package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/services/whatsapp"
	"arfcoder-go/internal/utils"
	"time"

	"github.com/gofiber/fiber/v2"
)

// --- DASHBOARD STATS ---
func GetDashboardStats(c *fiber.Ctx) error {
	var totalOrders int64
	var totalProducts int64
	var totalUsers int64
	var totalSales float64

	database.DB.Model(&models.Order{}).Count(&totalOrders)
	database.DB.Model(&models.Product{}).Count(&totalProducts)
	database.DB.Model(&models.User{}).Count(&totalUsers)

	// Sum total sales (PAID) - FIX QUERY
	database.DB.Model(&models.Order{}).Where("status = ?", models.OrderStatusPaid).Select("COALESCE(SUM(\"totalAmount\"), 0)").Scan(&totalSales)

	// Chart Data
	sixMonthsAgo := time.Now().AddDate(0, -5, 0)
	sixMonthsAgo = time.Date(sixMonthsAgo.Year(), sixMonthsAgo.Month(), 1, 0, 0, 0, 0, sixMonthsAgo.Location())

	recentOrders := make([]models.Order, 0) // Init slice
	// FIX QUERY
	database.DB.Where("status = ? AND \"createdAt\" >= ?", models.OrderStatusPaid, sixMonthsAgo).Find(&recentOrders)

	monthlyStats := make(map[string]float64)
	monthNames := []string{"Jan", "Feb", "Mar", "Apr", "Mei", "Jun", "Jul", "Agu", "Sep", "Okt", "Nov", "Des"}
	
	for i := 0; i < 6; i++ {
		d := time.Now().AddDate(0, -i, 0)
		key := monthNames[int(d.Month())-1]
		monthlyStats[key] = 0
	}

	for _, o := range recentOrders {
		key := monthNames[int(o.CreatedAt.Month())-1]
		monthlyStats[key] += o.TotalAmount
	}

	var labels []string
	var data []float64

	for i := 5; i >= 0; i-- {
		d := time.Now().AddDate(0, -i, 0)
		key := monthNames[int(d.Month())-1]
		labels = append(labels, key)
		data = append(data, monthlyStats[key])
	}

	return c.JSON(fiber.Map{
		"totalOrders":   totalOrders,
		"totalProducts": totalProducts,
		"totalUsers":    totalUsers,
		"totalSales":    totalSales,
		"chart": fiber.Map{
			"labels": labels,
			"data":   data,
		},
	})
}

// --- ORDER MANAGEMENT ---
func GetAllOrders(c *fiber.Ctx) error {
	orders := make([]models.Order, 0)
	// FIX QUERY
	database.DB.Preload("User").Preload("Items.Product").Order("\"createdAt\" desc").Find(&orders)
	return c.JSON(orders)
}

func UpdateOrderStatus(c *fiber.Ctx) error {
	id := c.Params("id")
	type Req struct {
		Status      string `json:"status"`
		RefundProof string `json:"refundProof"`
	}
	var req Req
	c.BodyParser(&req)

	// FIX QUERY
	database.DB.Model(&models.Order{}).Where("id = ?", id).Updates(models.Order{Status: req.Status, RefundProof: req.RefundProof})
	return c.JSON(fiber.Map{"message": "Status updated"})
}

func UpdateDeliveryInfo(c *fiber.Ctx) error {
	id := c.Params("id")
	type Req struct {
		DeliveryInfo string `json:"deliveryInfo"`
	}
	var req Req
	c.BodyParser(&req)

	database.DB.Model(&models.Order{}).Where("id = ?", id).Updates(models.Order{
		DeliveryInfo: req.DeliveryInfo,
		Status:       models.OrderStatusShipped,
	})
	return c.JSON(fiber.Map{"message": "Delivery info updated"})
}

// --- USER MANAGEMENT ---
func GetAllUsers(c *fiber.Ctx) error {
	users := make([]models.User, 0)
	// FIX QUERY (Select CamelCase columns if needed, but GORM maps them now)
	// But Select() overrides GORM, so we must use quoted names
	database.DB.Select("id, name, email, role, \"isVerified\", \"createdAt\"").Order("\"createdAt\" desc").Find(&users)
	return c.JSON(users)
}

func DeleteUser(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.User{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "User deleted"})
}

// --- SERVICE MANAGEMENT ---
func GetAdminServices(c *fiber.Ctx) error {
	services := make([]models.Service, 0)
	database.DB.Order("\"createdAt\" desc").Find(&services)
	return c.JSON(services)
}

func UpsertService(c *fiber.Ctx) error {
	var req models.Service
	c.BodyParser(&req)
	if req.ID == "" || req.ID == "new" {
		req.ID = utils.GenerateRandomString(10)
		database.DB.Create(&req)
	} else {
		database.DB.Model(&models.Service{}).Where("id = ?", req.ID).Updates(req)
	}
	return c.JSON(req)
}

func DeleteService(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Service{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Service deleted"})
}

// --- TIMELINE ---
func UpdateOrderTimeline(c *fiber.Ctx) error {
	id := c.Params("id")
	type Req struct {
		Title       string `json:"title"`
		Description string `json:"description"`
	}
	var req Req
	c.BodyParser(&req)

	tl := models.OrderTimeline{
		OrderID:     id,
		Title:       req.Title,
		Description: req.Description,
		Timestamp:   time.Now(),
	}
	database.DB.Create(&tl)
	return c.JSON(tl)
}

func DeleteOrderTimeline(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.OrderTimeline{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

// --- WA BOT CONTROL ---
func GetWaStatus(c *fiber.Ctx) error {
	status := "DISCONNECTED"
	qr := whatsapp.GetQR()
	
	if whatsapp.IsConnected() {
		if whatsapp.IsLoggedIn() {
			status = "CONNECTED"
			qr = "" 
		} else {
			status = "Scan QR"
		}
	}
	
	return c.JSON(fiber.Map{
		"status": status,
		"qr":     qr,
	})
}

func LogoutWa(c *fiber.Ctx) error {
	whatsapp.Logout()
	return c.JSON(fiber.Map{"message": "WA Logged out"})
}

func StartWa(c *fiber.Ctx) error {
	go whatsapp.Connect()
	return c.JSON(fiber.Map{"message": "WA Connection initiated"})
}
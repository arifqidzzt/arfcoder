package handlers

import (
	"github.com/arifqi/arfcoder-server/internal/config"
	"github.com/arifqi/arfcoder-server/internal/models"
	"github.com/arifqi/arfcoder-server/pkg/services"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// --- DASHBOARD ---
func GetDashboardStats(c *fiber.Ctx) error {
	var totalOrders int64
	var totalProducts int64
	var totalUsers int64
	
	config.DB.Model(&models.Order{}).Count(&totalOrders)
	config.DB.Model(&models.Product{}).Count(&totalProducts)
	config.DB.Model(&models.User{}).Count(&totalUsers)

	var totalSales float64
	config.DB.Model(&models.Order{}).Where("status = ?", models.StatusPaid).Select("coalesce(sum(total_amount), 0)").Scan(&totalSales)

	// Chart Data (Simple 6 months logic)
	// For production, use raw SQL date_trunc query
	
	return c.JSON(fiber.Map{
		"totalOrders":   totalOrders,
		"totalProducts": totalProducts,
		"totalUsers":    totalUsers,
		"totalSales":    totalSales,
		"chart": fiber.Map{
			"labels": []string{"Jan", "Feb", "Mar", "Apr", "May", "Jun"},
			"data":   []int{0, 0, 0, 0, 0, 0}, // Placeholder for MVP
		},
	})
}

// --- USERS ---
func GetAllUsers(c *fiber.Ctx) error {
	var users []models.User
	config.DB.Order("created_at desc").Find(&users)
	return c.JSON(users)
}

func DeleteUser(c *fiber.Ctx) error {
	id := c.Params("id")
	config.DB.Delete(&models.User{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "User deleted"})
}

// --- SERVICES ---
func GetServices(c *fiber.Ctx) error {
	var s []models.Service
	config.DB.Order("created_at desc").Find(&s)
	return c.JSON(s)
}

func UpsertService(c *fiber.Ctx) error {
	var req models.Service
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid"})
	}

	if req.ID == "" {
		req.ID = uuid.New().String()
		config.DB.Create(&req)
	} else {
		config.DB.Save(&req)
	}
	return c.JSON(req)
}

func DeleteService(c *fiber.Ctx) error {
	config.DB.Delete(&models.Service{}, "id = ?", c.Params("id"))
	return c.JSON(fiber.Map{"message": "Deleted"})
}

// --- CHAT ---
func GetUserChatHistory(c *fiber.Ctx) error {
	userId := c.Params("userId")
	var msgs []models.Message
	config.DB.Where("sender_id = ? OR (is_admin = true AND target_user_id = ?)", userId, userId).Order("created_at asc").Find(&msgs)
	return c.JSON(msgs)
}

// --- WA ---
func GetWAStatus(c *fiber.Ctx) error {
	status := "DISCONNECTED"
	qr := ""
	if services.WAClient != nil && services.WAClient.IsConnected() {
		status = "CONNECTED"
	}
	// Note: Real-time QR is streamed via Socket, this is initial state
	return c.JSON(fiber.Map{"status": status, "qr": qr})
}

func StartWA(c *fiber.Ctx) error {
	qrChan, err := services.GenerateQR()
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to start WA"})
	}
	
	go func() {
		for qr := range qrChan {
			services.Server.BroadcastToNamespace("/", "wa_qr", map[string]interface{}{"qr": qr})
		}
	}()

	return c.JSON(fiber.Map{"message": "WA Starting..."})
}

func LogoutWA(c *fiber.Ctx) error {
	services.LogoutWhatsApp()
	return c.JSON(fiber.Map{"message": "Logged out"})
}
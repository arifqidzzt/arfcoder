package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"time"

	"github.com/gofiber/fiber/v2"
)

// Helper to get common data (User, CartCount)
func getCommonData(c *fiber.Ctx) fiber.Map {
	data := fiber.Map{
		"Title": "ArfCoder",
	}

	// Get User from Token (Cookie-based for Frontend)

token := c.Cookies("auth_token")
	if token != "" {
		claims, err := utils.VerifyToken(token)
		if err == nil {
			var user models.User
			database.DB.First(&user, "id = ?", claims.UserID)
			data["User"] = user

			var cartCount int64
			database.DB.Model(&models.CartItem{}).Where("\"userId\" = ?", user.ID).Count(&cartCount)
			data["CartCount"] = cartCount
		}
	}

	return data
}

func RenderHome(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Beranda"

	var products []models.Product
	database.DB.Limit(6).Order("\"createdAt\" desc").Find(&products)
	data["Products"] = products

	var flashSales []models.FlashSale
	now := time.Now()
	database.DB.Preload("Product").Where("\"isActive\" = ? AND \"startTime\" <= ? AND \"endTime\" > ?", true, now, now).Find(&flashSales)
	data["FlashSales"] = flashSales

	return c.Render("pages/index", data)
}

func RenderProducts(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Produk Kami"

	var products []models.Product
	database.DB.Order("\"createdAt\" desc").Find(&products)
	data["Products"] = products

	return c.Render("pages/products", data)
}

func RenderCart(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Keranjang Belanja"

	user, ok := data["User"].(models.User)
	if !ok {
		return c.Redirect("/login")
	}

	data["CartItems"] = getCartData(user.ID)["CartItems"]
	data["Total"] = getCartData(user.ID)["Total"]

	return c.Render("pages/cart", data)
}

func RenderCheckout(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Checkout"

	user, ok := data["User"].(models.User)
	if !ok { return c.Redirect("/login") }

	cartData := getCartData(user.ID)
	if len(cartData["CartItems"].([]models.CartItem)) == 0 {
		return c.Redirect("/cart")
	}

	data["CartItems"] = cartData["CartItems"]
	data["Total"] = cartData["Total"]

	return c.Render("pages/checkout", data)
}

func RenderProfile(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Profil Saya"

	user, ok := data["User"].(models.User)
	if !ok { return c.Redirect("/login") }

	// Spending logic
	var totalSpent float64
	database.DB.Model(&models.Order{}).Where("\"userId\" = ? AND status IN ?", user.ID, []string{models.OrderStatusPaid, models.OrderStatusProcessing, models.OrderStatusShipped, models.OrderStatusCompleted}).Select("COALESCE(SUM(\"totalAmount\"), 0)").Scan(&totalSpent)
	data["TotalSpent"] = totalSpent

	return c.Render("pages/profile", data)
}

func RenderOrders(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Pesanan Saya"

	user, ok := data["User"].(models.User)
	if !ok { return c.Redirect("/login") }

	var orders []models.Order
	database.DB.Preload("Items.Product").Where("\"userId\" = ?", user.ID).Order("\"createdAt\" desc").Find(&orders)
	data["Orders"] = orders

	return c.Render("pages/orders", data)
}

func RenderAdminDashboard(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Admin Dashboard"

	user, ok := data["User"].(models.User)
	if !ok || (user.Role != "ADMIN" && user.Role != "SUPER_ADMIN") {
		return c.Redirect("/")
	}

	var totalOrders int64
	var totalProducts int64
	var totalUsers int64
	var totalSales float64

	database.DB.Model(&models.Order{}).Count(&totalOrders)
	database.DB.Model(&models.Product{}).Count(&totalProducts)
	database.DB.Model(&models.User{}).Count(&totalUsers)
	database.DB.Model(&models.Order{}).Where("status = ?", models.OrderStatusPaid).Select("COALESCE(SUM(\"totalAmount\"), 0)").Scan(&totalSales)

	data["Stats"] = fiber.Map{
		"TotalOrders":   totalOrders,
		"TotalProducts": totalProducts,
		"TotalUsers":    totalUsers,
		"TotalSales":    totalSales,
	}

	return c.Render("pages/admin/dashboard", data, "layouts/admin") // Note: Use specific layout
}

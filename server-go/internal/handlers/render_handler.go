package handlers

import (
	"arfcoder-go/internal/config"
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
		data["Token"] = token
		claims, err := utils.VerifyToken(token)		if err == nil {
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

func RenderLogin(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Login"
	data["GoogleClientID"] = config.GoogleClientID
	return c.Render("pages/login", data)
}

func RenderRegister(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Daftar"
	return c.Render("pages/register", data)
}

func RenderProductDetail(c *fiber.Ctx) error {
	id := c.Params("id")
	data := getCommonData(c)

	var product models.Product
	if err := database.DB.Preload("Category").Preload("Reviews.User").First(&product, "id = ?", id).Error; err != nil {
		return c.Redirect("/products")
	}

	data["Title"] = product.Name
	data["Product"] = product

	return c.Render("pages/product_detail", data)
}

func RenderAdminFlashSales(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Kelola Flash Sale"
	var flashSales []models.FlashSale
	database.DB.Preload("Product").Order("\"createdAt\" desc").Find(&flashSales)
	data["FlashSales"] = flashSales
	
	var products []models.Product
	database.DB.Find(&products)
	data["AllProducts"] = products

	return c.Render("pages/admin/flash_sales", data, "layouts/admin")
}

func RenderForgotPassword(c *fiber.Ctx) error {
	return c.Render("pages/forgot_password", getCommonData(c))
}

func RenderResetPassword(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Token"] = c.Query("token")
	return c.Render("pages/reset_password", data)
}

func RenderVerifyOtp(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["UserID"] = c.Query("userId")
	return c.Render("pages/verify_otp", data)
}

func RenderVerifyAdmin(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["UserID"] = c.Query("userId")
	return c.Render("pages/verify_admin", data)
}

func RenderAdminOrderManage(c *fiber.Ctx) error {
	id := c.Params("id")
	data := getCommonData(c)
	user, ok := data["User"].(models.User)
	if !ok { return c.Redirect("/login") }

	var order models.Order
	query := database.DB.Preload("Items.Product").Preload("Timeline")
	
	if user.Role == "ADMIN" || user.Role == "SUPER_ADMIN" {
		query.First(&order, "id = ?", id)
	} else {
		query.Where("id = ? AND \"userId\" = ?", id, user.ID).First(&order)
	}

	if order.ID == "" { return c.Redirect("/orders") }

	data["Title"] = "Detail Pesanan #" + order.InvoiceNumber
	data["Order"] = order

	return c.Render("pages/order_detail", data)
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

func RenderPublicServices(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Layanan Kami"
	var services []models.Service
	database.DB.Order("\"createdAt\" desc").Find(&services)
	data["Services"] = services
	return c.Render("pages/services", data)
}

func RenderContact(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Hubungi Kami"
	return c.Render("pages/contact", data)
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

	return c.Render("pages/admin/dashboard", data, "layouts/admin")
}

func RenderAdminProducts(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Kelola Produk"
	var products []models.Product
	database.DB.Order("\"createdAt\" desc").Find(&products)
	data["Products"] = products
	return c.Render("pages/admin/products", data, "layouts/admin")
}

func RenderAdminProductForm(c *fiber.Ctx) error {
	id := c.Params("id")
	data := getCommonData(c)
	data["Title"] = "Form Produk"

	var product models.Product
	if id != "new" {
		database.DB.First(&product, "id = ?", id)
	}
	data["Product"] = product

	var categories []models.Category
	database.DB.Find(&categories)
	data["Categories"] = categories

	return c.Render("pages/admin/product_form", data, "layouts/admin")
}

func RenderAdminOrderManage(c *fiber.Ctx) error {
	id := c.Params("id")
	data := getCommonData(c)
	data["Title"] = "Kelola Pesanan"

	var order models.Order
	database.DB.Preload("Items.Product").Preload("User").Preload("Timeline").First(&order, "id = ?", id)
	data["Order"] = order

	return c.Render("pages/admin/order_manage", data, "layouts/admin")
}

func RenderProfileSecurity(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Keamanan Akun"
	return c.Render("pages/profile_security", data)
}

func RenderAdminOrders(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Kelola Pesanan"
	var orders []models.Order
	database.DB.Preload("User").Order("\"createdAt\" desc").Find(&orders)
	data["Orders"] = orders
	return c.Render("pages/admin/orders", data, "layouts/admin")
}

func RenderAdminUsers(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Kelola Pengguna"
	var users []models.User
	database.DB.Order("\"createdAt\" desc").Find(&users)
	data["Users"] = users
	return c.Render("pages/admin/users", data, "layouts/admin")
}

func RenderAdminVouchers(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Kelola Voucher"
	var vouchers []models.Voucher
	database.DB.Order("\"createdAt\" desc").Find(&vouchers)
	data["Vouchers"] = vouchers
	return c.Render("pages/admin/vouchers", data, "layouts/admin")
}

func RenderAdminServices(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Kelola Jasa"
	var services []models.Service
	database.DB.Order("\"createdAt\" desc").Find(&services)
	data["Services"] = services
	return c.Render("pages/admin/services", data, "layouts/admin")
}

func RenderAdminChat(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Live Chat"
	return c.Render("pages/admin/chat", data, "layouts/admin")
}

func RenderAdminWhatsapp(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "WhatsApp Bot"
	return c.Render("pages/admin/whatsapp", data, "layouts/admin")
}

func RenderAdminLogs(c *fiber.Ctx) error {
	data := getCommonData(c)
	data["Title"] = "Audit Logs"
	var logs []models.ActivityLog
	database.DB.Preload("User").Order("\"createdAt\" desc").Limit(100).Find(&logs)
	data["Logs"] = logs
	return c.Render("pages/admin/logs", data, "layouts/admin")
}

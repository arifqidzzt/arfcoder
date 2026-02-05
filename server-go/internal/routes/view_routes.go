package routes

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/middleware"
	"arfcoder-go/internal/models"

	"github.com/gofiber/fiber/v2"
)

// SetupViewRoutes configures all frontend page routes
func SetupViewRoutes(app *fiber.App) {
	// ============ PUBLIC PAGES ============

	// Homepage
	app.Get("/", func(c *fiber.Ctx) error {
		// Fetch products for homepage
		var products []models.Product
		database.DB.Order("created_at DESC").Limit(6).Find(&products)

		// Fetch active flash sales
		var flashSales []models.FlashSale
		database.DB.Preload("Product").Where("end_time > NOW() AND start_time < NOW()").Find(&flashSales)

		return c.Render("pages/home", fiber.Map{
			"Title":           "",
			"MetaDescription": "ArfCoder - Solusi Digital untuk Pertumbuhan Bisnis Anda",
			"Products":        products,
			"FlashSales":      flashSales,
			"Languages":       []string{"JavaScript", "TypeScript", "Python", "Go", "Java", "PHP", "Rust", "C++", "Swift", "Kotlin", "Ruby", "Dart"},
		})
	})

	// Products page
	app.Get("/products", func(c *fiber.Ctx) error {
		var products []models.Product
		database.DB.Where("type = ?", "PRODUCT").Order("created_at DESC").Find(&products)

		return c.Render("pages/products", fiber.Map{
			"Title":           "Produk",
			"MetaDescription": "Katalog produk digital ArfCoder",
			"Products":        products,
		})
	})

	// Product detail
	app.Get("/products/:id", func(c *fiber.Ctx) error {
		id := c.Params("id")
		var product models.Product
		if err := database.DB.First(&product, "id = ?", id).Error; err != nil {
			return c.Status(404).Render("pages/404", fiber.Map{
				"Title": "Produk Tidak Ditemukan",
			})
		}

		// Get reviews
		var reviews []models.Review
		database.DB.Preload("User").Where("product_id = ?", id).Order("created_at DESC").Find(&reviews)

		return c.Render("pages/product_detail", fiber.Map{
			"Title":           product.Name,
			"MetaDescription": product.Description,
			"Product":         product,
			"Reviews":         reviews,
		})
	})

	// Services page
	app.Get("/services", func(c *fiber.Ctx) error {
		var services []models.Product
		database.DB.Where("type = ?", "SERVICE").Order("created_at DESC").Find(&services)

		return c.Render("pages/services", fiber.Map{
			"Title":           "Layanan",
			"MetaDescription": "Layanan pengembangan digital ArfCoder",
			"Services":        services,
		})
	})

	// Static pages
	app.Get("/contact", renderStaticPage("pages/contact", "Hubungi Kami", "Hubungi tim ArfCoder"))
	app.Get("/contact/support", renderStaticPage("pages/contact_support", "Dukungan", "Pusat bantuan ArfCoder"))
	app.Get("/faq", renderStaticPage("pages/faq", "FAQ", "Pertanyaan yang sering diajukan"))
	app.Get("/terms", renderStaticPage("pages/terms", "Syarat & Ketentuan", "Syarat dan ketentuan layanan"))
	app.Get("/privacy", renderStaticPage("pages/privacy", "Kebijakan Privasi", "Kebijakan privasi ArfCoder"))
	app.Get("/refund-policy", renderStaticPage("pages/refund_policy", "Kebijakan Refund", "Kebijakan pengembalian dana"))

	// ============ AUTH PAGES ============
	app.Get("/login", renderStaticPage("pages/login", "Masuk", "Login ke akun ArfCoder"))
	app.Get("/register", renderStaticPage("pages/register", "Daftar", "Buat akun ArfCoder"))
	app.Get("/verify-otp", renderStaticPage("pages/verify_otp", "Verifikasi OTP", "Verifikasi email Anda"))
	app.Get("/verify-admin", renderStaticPage("pages/verify_admin", "Verifikasi Admin", "Verifikasi keamanan admin"))
	app.Get("/forgot-password", renderStaticPage("pages/forgot_password", "Lupa Password", "Reset password akun Anda"))
	app.Get("/forgot-password/sent", renderStaticPage("pages/forgot_password_sent", "Email Terkirim", "Cek email Anda"))
	app.Get("/reset-password", renderStaticPage("pages/reset_password", "Reset Password", "Buat password baru"))

	// ============ USER PAGES (Protected) ============
	userPages := app.Group("", middleware.OptionalAuth)

	userPages.Get("/cart", func(c *fiber.Ctx) error {
		return c.Render("pages/cart", fiber.Map{
			"Title":           "Keranjang",
			"MetaDescription": "Keranjang belanja Anda",
		})
	})

	userPages.Get("/checkout", func(c *fiber.Ctx) error {
		return c.Render("pages/checkout", fiber.Map{
			"Title":           "Checkout",
			"MetaDescription": "Selesaikan pembayaran",
		})
	})

	userPages.Get("/orders", func(c *fiber.Ctx) error {
		return c.Render("pages/orders", fiber.Map{
			"Title":           "Pesanan Saya",
			"MetaDescription": "Riwayat pesanan Anda",
		})
	})

	userPages.Get("/orders/:id", func(c *fiber.Ctx) error {
		return c.Render("pages/order_detail", fiber.Map{
			"Title":           "Detail Pesanan",
			"MetaDescription": "Detail pesanan",
			"OrderID":         c.Params("id"),
		})
	})

	userPages.Get("/profile", func(c *fiber.Ctx) error {
		return c.Render("pages/profile", fiber.Map{
			"Title":           "Profil",
			"MetaDescription": "Pengaturan profil Anda",
		})
	})

	// ============ ADMIN PAGES ============
	adminPages := app.Group("/admin", middleware.OptionalAuth)

	adminMenuItems := []fiber.Map{
		{"Href": "/admin", "Icon": "bar-chart-3", "Label": "Dashboard"},
		{"Href": "/admin/products", "Icon": "package", "Label": "Produk"},
		{"Href": "/admin/orders", "Icon": "shopping-bag", "Label": "Pesanan"},
		{"Href": "/admin/users", "Icon": "users", "Label": "Pengguna"},
		{"Href": "/admin/vouchers", "Icon": "ticket", "Label": "Vouchers"},
		{"Href": "/admin/flash-sale", "Icon": "zap", "Label": "Flash Sale"},
		{"Href": "/admin/services", "Icon": "layers", "Label": "Layanan"},
		{"Href": "/admin/chat", "Icon": "message-square", "Label": "Live Chat"},
		{"Href": "/admin/whatsapp", "Icon": "smartphone", "Label": "WhatsApp Bot"},
		{"Href": "/admin/logs", "Icon": "history", "Label": "Audit Logs"},
	}

	// Admin Dashboard
	adminPages.Get("/", func(c *fiber.Ctx) error {
		return c.Render("admin/dashboard", fiber.Map{
			"Title":      "Dashboard",
			"ActivePath": "/admin",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin"),
		}, "layouts/admin")
	})

	// Admin Products
	adminPages.Get("/products", func(c *fiber.Ctx) error {
		var products []models.Product
		database.DB.Order("created_at DESC").Find(&products)

		return c.Render("admin/products", fiber.Map{
			"Title":      "Kelola Produk",
			"ActivePath": "/admin/products",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/products"),
			"Products":   products,
		}, "layouts/admin")
	})

	adminPages.Get("/products/new", func(c *fiber.Ctx) error {
		return c.Render("admin/product_new", fiber.Map{
			"Title":      "Tambah Produk",
			"ActivePath": "/admin/products",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/products"),
		}, "layouts/admin")
	})

	adminPages.Get("/products/:id", func(c *fiber.Ctx) error {
		id := c.Params("id")
		var product models.Product
		database.DB.First(&product, "id = ?", id)

		return c.Render("admin/product_edit", fiber.Map{
			"Title":      "Edit Produk",
			"ActivePath": "/admin/products",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/products"),
			"Product":    product,
		}, "layouts/admin")
	})

	// Admin Orders
	adminPages.Get("/orders", func(c *fiber.Ctx) error {
		var orders []models.Order
		database.DB.Preload("User").Order("created_at DESC").Find(&orders)

		return c.Render("admin/orders", fiber.Map{
			"Title":      "Kelola Pesanan",
			"ActivePath": "/admin/orders",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/orders"),
			"Orders":     orders,
		}, "layouts/admin")
	})

	adminPages.Get("/orders/:id", func(c *fiber.Ctx) error {
		id := c.Params("id")
		var order models.Order
		database.DB.Preload("User").Preload("OrderItems.Product").First(&order, "id = ?", id)

		return c.Render("admin/order_detail", fiber.Map{
			"Title":      "Detail Pesanan",
			"ActivePath": "/admin/orders",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/orders"),
			"Order":      order,
		}, "layouts/admin")
	})

	// Admin Users
	adminPages.Get("/users", func(c *fiber.Ctx) error {
		var users []models.User
		database.DB.Order("created_at DESC").Find(&users)

		return c.Render("admin/users", fiber.Map{
			"Title":      "Kelola Pengguna",
			"ActivePath": "/admin/users",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/users"),
			"Users":      users,
		}, "layouts/admin")
	})

	// Admin Vouchers
	adminPages.Get("/vouchers", func(c *fiber.Ctx) error {
		var vouchers []models.Voucher
		database.DB.Order("created_at DESC").Find(&vouchers)

		return c.Render("admin/vouchers", fiber.Map{
			"Title":      "Kelola Voucher",
			"ActivePath": "/admin/vouchers",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/vouchers"),
			"Vouchers":   vouchers,
		}, "layouts/admin")
	})

	// Admin Flash Sale
	adminPages.Get("/flash-sale", func(c *fiber.Ctx) error {
		var flashSales []models.FlashSale
		database.DB.Preload("Product").Order("created_at DESC").Find(&flashSales)

		return c.Render("admin/flash_sale", fiber.Map{
			"Title":      "Flash Sale",
			"ActivePath": "/admin/flash-sale",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/flash-sale"),
			"FlashSales": flashSales,
		}, "layouts/admin")
	})

	// Admin Services
	adminPages.Get("/services", func(c *fiber.Ctx) error {
		var services []models.Product
		database.DB.Where("type = ?", "SERVICE").Order("created_at DESC").Find(&services)

		return c.Render("admin/services", fiber.Map{
			"Title":      "Kelola Layanan",
			"ActivePath": "/admin/services",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/services"),
			"Services":   services,
		}, "layouts/admin")
	})

	// Admin Chat
	adminPages.Get("/chat", func(c *fiber.Ctx) error {
		return c.Render("admin/chat", fiber.Map{
			"Title":      "Live Chat",
			"ActivePath": "/admin/chat",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/chat"),
		}, "layouts/admin")
	})

	// Admin WhatsApp
	adminPages.Get("/whatsapp", func(c *fiber.Ctx) error {
		return c.Render("admin/whatsapp", fiber.Map{
			"Title":      "WhatsApp Bot",
			"ActivePath": "/admin/whatsapp",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/whatsapp"),
		}, "layouts/admin")
	})

	// Admin Logs
	adminPages.Get("/logs", func(c *fiber.Ctx) error {
		return c.Render("admin/logs", fiber.Map{
			"Title":      "Audit Logs",
			"ActivePath": "/admin/logs",
			"MenuItems":  setActiveMenuItem(adminMenuItems, "/admin/logs"),
		}, "layouts/admin")
	})

	// Admin Profile
	adminPages.Get("/profile", func(c *fiber.Ctx) error {
		return c.Render("admin/profile", fiber.Map{
			"Title":      "Pengaturan & 2FA",
			"ActivePath": "/admin/profile",
			"MenuItems":  adminMenuItems,
		}, "layouts/admin")
	})
}

// Helper function to render static pages
func renderStaticPage(template, title, description string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		return c.Render(template, fiber.Map{
			"Title":           title,
			"MetaDescription": description,
		})
	}
}

// Helper function to set active menu item
func setActiveMenuItem(items []fiber.Map, activePath string) []fiber.Map {
	result := make([]fiber.Map, len(items))
	for i, item := range items {
		newItem := fiber.Map{
			"Href":   item["Href"],
			"Icon":   item["Icon"],
			"Label":  item["Label"],
			"Active": item["Href"] == activePath,
		}
		result[i] = newItem
	}
	return result
}

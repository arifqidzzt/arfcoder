package web

import (
	"fmt"
	"html/template"
	"log"
	"net/http"
	"path/filepath"

	"arfcoder-go/internal/config"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/filesystem"
)

var templates *template.Template

// InitTemplates loads and parses all HTML templates
func InitTemplates() {
	var err error
	templateDir := "web/templates"

	// Define template functions
	funcMap := template.FuncMap{
		"formatPrice": func(price interface{}) string {
			switch v := price.(type) {
			case float64:
				return formatIDR(v)
			case int:
				return formatIDR(float64(v))
			case int64:
				return formatIDR(float64(v))
			default:
				return "Rp 0"
			}
		},
	}

	// Parse all templates
	templates = template.New("").Funcs(funcMap)

	patterns := []string{
		filepath.Join(templateDir, "layouts", "*.html"),
		filepath.Join(templateDir, "partials", "*.html"),
		filepath.Join(templateDir, "pages", "*.html"),
		filepath.Join(templateDir, "pages", "admin", "*.html"),
	}

	for _, pattern := range patterns {
		templates, err = templates.ParseGlob(pattern)
		if err != nil {
			log.Printf("Warning: Could not parse templates in %s: %v", pattern, err)
		}
	}

	log.Println("Templates loaded successfully")
}

func formatIDR(amount float64) string {
	// Simple IDR formatting
	return "Rp " + formatNumber(amount)
}

func formatNumber(n float64) string {
	// Format number with thousand separators
	str := ""
	i := int64(n)
	for i > 0 {
		if len(str) > 0 {
			str = "." + str
		}
		if i < 1000 {
			str = fmt.Sprintf("%d", i) + str
			break
		}
		str = fmt.Sprintf("%03d", i%1000) + str
		i = i / 1000
	}
	if str == "" {
		str = "0"
	}
	return str
}

// SetupWebRoutes sets up all web routes for template rendering
func SetupWebRoutes(app *fiber.App) {
	// Serve static files
	app.Use("/static", filesystem.New(filesystem.Config{
		Root:   http.Dir("./web/static"),
		Browse: false,
	}))

	// Public pages
	app.Get("/", renderPage("home", "base"))
	app.Get("/products", renderPage("products", "base"))
	app.Get("/products/:id", renderPage("product_detail", "base"))
	app.Get("/cart", renderPage("cart", "base"))
	app.Get("/checkout", renderPage("checkout", "base"))
	app.Get("/orders", renderPage("orders", "base"))
	app.Get("/orders/:id", renderPage("order_detail", "base"))
	app.Get("/profile", renderPage("profile", "base"))
	app.Get("/login", renderPage("login", "base"))
	app.Get("/register", renderPage("register", "base"))
	app.Get("/verify-otp", renderPage("verify_otp", "base"))
	app.Get("/verify-admin", renderPage("verify_admin", "base"))
	app.Get("/forgot-password", renderPage("forgot_password", "base"))
	app.Get("/reset-password", renderPage("reset_password", "base"))
	app.Get("/services", renderPage("services", "base"))
	app.Get("/terms", renderPage("terms", "base"))
	app.Get("/privacy", renderPage("privacy", "base"))
	app.Get("/refund-policy", renderPage("refund_policy", "base"))
	app.Get("/faq", renderPage("faq", "base"))
	app.Get("/contact", renderPage("contact", "base"))

	// Admin pages
	admin := app.Group("/admin")
	admin.Get("/", renderPage("admin/dashboard", "admin"))
	admin.Get("/products", renderPage("admin/products", "admin"))
	admin.Get("/orders", renderPage("admin/orders", "admin"))
	admin.Get("/users", renderPage("admin/users", "admin"))
	admin.Get("/vouchers", renderPage("admin/vouchers", "admin"))
	admin.Get("/flash-sales", renderPage("admin/flash_sales", "admin"))
	admin.Get("/services", renderPage("admin/services", "admin"))
	admin.Get("/chat", renderPage("admin/chat", "admin"))
	admin.Get("/whatsapp", renderPage("admin/whatsapp", "admin"))
	admin.Get("/logs", renderPage("admin/logs", "admin"))
	admin.Get("/profile", renderPage("admin/profile", "admin"))
}

// renderPage returns a handler that renders a specific page with a layout
func renderPage(page, layout string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		data := fiber.Map{
			"Title":             getPageTitle(page),
			"MidtransClientKey": config.MidtransClientKey,
		}

		// Check for HTMX request - only return page content
		if c.Get("HX-Request") == "true" {
			c.Set("Content-Type", "text/html")
			return renderTemplate(c, page, data)
		}

		// Full page render with layout
		data["Page"] = page
		return renderWithLayout(c, page, layout, data)
	}
}

func renderTemplate(c *fiber.Ctx, name string, data fiber.Map) error {
	c.Set("Content-Type", "text/html")
	return templates.ExecuteTemplate(c.Response().BodyWriter(), name, data)
}

func renderWithLayout(c *fiber.Ctx, page, layout string, data fiber.Map) error {
	c.Set("Content-Type", "text/html")

	// For admin pages use admin layout, otherwise base
	layoutTemplate := layout + ".html"
	return templates.ExecuteTemplate(c.Response().BodyWriter(), layoutTemplate, data)
}

func getPageTitle(page string) string {
	titles := map[string]string{
		"home":              "ArfCoder - Digital Solutions",
		"products":          "Produk - ArfCoder",
		"product_detail":    "Detail Produk - ArfCoder",
		"cart":              "Keranjang - ArfCoder",
		"checkout":          "Checkout - ArfCoder",
		"orders":            "Pesanan Saya - ArfCoder",
		"order_detail":      "Detail Pesanan - ArfCoder",
		"profile":           "Profil - ArfCoder",
		"login":             "Masuk - ArfCoder",
		"register":          "Daftar - ArfCoder",
		"verify_otp":        "Verifikasi OTP - ArfCoder",
		"verify_admin":      "Verifikasi Admin - ArfCoder",
		"forgot_password":   "Lupa Password - ArfCoder",
		"reset_password":    "Reset Password - ArfCoder",
		"services":          "Layanan - ArfCoder",
		"terms":             "Syarat & Ketentuan - ArfCoder",
		"privacy":           "Kebijakan Privasi - ArfCoder",
		"refund_policy":     "Kebijakan Refund - ArfCoder",
		"faq":               "FAQ - ArfCoder",
		"contact":           "Hubungi Kami - ArfCoder",
		"admin/dashboard":   "Dashboard Admin - ArfCoder",
		"admin/products":    "Kelola Produk - ArfCoder",
		"admin/orders":      "Kelola Pesanan - ArfCoder",
		"admin/users":       "Kelola Pengguna - ArfCoder",
		"admin/vouchers":    "Kelola Voucher - ArfCoder",
		"admin/flash_sales": "Flash Sale - ArfCoder",
		"admin/services":    "Kelola Layanan - ArfCoder",
		"admin/chat":        "Live Chat - ArfCoder",
		"admin/whatsapp":    "WhatsApp Gateway - ArfCoder",
		"admin/logs":        "Activity Logs - ArfCoder",
		"admin/profile":     "Admin Profile - ArfCoder",
	}
	if title, ok := titles[page]; ok {
		return title
	}
	return "ArfCoder"
}

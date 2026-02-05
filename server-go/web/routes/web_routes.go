package web

import (
	"bytes"
	"fmt"
	"html/template"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"arfcoder-go/internal/config"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/filesystem"
)

var templates map[string]*template.Template

// InitTemplates loads and parses all HTML templates
func InitTemplates() {
	templates = make(map[string]*template.Template)
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
		"formatDate": func(date interface{}) string {
			return fmt.Sprintf("%v", date)
		},
	}

	// Load layout files
	baseLayout := filepath.Join(templateDir, "layouts", "base.html")
	adminLayout := filepath.Join(templateDir, "layouts", "admin.html")

	// Load partials
	partials, err := filepath.Glob(filepath.Join(templateDir, "partials", "*.html"))
	if err != nil {
		log.Printf("Error loading partials: %v", err)
	}

	// Load public page templates
	publicPages, _ := filepath.Glob(filepath.Join(templateDir, "pages", "*.html"))
	for _, page := range publicPages {
		name := strings.TrimSuffix(filepath.Base(page), ".html")
		files := append([]string{baseLayout, page}, partials...)
		tmpl, err := template.New("").Funcs(funcMap).ParseFiles(files...)
		if err != nil {
			log.Printf("Error parsing template %s: %v", name, err)
			continue
		}
		templates[name] = tmpl
		log.Printf("Loaded template: %s", name)
	}

	// Load admin page templates
	adminPages, _ := filepath.Glob(filepath.Join(templateDir, "pages", "admin", "*.html"))
	for _, page := range adminPages {
		name := "admin/" + strings.TrimSuffix(filepath.Base(page), ".html")
		files := append([]string{adminLayout, page}, partials...)
		tmpl, err := template.New("").Funcs(funcMap).ParseFiles(files...)
		if err != nil {
			log.Printf("Error parsing admin template %s: %v", name, err)
			continue
		}
		templates[name] = tmpl
		log.Printf("Loaded admin template: %s", name)
	}

	log.Printf("Templates loaded: %d total", len(templates))
}

func formatIDR(amount float64) string {
	return "Rp " + formatNumber(amount)
}

func formatNumber(n float64) string {
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
			"CurrentPath":       c.Path(),
		}

		tmpl, ok := templates[page]
		if !ok {
			log.Printf("Template not found: %s", page)
			return c.Status(404).SendString("Template not found: " + page)
		}

		// For HTMX requests, only return the content block
		if c.Get("HX-Request") == "true" {
			c.Set("Content-Type", "text/html")
			var buf bytes.Buffer
			contentName := "content"
			if layout == "admin" {
				contentName = "admin_content"
			}
			if err := tmpl.ExecuteTemplate(&buf, contentName, data); err != nil {
				log.Printf("Error executing content template %s: %v", page, err)
				return c.Status(500).SendString("Template error: " + err.Error())
			}
			return c.Send(buf.Bytes())
		}

		// Full page render with layout
		c.Set("Content-Type", "text/html")
		layoutName := layout + ".html"
		var buf bytes.Buffer
		if err := tmpl.ExecuteTemplate(&buf, layoutName, data); err != nil {
			log.Printf("Error executing layout %s for page %s: %v", layoutName, page, err)
			return c.Status(500).SendString("Template error: " + err.Error())
		}
		return c.Send(buf.Bytes())
	}
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

// GetWorkingDirectory returns the current working directory
func GetWorkingDirectory() string {
	wd, _ := os.Getwd()
	return wd
}

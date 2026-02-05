package render

import (
	"embed"
	"html/template"
	"io"
	"log"
	"strings"

	"github.com/gofiber/fiber/v2"
)

//go:embed templates/*
var viewsFS embed.FS

var templates *template.Template

// TemplateData holds data passed to templates
type TemplateData struct {
	Title       string
	Description string
	Data        interface{}
	User        interface{}
	Token       string
	Config      map[string]string
	Flash       map[string]string
}

// InitTemplates parses all templates at startup
func InitTemplates() {
	funcMap := template.FuncMap{
		"formatPrice": func(price float64) string {
			// Simple price formatter for IDR
			return formatIDR(price)
		},
		"formatDate": func(t interface{}) string {
			return formatDateTime(t)
		},
		"safeHTML": func(s string) template.HTML {
			return template.HTML(s)
		},
		"add": func(a, b int) int {
			return a + b
		},
		"sub": func(a, b int) int {
			return a - b
		},
		"mul": func(a, b float64) float64 {
			return a * b
		},
		"div": func(a, b float64) float64 {
			if b == 0 {
				return 0
			}
			return a / b
		},
		"calcDiscount": func(price, discount float64) float64 {
			return price * (1 - discount/100)
		},
		"truncate": func(s string, length int) string {
			if len(s) <= length {
				return s
			}
			return s[:length] + "..."
		},
		"contains": func(s, substr string) bool {
			return strings.Contains(s, substr)
		},
		"lower": func(s string) string {
			return strings.ToLower(s)
		},
		"upper": func(s string) string {
			return strings.ToUpper(s)
		},
	}

	var err error
	templates, err = template.New("").Funcs(funcMap).ParseFS(viewsFS, 
		"templates/layouts/*.html",
		"templates/partials/*.html",
		"templates/pages/*.html",
		"templates/admin/*.html",
	)
	if err != nil {
		log.Fatal("Error parsing templates:", err)
	}
	log.Println("✓ Templates loaded successfully")
}

// Render renders a template with the given data
func Render(c *fiber.Ctx, templateName string, data TemplateData) error {
	c.Set("Content-Type", "text/html; charset=utf-8")
	
	buf := new(strings.Builder)
	err := templates.ExecuteTemplate(buf, templateName, data)
	if err != nil {
		log.Printf("Template error (%s): %v", templateName, err)
		return c.Status(500).SendString("Internal Server Error: Template rendering failed")
	}
	
	return c.SendString(buf.String())
}

// RenderPartial renders a partial template (for HTMX responses)
func RenderPartial(c *fiber.Ctx, templateName string, data interface{}) error {
	c.Set("Content-Type", "text/html; charset=utf-8")
	
	buf := new(strings.Builder)
	err := templates.ExecuteTemplate(buf, templateName, data)
	if err != nil {
		log.Printf("Partial template error (%s): %v", templateName, err)
		return c.Status(500).SendString("Partial render error")
	}
	
	return c.SendString(buf.String())
}

// Helper functions
func formatIDR(amount float64) string {
	// Simple IDR formatter
	intAmount := int64(amount)
	str := ""
	negative := false
	if intAmount < 0 {
		negative = true
		intAmount = -intAmount
	}
	
	s := ""
	for intAmount > 0 {
		if len(s) > 0 && len(s)%3 == 0 {
			s = "." + s
		}
		s = string(rune('0'+intAmount%10)) + s
		intAmount /= 10
	}
	if s == "" {
		s = "0"
	}
	
	str = "Rp " + s
	if negative {
		str = "-" + str
	}
	return str
}

func formatDateTime(t interface{}) string {
	// Handle different time types
	switch v := t.(type) {
	case string:
		return v
	default:
		return ""
	}
}

// RenderToString is for getting rendered HTML as string
func RenderToString(templateName string, data interface{}) (string, error) {
	buf := new(strings.Builder)
	err := templates.ExecuteTemplate(buf, templateName, data)
	if err != nil {
		return "", err
	}
	return buf.String(), nil
}

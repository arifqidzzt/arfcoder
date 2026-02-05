package main

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/handlers"
	"arfcoder-go/internal/routes"
	"arfcoder-go/internal/services/whatsapp"
	"fmt"
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/helmet"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/template/html/v2"
)

func main() {
	// 1. Config
	config.LoadConfig()

	// 2. Database
	database.Connect()

	// 3. Init Services
	handlers.InitMidtrans()

	go func() {
		if err := whatsapp.Connect(); err != nil {
			log.Println("Failed to start WhatsApp Service:", err)
		}
	}()

	// 4. Template Engine Setup
	engine := html.New("./views", ".html")

	// Enable template reloading in development (set to false in production)
	engine.Reload(true)

	// Add custom template functions
	engine.AddFunc("formatPrice", func(price float64) string {
		return formatPrice(price)
	})
	engine.AddFunc("formatDate", func(date string) string {
		return formatDate(date)
	})
	engine.AddFunc("multiply", func(a, b int) int {
		return a * b
	})
	engine.AddFunc("discountedPrice", func(price float64, discount int) float64 {
		return price * (1 - float64(discount)/100)
	})
	engine.AddFunc("isOdd", func(i int) bool {
		return i%2 != 0
	})

	// 5. Fiber App with Template Engine
	app := fiber.New(fiber.Config{
		Views:       engine,
		ViewsLayout: "layouts/base",
		BodyLimit:   50 * 1024 * 1024, // 50MB
	})

	// 6. Static Files
	app.Static("/static", "./static", fiber.Static{
		Compress:      true,
		CacheDuration: -1, // Disable cache in development
	})

	// 7. Global Middleware
	app.Use(logger.New())
	app.Use(helmet.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: config.ClientURL + ", http://localhost:5000, http://localhost:3000",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, x-arf-secure-token",
		AllowMethods: "GET,POST,HEAD,PUT,DELETE,PATCH",
	}))

	// 8. View Routes (Frontend Pages)
	routes.SetupViewRoutes(app)

	// 9. API Routes
	routes.SetupRoutes(app)

	// 10. Start
	log.Println("🚀 Server starting on port " + config.Port)
	log.Println("📁 Static files: /static")
	log.Println("🖥️  Frontend views enabled")
	log.Fatal(app.Listen(":" + config.Port))
}

// Helper function to format price in Indonesian Rupiah
func formatPrice(price float64) string {
	formatted := ""
	priceStr := fmt.Sprintf("%.0f", price)
	for i, c := range priceStr {
		if i > 0 && (len(priceStr)-i)%3 == 0 {
			formatted += "."
		}
		formatted += string(c)
	}
	return "Rp " + formatted
}

// Helper function to format date
func formatDate(dateStr string) string {
	// Simple pass-through for now
	return dateStr
}

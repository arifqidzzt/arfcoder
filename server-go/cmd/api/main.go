package main

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/handlers"
	"arfcoder-go/internal/routes"
	"arfcoder-go/internal/services/whatsapp"
	"log"
	"strings"
	"fmt"
	"time"
	"encoding/json"

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

	// 4. Template Engine
	engine := html.New("./internal/templates", ".html")
	engine.AddFunc("formatNumber", func(n float64) string {
		s := fmt.Sprintf("%.0f", n)
		var result []string
		for i := len(s); i > 0; i -= 3 {
			start := i - 3
			if start < 0 { start = 0 }
			result = append([]string{s[start:i]}, result...)
		}
		return strings.Join(result, ".")
	})
	engine.AddFunc("calcDiscount", func(price float64, discount float64, qty int) float64 {
		return (price * (1 - discount/100)) * float64(qty)
	})
	engine.AddFunc("formatDateNow", func() string {
		return time.Now().Format("02 Jan 2006")
	})
	engine.AddFunc("json", func(v interface{}) string {
		b, _ := json.Marshal(v)
		return string(b)
	})

	// 5. Fiber App
	app := fiber.New(fiber.Config{
		BodyLimit: 50 * 1024 * 1024, // 50MB
		Views: engine,
		ViewsLayout: "layouts/base",
	})

	// 6. Global Middleware
	app.Use(logger.New())
	app.Use(helmet.New(helmet.Config{
		ContentSecurityPolicy: "default-src 'self' https: 'unsafe-inline' 'unsafe-eval'; img-src 'self' data: https:; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://app.sandbox.midtrans.com https://app.midtrans.com;",
	}))
	app.Static("/static", "./static") // Serve static files
	app.Use(cors.New(cors.Config{
		AllowOrigins: config.ClientURL,
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, x-arf-secure-token",
		AllowMethods: "GET,POST,HEAD,PUT,DELETE,PATCH",
	}))

	// 7. Routes
	routes.SetupRoutes(app)

	// 8. Start
	log.Fatal(app.Listen(":" + config.Port))
}

package main

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/handlers"
	"arfcoder-go/internal/routes"
	"arfcoder-go/internal/services/whatsapp"
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

	// 4. Fiber App with Template Engine
	engine := html.New("./web/templates", ".html")
	
	app := fiber.New(fiber.Config{
		BodyLimit: 50 * 1024 * 1024, // 50MB
		Views:     engine,
	})

	// 5. Global Middleware
	app.Use(logger.New())
	app.Use(helmet.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: config.ClientURL,
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, x-arf-secure-token",
		AllowMethods: "GET,POST,HEAD,PUT,DELETE,PATCH",
	}))

	// Static Files
	app.Static("/static", "./web/static")

	// 6. Routes
	routes.SetupWebRoutes(app) // Web Routes (HTML)
	routes.SetupRoutes(app)    // API Routes (JSON)

	// 7. Start
	log.Fatal(app.Listen(":" + config.Port))
}

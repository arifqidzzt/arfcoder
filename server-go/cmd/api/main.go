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
)

func main() {
	// 1. Config
	config.LoadConfig()

	// 2. Database
	database.Connect()

	// Auto Migrate (Ensure schema matches)
	// database.DB.AutoMigrate(&models.User{}, &models.Order{}, &models.Product{}, &models.Otp{}, &models.ActivityLog{})
	// Note: AutoMigrate is good for dev, but use with caution.
	// Since we are migrating, we assume the DB schema already exists from Prisma.
	// We just need to ensure GORM models map correctly.

	// 3. Init Services
	handlers.InitMidtrans()
	handlers.InitMidtransCoreApi()

	go func() {
		if err := whatsapp.Connect(); err != nil {
			log.Println("Failed to start WhatsApp Service:", err)
		}
	}()

	// 4. Fiber App
	app := fiber.New(fiber.Config{
		BodyLimit: 50 * 1024 * 1024, // 50MB
	})

	// 5. Global Middleware
	app.Use(logger.New())
	app.Use(helmet.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: config.ClientURL,
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, x-arf-secure-token",
		AllowMethods: "GET,POST,HEAD,PUT,DELETE,PATCH",
	}))

	// 6. Routes
	routes.SetupRoutes(app)

	// 7. Start
	log.Fatal(app.Listen(":" + config.Port))
}

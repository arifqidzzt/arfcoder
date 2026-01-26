package main

import (
	"log"
	"os"

	"github.com/arifqi/arfcoder-server/internal/config"
	"github.com/arifqi/arfcoder-server/internal/routes"
	"github.com/arifqi/arfcoder-server/pkg/services"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/adaptor/v2"
)

func main() {
	// 1. Connect Database
	config.ConnectDB()

	// 2. Init Services
	go services.InitWhatsApp() // Run in background
	socketServer := services.InitSocket()

	// 3. Setup Fiber App
	app := fiber.New(fiber.Config{
		AppName: "ArfCoder Go Server v1.0",
	})

	// 4. Middlewares
	app.Use(logger.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*", // Allow all for now to fix CORS issues with socket
		AllowHeaders: "Origin, Content-Type, Accept, Authorization, x-arf-secure-token",
	}))

	// 5. Setup Routes
	routes.SetupRoutes(app)

	// Socket.io Route
	app.All("/socket.io/*", adaptor.HTTPHandler(socketServer))

	// Health Check
	app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("🚀 ArfCoder Go Backend is Running!")
	})

	// 6. Start Server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080" // Use different port for dev
	}
	
	log.Printf("Server listening on port %s", port)
	log.Fatal(app.Listen(":" + port))
}

package routes

import (
	"github.com/arifqi/arfcoder-server/internal/handlers"
	"github.com/arifqi/arfcoder-server/internal/middleware"
	"github.com/gofiber/fiber/v2"
	jwtware "github.com/gofiber/contrib/jwt"
	"os"
)

func SetupRoutes(app *fiber.App) {
	api := app.Group("/api")

	// Global Security Header Check
	api.Use(middleware.SecureHeaders)

	// Auth (Public)
	auth := api.Group("/auth")
	auth.Post("/login", handlers.Login)
	auth.Post("/register", handlers.Register)
	auth.Post("/verify-otp", handlers.VerifyOtp)
	auth.Post("/resend-otp", handlers.ResendOtp)
	auth.Post("/google", handlers.GoogleLogin)
	auth.Post("/forgot-password", handlers.ForgotPassword)
	auth.Post("/reset-password", handlers.ResetPassword)

	// Webhook
	api.Post("/midtrans-webhook", handlers.MidtransWebhook)

	// Public Data
	api.Get("/products", handlers.GetAllProducts)
	api.Get("/products/:id", handlers.GetProduct)
	api.Get("/products/services", handlers.GetServices)

	// --- PROTECTED ROUTES (JWT) ---
	app.Use(jwtware.New(jwtware.Config{
		SigningKey: jwtware.SigningKey{Key: []byte(os.Getenv("JWT_SECRET"))},
	}))

	// User Profile
	api.Get("/auth/me", handlers.GetMe) // Legacy path support
	user := api.Group("/user")
	user.Get("/profile", handlers.GetMe)
	user.Put("/profile", handlers.UpdateProfile)
	user.Put("/password", handlers.UpdatePassword)

	// Orders
	api.Post("/orders", handlers.CreateOrder)
	api.Get("/orders/my", handlers.GetMyOrders)

	// Admin
	admin := api.Group("/admin")
	admin.Get("/stats", handlers.GetDashboardStats)
	
	// Admin Users
	admin.Get("/users", handlers.GetAllUsers)
	admin.Delete("/users/:id", handlers.DeleteUser)
	admin.Get("/chat/:userId", handlers.GetUserChatHistory)

	// Admin Services
	admin.Get("/services", handlers.GetServices)
	admin.Post("/services", handlers.UpsertService)
	admin.Delete("/services/:id", handlers.DeleteService)

	// Admin WA
	admin.Post("/wa/start", handlers.StartWA)
	admin.Post("/wa/logout", handlers.LogoutWA)
	admin.Get("/wa/status", handlers.GetWAStatus)
}

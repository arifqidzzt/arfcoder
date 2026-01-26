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
	api.Get("/auth/me", handlers.GetMe)
	user := api.Group("/user")
	user.Get("/profile", handlers.GetMe)
	user.Put("/profile", handlers.UpdateProfile)
	user.Put("/password", handlers.UpdatePassword)

	// Phone & Email Change
	user.Post("/phone/request", handlers.RequestPhoneChange)
	user.Post("/phone/verify-old", handlers.VerifyOldPhone)
	user.Post("/phone/request-new", handlers.RequestNewPhone)
	user.Post("/phone/verify-new", handlers.VerifyNewPhone)
	user.Post("/email/request", handlers.RequestEmailChange)
	user.Post("/email/verify-old", handlers.VerifyOldEmail)
	user.Post("/email/verify-new", handlers.VerifyNewEmail)

	// Orders (User)
	api.Post("/orders", handlers.CreateOrder)
	api.Get("/orders/my", handlers.GetMyOrders)
	api.Get("/orders/:id", handlers.GetOrder) // Detail Order
	api.Post("/orders/:id/pay", handlers.PayOrder)
	api.Put("/orders/:id/cancel", handlers.CancelOrder)
	api.Post("/orders/:id/refund", handlers.RequestRefund)

	// Admin
	admin := api.Group("/admin")
	admin.Get("/stats", handlers.GetDashboardStats)
	
	// Admin Orders
	admin.Get("/orders", handlers.GetAllOrders)
	admin.Put("/orders/:id", handlers.UpdateOrder)
	admin.Put("/orders/:id/delivery", handlers.UpdateOrder) // Re-use update logic

	// Admin Users
	admin.Get("/users", handlers.GetAllUsers)
	admin.Delete("/users/:id", handlers.DeleteUser)
	admin.Get("/chat/:userId", handlers.GetUserChatHistory)

	// Admin Products
	prod := api.Group("/products") // Protected part of products
	prod.Post("/", handlers.CreateProduct)
	prod.Put("/:id", handlers.UpdateProduct)
	prod.Delete("/:id", handlers.DeleteProduct)

	// Admin Services
	admin.Get("/services", handlers.GetServices)
	admin.Post("/services", handlers.UpsertService)
	admin.Delete("/services/:id", handlers.DeleteService)

	// Admin WA
	admin.Post("/wa/start", handlers.StartWA)
	admin.Post("/wa/logout", handlers.LogoutWA)
	admin.Get("/wa/status", handlers.GetWAStatus)
}
package routes

import (
	"arfcoder-go/internal/handlers"
	"arfcoder-go/internal/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	api := app.Group("/api", middleware.RateLimitAPI())

	// --- AUTH ---
	auth := api.Group("/auth", middleware.RateLimitAuth(), middleware.SecureMiddleware)
	auth.Post("/register", handlers.Register)
	auth.Post("/login", handlers.Login)
	auth.Post("/verify-otp", handlers.VerifyOtp)
	auth.Post("/verify-login-otp", handlers.VerifyLoginOtp) // FIX: Added Route
	auth.Post("/resend-otp", handlers.ResendOtp)
	auth.Post("/google", handlers.GoogleLogin)
	auth.Post("/forgot-password", handlers.ForgotPassword)
	auth.Post("/reset-password", handlers.ResetPassword)

	// 2FA Routes
	auth.Post("/2fa/verify", handlers.VerifyLogin2FA)
	auth.Post("/2fa/send", handlers.SendBackupOtp)
	auth.Post("/2fa/setup", middleware.AuthMiddleware, handlers.SetupTwoFactor)
	auth.Post("/2fa/enable", middleware.AuthMiddleware, handlers.EnableTwoFactor)

	// --- PRODUCTS ---
	products := api.Group("/products", middleware.SecureMiddleware)
	products.Get("/services", handlers.GetPublicServices)
	products.Get("/", handlers.GetAllProducts)
	products.Get("/:id", handlers.GetProductById)
	// Admin Product CRUD
	products.Post("/", middleware.AuthMiddleware, middleware.AdminOnly, handlers.CreateProduct)
	products.Put("/:id", middleware.AuthMiddleware, middleware.AdminOnly, handlers.UpdateProduct)
	products.Delete("/:id", middleware.AuthMiddleware, middleware.AdminOnly, handlers.DeleteProduct)

	// --- ORDERS ---
	orders := api.Group("/orders", middleware.SecureMiddleware)
	orders.Post("/", middleware.AuthMiddleware, handlers.CreateOrder)
	orders.Post("/webhook", handlers.HandleMidtransWebhook)
	orders.Get("/my", middleware.AuthMiddleware, handlers.GetMyOrders)
	orders.Get("/:id", middleware.AuthMiddleware, handlers.GetOrderById)
	// Order Actions
	orders.Put("/:id/cancel", middleware.AuthMiddleware, handlers.CancelOrder)
	orders.Post("/:id/refund", middleware.AuthMiddleware, handlers.RequestRefund)
	orders.Post("/:id/pay", middleware.AuthMiddleware, handlers.RegeneratePaymentToken)

	// Core API Payment Routes
	orders.Post("/:id/charge", middleware.AuthMiddleware, handlers.CreateCoreApiCharge)
	orders.Get("/:id/payment-status", middleware.AuthMiddleware, handlers.GetPaymentStatus)
	orders.Post("/:id/regenerate-payment", middleware.AuthMiddleware, handlers.RegenerateCoreApiPayment)

	// --- VOUCHERS ---
	vouchers := api.Group("/vouchers", middleware.SecureMiddleware)
	vouchers.Get("/", handlers.GetAllVouchers)
	vouchers.Post("/check", handlers.CheckVoucher)
	vouchers.Post("/", middleware.AuthMiddleware, middleware.AdminOnly, handlers.CreateVoucher)
	vouchers.Delete("/:id", middleware.AuthMiddleware, middleware.AdminOnly, handlers.DeleteVoucher)

	// --- FLASH SALES ---
	fs := api.Group("/flash-sales", middleware.SecureMiddleware)
	fs.Get("/active", handlers.GetActiveFlashSales)
	fs.Get("/", middleware.AuthMiddleware, middleware.AdminOnly, handlers.GetAllFlashSales) // FIX: Added
	fs.Post("/", middleware.AuthMiddleware, middleware.AdminOnly, handlers.CreateFlashSale)
	fs.Delete("/:id", middleware.AuthMiddleware, middleware.AdminOnly, handlers.DeleteFlashSale)

	// --- REVIEWS ---
	reviews := api.Group("/reviews", middleware.SecureMiddleware)
	reviews.Get("/:productId", handlers.GetProductReviews)
	reviews.Post("/", middleware.AuthMiddleware, handlers.CreateReview)

	// --- USER PROFILE ---
	user := api.Group("/user", middleware.SecureMiddleware, middleware.AuthMiddleware)
	user.Get("/profile", handlers.GetProfile)
	user.Put("/profile", handlers.UpdateProfile)
	user.Put("/change-password", handlers.ChangePassword)
	user.Put("/phone-direct", handlers.UpdatePhoneDirect)
	// Flows
	user.Post("/email/request", handlers.RequestEmailChange)
	user.Post("/email/verify-old", handlers.VerifyOldEmail)
	user.Post("/email/verify-new", handlers.VerifyNewEmail)
	user.Post("/phone/request", handlers.RequestPhoneChange)
	user.Post("/phone/verify-old", handlers.VerifyOldPhone)
	user.Post("/phone/request-new", handlers.RequestNewPhoneOtp)
	user.Post("/phone/verify-new", handlers.VerifyNewPhone)

	// --- CART ---
	cart := user.Group("/cart")
	cart.Get("/", handlers.GetCart)
	cart.Post("/", handlers.AddToCart)
	cart.Put("/:productId", handlers.UpdateCartQuantity)
	cart.Delete("/:productId", handlers.RemoveFromCart)

	// --- CHAT ---
	user.Post("/chat/send", handlers.SendMessage)
	user.Get("/chat/history/:userId", handlers.GetUserChatHistory)

	// --- ADMIN DASHBOARD ---
	admin := api.Group("/admin", middleware.SecureMiddleware, middleware.AuthMiddleware, middleware.AdminOnly)
	admin.Get("/stats", handlers.GetDashboardStats)
	admin.Get("/orders", handlers.GetAllOrders)
	admin.Put("/orders/:id", handlers.UpdateOrderStatus)
	admin.Put("/orders/:id/delivery", handlers.UpdateDeliveryInfo)
	admin.Get("/users", handlers.GetAllUsers)
	admin.Delete("/users/:id", handlers.DeleteUser)

	admin.Get("/chat/:userId", handlers.GetUserChatHistory)

	admin.Get("/services", handlers.GetAdminServices)
	admin.Post("/services", handlers.UpsertService)
	admin.Delete("/services/:id", handlers.DeleteService)

	admin.Get("/wa/status", handlers.GetWaStatus)
	admin.Post("/wa/logout", handlers.LogoutWa)
	admin.Post("/wa/start", handlers.StartWa)

	admin.Post("/timeline/:id", handlers.UpdateOrderTimeline)
	admin.Delete("/timeline/:id", handlers.DeleteOrderTimeline)

	// --- LOGS ---
	api.Get("/logs", middleware.SecureMiddleware, middleware.AuthMiddleware, middleware.AdminOnly, handlers.GetLogs)
}

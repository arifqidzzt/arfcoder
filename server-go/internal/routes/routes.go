package routes

import (
	"arfcoder-go/internal/handlers"
	"arfcoder-go/internal/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupRoutes(app *fiber.App) {
	// --- PAGES (Frontend) ---
	app.Get("/", handlers.RenderHome)
	app.Get("/login", handlers.RenderLogin)
	app.Get("/register", handlers.RenderRegister)
	app.Get("/forgot-password", handlers.RenderForgotPassword)
	app.Get("/reset-password", handlers.RenderResetPassword)
	app.Get("/verify-otp", handlers.RenderVerifyOtp)
	app.Get("/verify-admin", handlers.RenderVerifyAdmin)
	app.Get("/products", handlers.RenderProducts)
	app.Get("/products/:id", handlers.RenderProductDetail)
	app.Get("/services", handlers.RenderPublicServices)
	app.Get("/contact", handlers.RenderContact)
	app.Get("/cart", handlers.RenderCart)
	app.Get("/checkout", handlers.RenderCheckout)
	app.Get("/orders", handlers.RenderOrders)
	app.Get("/orders/:id", handlers.RenderOrderDetail)
	app.Get("/profile", handlers.RenderProfile)
	app.Get("/profile/security", handlers.RenderProfileSecurity)
	app.Get("/faq", func(c *fiber.Ctx) error { return c.Render("pages/faq", fiber.Map{"Title": "FAQ"}) })
	app.Get("/privacy", func(c *fiber.Ctx) error { return c.Render("pages/legal", fiber.Map{"Title": "Kebijakan Privasi", "Content": "Isi kebijakan privasi Anda di sini."}) })
	app.Get("/terms", func(c *fiber.Ctx) error { return c.Render("pages/legal", fiber.Map{"Title": "Syarat & Ketentuan", "Content": "Isi syarat dan ketentuan Anda di sini."}) })
	app.Get("/refund-policy", func(c *fiber.Ctx) error { return c.Render("pages/legal", fiber.Map{"Title": "Kebijakan Refund", "Content": "Isi kebijakan refund Anda di sini."}) })
	app.Post("/logout", handlers.Logout)

	api := app.Group("/api", middleware.RateLimitAPI())

	// --- ADMIN DASHBOARD ---
	admin := app.Group("/admin", middleware.AuthMiddleware, middleware.AdminOnly)
	admin.Get("/", handlers.RenderAdminDashboard)
	admin.Get("/products", handlers.RenderAdminProducts)
	admin.Get("/products/:id", handlers.RenderAdminProductForm)
	admin.Get("/orders", handlers.RenderAdminOrders)
	admin.Get("/orders/:id", handlers.RenderAdminOrderManage)
	admin.Get("/users", handlers.RenderAdminUsers)
	admin.Get("/vouchers", handlers.RenderAdminVouchers)
	admin.Get("/flash-sale", handlers.RenderAdminFlashSales)
	admin.Get("/services", handlers.RenderAdminServices)
	admin.Get("/chat", handlers.RenderAdminChat)
	admin.Get("/whatsapp", handlers.RenderAdminWhatsapp)
	admin.Get("/logs", handlers.RenderAdminLogs)

	// --- PUBLIC WEBHOOK ---
	api.Post("/midtrans-webhook", handlers.HandleMidtransWebhook)

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
	orders.Get("/my", middleware.AuthMiddleware, handlers.GetMyOrders)
	orders.Get("/:id", middleware.AuthMiddleware, handlers.GetOrderById)
	// Order Actions
	orders.Put("/:id/cancel", middleware.AuthMiddleware, handlers.CancelOrder)
	orders.Post("/:id/refund", middleware.AuthMiddleware, handlers.RequestRefund)
	orders.Post("/:id/pay", middleware.AuthMiddleware, handlers.RegeneratePaymentToken)

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
	adminAPI := api.Group("/admin", middleware.SecureMiddleware, middleware.AuthMiddleware, middleware.AdminOnly)
	adminAPI.Get("/stats", handlers.GetDashboardStats)
	adminAPI.Get("/orders", handlers.GetAllOrders)
	adminAPI.Put("/orders/:id", handlers.UpdateOrderStatus)
	adminAPI.Put("/orders/:id/delivery", handlers.UpdateDeliveryInfo)
	adminAPI.Get("/users", handlers.GetAllUsers)
	adminAPI.Delete("/users/:id", handlers.DeleteUser)
	
	adminAPI.Get("/chat/:userId", handlers.GetUserChatHistory)

	adminAPI.Get("/services", handlers.GetAdminServices)
	adminAPI.Post("/services", handlers.UpsertService)
	adminAPI.Delete("/services/:id", handlers.DeleteService)
	
	adminAPI.Get("/wa/status", handlers.GetWaStatus)
	adminAPI.Post("/wa/logout", handlers.LogoutWa)
	adminAPI.Post("/wa/start", handlers.StartWa)
	
	adminAPI.Post("/timeline/:id", handlers.UpdateOrderTimeline)
	adminAPI.Delete("/timeline/:id", handlers.DeleteOrderTimeline)
	
	// --- LOGS ---
	api.Get("/logs", middleware.SecureMiddleware, middleware.AuthMiddleware, middleware.AdminOnly, handlers.GetLogs)
}
package routes

import (
	"arfcoder-go/internal/handlers"
	"arfcoder-go/internal/middleware"

	"github.com/gofiber/fiber/v2"
)

func SetupWebRoutes(app *fiber.App) {
	// Static files are served from main.go setup usually, or here
	// app.Static("/static", "./web/static")

	// Web Routes
	web := app.Group("/", middleware.SoftWebAuth)
	
	web.Get("/", handlers.WebHome)
    web.Get("/auth/login", handlers.WebLogin)
    web.Get("/auth/register", handlers.WebRegister)
    web.Get("/products", handlers.WebProducts)
    web.Get("/products/:id", handlers.WebProductDetail)
    web.Get("/services", handlers.WebServices)
    web.Get("/contact", handlers.WebContact)
    
    // Protected Routes
    web.Get("/cart", middleware.RequireWebAuth, handlers.WebCart)
    web.Get("/checkout", middleware.RequireWebAuth, handlers.WebCheckout)
    web.Get("/orders/my", middleware.RequireWebAuth, handlers.WebMyOrders)
    web.Get("/orders/:id", middleware.RequireWebAuth, handlers.WebOrderDetail)
    web.Get("/user/profile", middleware.RequireWebAuth, handlers.WebProfile) // We will implement login page next
    
    // Auth Actions (HTMX targets or Form Posts)
    // We can reuse API or create specific web auth handlers if response needs to be HTML
}

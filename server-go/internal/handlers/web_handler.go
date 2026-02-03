package handlers

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"time"

	"github.com/gofiber/fiber/v2"
)

func WebHome(c *fiber.Ctx) error {
	// 1. Get User from Context (set by SoftWebAuth)
	var user *utils.JWTClaims
	if u := c.Locals("user"); u != nil {
		user = u.(*utils.JWTClaims)
	}

	// 2. Fetch Featured Products (Limit 3)
	var products []models.Product
	if err := database.DB.Order("\"createdAt\" desc").Limit(3).Find(&products).Error; err != nil {
		// Log error but don't fail page
		// log.Println("Error fetching products:", err)
	}

	// 3. Fetch Active Flash Sales
	var flashSales []models.FlashSale
	if err := database.DB.Preload("Product").Where("\"isActive\" = ? AND \"endTime\" > ?", true, time.Now()).Find(&flashSales).Error; err != nil {
		// log.Println("Error fetching flash sales:", err)
	}

	// 4. Render Template
	return c.Render("pages/home", fiber.Map{
		"User":       user,
		"Products":   products,
		"FlashSales": flashSales,
	}, "layouts/base")
}

func WebLogin(c *fiber.Ctx) error {
	if c.Locals("user") != nil {
		return c.Redirect("/")
	}
	return c.Render("pages/login", fiber.Map{
		"GoogleClientID": config.GoogleClientID,
	}, "layouts/base")
}

func WebRegister(c *fiber.Ctx) error {
	if c.Locals("user") != nil {
		return c.Redirect("/")
	}
	return c.Render("pages/register", fiber.Map{
		"GoogleClientID": config.GoogleClientID,
	}, "layouts/base")
}

func WebProductDetail(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := database.DB.Preload("Category").First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).SendString("Product not found") // Simple 404 for now
	}

	var reviews []models.Review
	database.DB.Preload("User").Where("\"productId\" = ? AND \"isVisible\" = ?", id, true).Order("created_at desc").Find(&reviews)

	finalPrice := product.Price
	if product.Discount > 0 {
		finalPrice = product.Price * (1 - product.Discount/100)
	}
	
	// Get Current User
	var user *utils.JWTClaims
	if u := c.Locals("user"); u != nil {
		user = u.(*utils.JWTClaims)
	}

	return c.Render("pages/product_detail", fiber.Map{
		"User": user,
		"Product": product,
		"Reviews": reviews,
		"FinalPrice": finalPrice,
	}, "layouts/base")
}

func WebCart(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	
	var cartItems []models.CartItem
	database.DB.Preload("Product").Where("\"userId\" = ?", user.UserID).Find(&cartItems)

	return c.Render("pages/cart", fiber.Map{
		"User": user,
		"CartItems": cartItems,
	}, "layouts/base")
}

func WebCheckout(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	
	var cartItems []models.CartItem
	if err := database.DB.Preload("Product").Where("\"userId\" = ?", user.UserID).Find(&cartItems).Error; err != nil {
		return c.Redirect("/cart")
	}

	if len(cartItems) == 0 {
		return c.Redirect("/cart")
	}

	total := 0.0
	for _, item := range cartItems {
		price := item.Product.Price
		if item.Product.Discount > 0 {
			price = price * (1 - item.Product.Discount/100)
		}
		total += price * float64(item.Quantity)
	}

	return c.Render("pages/checkout", fiber.Map{
		"User":              user,
		"CartItems":         cartItems,
		"Total":             total,
		"MidtransClientKey": config.MidtransClientKey,
		"MidtransIsProd":    config.MidtransIsProd,
	}, "layouts/base")
}

func WebMyOrders(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	
	var orders []models.Order
	database.DB.Preload("Items.Product").Where("\"userId\" = ?", user.UserID).Order("created_at desc").Find(&orders)

	return c.Render("pages/orders", fiber.Map{
		"User":   user,
		"Orders": orders,
		"MidtransClientKey": config.MidtransClientKey,
		"MidtransIsProd":    config.MidtransIsProd,
	}, "layouts/base")
}

func WebOrderDetail(c *fiber.Ctx) error {
	id := c.Params("id")
	user := c.Locals("user").(*utils.JWTClaims)
	
	var order models.Order
	if err := database.DB.Preload("Items.Product").Preload("Timeline").Where("id = ? AND \"userId\" = ?", id, user.UserID).First(&order).Error; err != nil {
		return c.Status(404).Render("pages/404", fiber.Map{}, "layouts/base") // Need to make 404 page later or just redirect
	}

	return c.Render("pages/order_detail", fiber.Map{
		"User":              user,
		"Order":             order,
		"MidtransClientKey": config.MidtransClientKey,
		"MidtransIsProd":    config.MidtransIsProd,
	}, "layouts/base")
}

func WebProducts(c *fiber.Ctx) error {
	q := c.Query("q")
	cat := c.Query("cat")

	db := database.DB.Preload("Category").Model(&models.Product{})

	if q != "" {
		db = db.Where("name ILIKE ?", "%"+q+"%")
	}
	if cat != "" && cat != "All" {
		db = db.Joins("JOIN \"Category\" ON \"Category\".id = \"Product\".\"categoryId\"").Where("\"Category\".name = ?", cat)
	}

	var products []models.Product
	db.Find(&products)

	// Fetch Categories for Filter
	var categories []models.Category
	database.DB.Find(&categories)

	// Get User
	var user *utils.JWTClaims
	if u := c.Locals("user"); u != nil {
		user = u.(*utils.JWTClaims)
	}

	return c.Render("pages/products", fiber.Map{
		"User":       user,
		"Products":   products,
		"Categories": categories,
		"Query":      q,
		"ActiveCat":  cat,
	}, "layouts/base")
}

func WebProfile(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	
	// Fetch full user data to be sure
	var userData models.User
	if err := database.DB.First(&userData, "id = ?", user.UserID).Error; err != nil {
		return c.Redirect("/auth/login")
	}

	return c.Render("pages/profile", fiber.Map{
		"User": userData, // Pass full user struct
	}, "layouts/base")
}

func WebServices(c *fiber.Ctx) error {
	var services []models.Service
	database.DB.Find(&services)

	// Get User
	var user *utils.JWTClaims
	if u := c.Locals("user"); u != nil {
		user = u.(*utils.JWTClaims)
	}

	return c.Render("pages/services", fiber.Map{
		"User":     user,
		"Services": services,
	}, "layouts/base")
}

func WebContact(c *fiber.Ctx) error {
	// Get User
	var user *utils.JWTClaims
	if u := c.Locals("user"); u != nil {
		user = u.(*utils.JWTClaims)
	}
	return c.Render("pages/contact", fiber.Map{
		"User": user,
	}, "layouts/base")
}

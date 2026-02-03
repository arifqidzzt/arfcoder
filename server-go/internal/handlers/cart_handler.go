package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"github.com/gofiber/fiber/v2"
)

func getCartData(userID string) fiber.Map {
	var items []models.CartItem
	database.DB.Preload("Product").Where("\"userId\" = ?", userID).Find(&items)
	
	total := 0.0
	for _, item := range items {
		price := item.Product.Price * (1 - item.Product.Discount/100)
		total += price * float64(item.Quantity)
	}

	return fiber.Map{
		"CartItems": items,
		"Total":     total,
	}
}

func GetCart(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	data := getCartData(user.UserID)
	return c.JSON(data["CartItems"])
}

func AddToCart(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	var req struct {
		ProductID string `json:"productId"`
		Quantity  int    `json:"quantity"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var item models.CartItem
	result := database.DB.Where("\"userId\" = ? AND \"productId\" = ?", user.UserID, req.ProductID).First(&item)

	if result.Error == nil {
		item.Quantity += req.Quantity
		database.DB.Save(&item)
	} else {
		item = models.CartItem{
			UserID:    user.UserID,
			ProductID: req.ProductID,
			Quantity:  req.Quantity,
		}
		database.DB.Create(&item)
	}

	if c.Get("HX-Request") != "" {
		return c.Render("partials/cart_items", getCartData(user.UserID), "")
	}

	return c.JSON(item)
}

func UpdateCartQuantity(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	productId := c.Params("productId")
	var req struct {
		Quantity int `json:"quantity"`
	}
	c.BodyParser(&req)

	database.DB.Model(&models.CartItem{}).Where("\"userId\" = ? AND \"productId\" = ?", user.UserID, productId).Updates(models.CartItem{Quantity: req.Quantity})
	
	if c.Get("HX-Request") != "" {
		// Return the whole grid container to refresh items AND summary
		data := getCartData(user.UserID)
		return c.Render("partials/cart_container", data, "")
	}

	return c.JSON(fiber.Map{"message": "Quantity updated"})
}

func RemoveFromCart(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	productId := c.Params("productId")
	database.DB.Delete(&models.CartItem{}, "\"userId\" = ? AND \"productId\" = ?", user.UserID, productId)
	
	if c.Get("HX-Request") != "" {
		return c.Render("partials/cart_container", getCartData(user.UserID), "")
	}

	return c.JSON(fiber.Map{"message": "Item removed"})
}

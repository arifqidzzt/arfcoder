package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"github.com/gofiber/fiber/v2"
)

func GetCart(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	var items []models.CartItem
	database.DB.Preload("Product").Where("\"userId\" = ?", user.UserID).Find(&items)
	return c.JSON(items)
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

	return c.JSON(item)
}

func UpdateCartQuantity(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	productId := c.Params("productId")
	var req struct {
		Quantity int `json:"quantity"`
	}
	c.BodyParser(&req)

	database.DB.Model(&models.CartItem{}).Where("\"userId\" = ? AND \"productId\" = ?", user.UserID, productId).Update("quantity", req.Quantity)
	return c.JSON(fiber.Map{"message": "Quantity updated"})
}

func RemoveFromCart(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	productId := c.Params("productId")
	database.DB.Delete(&models.CartItem{}, "\"userId\" = ? AND \"productId\" = ?", user.UserID, productId)
	return c.JSON(fiber.Map{"message": "Item removed"})
}

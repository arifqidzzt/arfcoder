package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"time"

	"github.com/gofiber/fiber/v2"
)

func GetMyOrders(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	
	var orders []models.Order
	database.DB.Preload("Items.Product").
		Where("user_id = ?", userClaims.UserID).
		Order("created_at desc").
		Find(&orders)
		
	return c.JSON(orders)
}
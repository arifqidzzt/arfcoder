package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/coreapi"
	"github.com/midtrans/midtrans-go/snap"
	"gorm.io/gorm"
)

// Cancel Order (Return Stock)
func CancelOrder(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	orderId := c.Params("id")

	var order models.Order
	if err := database.DB.Preload("Items").Where("id = ? AND \"userId\" = ?", orderId, userClaims.UserID).First(&order).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	if order.Status != models.OrderStatusPending {
		return c.Status(400).JSON(fiber.Map{"message": "Cannot cancel processed order"})
	}

	// Cancel in Midtrans
	_, _ = CoreClient.CancelTransaction(order.ID)

	// Transaction for Atomicity
	tx := database.DB.Begin()

	// 1. Update Status
	if err := tx.Model(&order).Update("status", models.OrderStatusCancelled).Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"message": "Failed to cancel"})
	}

	// 2. Return Stock
	for _, item := range order.Items {
		if err := tx.Model(&models.Product{}).Where("id = ?", item.ProductID).
			Update("stock", gorm.Expr("stock + ?", item.Quantity)).Error; err != nil {
			tx.Rollback()
			return c.Status(500).JSON(fiber.Map{"message": "Failed to restore stock"})
		}
	}

	tx.Commit()
	return c.JSON(fiber.Map{"message": "Order cancelled"})
}

// Refund Request
func RequestRefund(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	orderId := c.Params("id")
	
	type Req struct {
		Reason  string `json:"reason"`
		Account string `json:"account"`
	}
	var req Req
	c.BodyParser(&req)

	var order models.Order
	if err := database.DB.Where("id = ? AND \"userId\" = ?", orderId, userClaims.UserID).First(&order).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	if order.Status != models.OrderStatusPaid {
		return c.Status(400).JSON(fiber.Map{"message": "Only paid orders can be refunded"})
	}

	database.DB.Model(&order).Updates(models.Order{
		Status:        models.OrderStatusRefundRequested,
		RefundReason:  req.Reason,
		RefundAccount: req.Account,
	})

	return c.JSON(fiber.Map{"message": "Refund requested"})
}
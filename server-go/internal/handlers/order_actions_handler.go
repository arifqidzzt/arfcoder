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

// Regenerate Payment Token (Smart Logic)
func RegeneratePaymentToken(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	orderId := c.Params("id")

	var order models.Order
	if err := database.DB.Where("id = ? AND \"userId\" = ?", orderId, userClaims.UserID).First(&order).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	if order.Status != models.OrderStatusPending {
		return c.Status(400).JSON(fiber.Map{"message": "Order already paid/cancelled"})
	}

	// 1. Expiration Logic
	timeSinceCreated := time.Since(order.CreatedAt)
	if timeSinceCreated > 24*time.Hour {
		database.DB.Model(&order).Update("status", models.OrderStatusCancelled)
		return c.Status(400).JSON(fiber.Map{"message": "Order expired (> 24h)"})
	}

	// 2. Fetch Payment Settings
	var paymentSetting models.PaymentSetting
	database.DB.First(&paymentSetting)

	// Generate New ID (Midtrans requires unique order_id for new transactions)
	newTxId := fmt.Sprintf("%s-%d", order.ID, time.Now().Unix())

	if paymentSetting.Mode == models.MidtransModeCore {
		if order.PaymentType == "" {
			return c.Status(400).JSON(fiber.Map{"message": "Original order has no payment type"})
		}

		coreReq := &coreapi.ChargeReq{
			PaymentType: coreapi.CoreapiPaymentType(order.PaymentType),
			TransactionDetails: midtrans.TransactionDetails{
				OrderID:  newTxId,
				GrossAmt: int64(order.TotalAmount),
			},
			CustomerDetails: &midtrans.CustomerDetails{
				FName: userClaims.UserID,
			},
		}

		// Handle specific payment methods
		switch order.PaymentType {
		case string(coreapi.PaymentTypeBankTransfer):
			coreReq.BankTransfer = &coreapi.BankTransferDetails{
				Bank: midtrans.Bank(order.PaymentMethod),
			}
		case string(coreapi.PaymentTypeEChannel):
			coreReq.EChannel = &coreapi.EChannelDetail{
				BillInfo1: "Payment for Order",
				BillInfo2: order.InvoiceNumber,
			}
		case string(coreapi.PaymentTypeGopay):
			coreReq.Gopay = &coreapi.GopayDetails{
				EnableCallback: true,
			}
		case string(coreapi.PaymentTypeQris):
		}

		resp, err := CoreClient.ChargeTransaction(coreReq)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"message": "Failed to regenerate payment"})
		}

		// Store Payment Details
		details := make(utils.JSONField)
		if len(resp.VaNumbers) > 0 {
			details["va_number"] = resp.VaNumbers[0].VANumber
			details["bank"] = resp.VaNumbers[0].Bank
		}
		if resp.PaymentType == string(coreapi.PaymentTypeQris) || resp.PaymentType == string(coreapi.PaymentTypeGopay) {
			for _, action := range resp.Actions {
				if action.Name == "generate-qr-code" {
					details["qr_url"] = action.URL
				}
				if action.Name == "deeplink-redirect" {
					details["deeplink"] = action.URL
				}
			}
		}
		if resp.BillKey != "" {
			details["bill_key"] = resp.BillKey
			details["biller_code"] = resp.BillerCode
		}
		details["expiry_time"] = resp.ExpiryTime

		database.DB.Model(&order).Updates(models.Order{
			PaymentDetails: details,
		})

		return c.JSON(fiber.Map{
			"mode":           "CORE",
			"paymentDetails": details,
		})

	} else {
		// Midtrans Snap
		reqSnap := &snap.Request{
			TransactionDetails: midtrans.TransactionDetails{
				OrderID:  newTxId,
				GrossAmt: int64(order.TotalAmount),
			},
			CustomerDetail: &midtrans.CustomerDetails{
				FName: userClaims.UserID,
			},
		}

		resp, err := SnapClient.CreateTransaction(reqSnap)
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"message": "Failed to regenerate token"})
		}

		database.DB.Model(&order).Updates(models.Order{
			SnapToken: resp.Token,
			SnapUrl:   resp.RedirectURL,
		})

		return c.JSON(fiber.Map{
			"mode":      "SNAP",
			"snapToken": resp.Token,
			"snapUrl":   resp.RedirectURL,
		})
	}
}
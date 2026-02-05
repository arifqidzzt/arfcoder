package handlers

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"fmt"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/coreapi"
	"github.com/midtrans/midtrans-go/snap"
)

// Exported so other files in 'handlers' package can use it
var SnapClient snap.Client
var CoreClient coreapi.Client

func InitMidtrans() {
	midtrans.ServerKey = config.MidtransServerKey
	midtrans.ClientKey = config.MidtransClientKey
	env := midtrans.Sandbox
	if config.MidtransIsProd == "true" {
		env = midtrans.Production
	}
	SnapClient.New(config.MidtransServerKey, env)
	CoreClient.New(config.MidtransServerKey, env)
}

func CreateOrder(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)

	type ItemReq struct {
		ProductId string `json:"productId"`
		Quantity  int    `json:"quantity"`
	}

	type OrderReq struct {
		Items         []ItemReq `json:"items"`
		Address       string    `json:"address"`
		VoucherCode   string    `json:"voucherCode"`
		PaymentType   string    `json:"paymentType"`   // For Core API, e.g., "bank_transfer", "qris"
		PaymentMethod string    `json:"paymentMethod"` // For Core API, e.g., "bca", "mandiri"
	}

	var req OrderReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	// 1. Fetch Payment Settings
	var paymentSetting models.PaymentSetting
	database.DB.First(&paymentSetting)

	var totalAmount float64
	var orderItems []models.OrderItem

	for _, item := range req.Items {
		var product models.Product
		if err := database.DB.First(&product, "id = ?", item.ProductId).Error; err != nil {
			return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
		}

		price := product.Price * (1 - product.Discount/100)
		totalAmount += price * float64(item.Quantity)

		orderItems = append(orderItems, models.OrderItem{
			ProductID: product.ID,
			Quantity:  item.Quantity,
			Price:     price,
		})
	}

	// Voucher Logic (Simplified)
	discountApplied := 0.0
	if req.VoucherCode != "" {
		var voucher models.Voucher
		if err := database.DB.Where("code = ?", req.VoucherCode).First(&voucher).Error; err == nil {
			if voucher.IsActive && time.Now().Before(voucher.ExpiresAt) {
				if voucher.Type == models.DiscountTypeFixed {
					discountApplied = voucher.Value
				} else {
					discountApplied = (totalAmount * voucher.Value) / 100
				}
				// Save usage
				database.DB.Model(&voucher).Update("usedCount", voucher.UsedCount+1)
			}
		}
	}

	finalAmount := totalAmount - discountApplied
	if finalAmount < 0 {
		finalAmount = 0
	}

	invoiceNumber := fmt.Sprintf("INV-%d-%d", time.Now().UnixMilli(), 100+time.Now().Unix()%900)

	order := models.Order{
		UserID:          user.UserID,
		InvoiceNumber:   invoiceNumber,
		TotalAmount:     finalAmount,
		Status:          models.OrderStatusPending,
		DiscountApplied: discountApplied,
		VoucherCode:     req.VoucherCode,
		Address:         req.Address,
		Items:           orderItems,
		PaymentType:     req.PaymentType,
		PaymentMethod:   req.PaymentMethod,
	}

	if err := database.DB.Create(&order).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to create order"})
	}

	// 2. Midtrans Logic based on Mode
	if paymentSetting.Mode == models.MidtransModeCore {
		// Core API Logic
		if req.PaymentType == "" {
			return c.Status(400).JSON(fiber.Map{"message": "Payment type is required for Core API"})
		}

		coreReq := &coreapi.ChargeReq{
			PaymentType: coreapi.CoreapiPaymentType(req.PaymentType),
			TransactionDetails: midtrans.TransactionDetails{
				OrderID:  order.ID,
				GrossAmt: int64(finalAmount),
			},
			CustomerDetails: &midtrans.CustomerDetails{
				FName: user.UserID,
			},
		}

		// Handle specific payment methods
		switch req.PaymentType {
		case string(coreapi.PaymentTypeBankTransfer):
			coreReq.BankTransfer = &coreapi.BankTransferDetails{
				Bank: midtrans.Bank(req.PaymentMethod),
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
			// QRIS usually doesn't need extra details
		}

		resp, err := CoreClient.ChargeTransaction(coreReq)
		if err != nil {
			fmt.Println("Midtrans Core Error:", err)
			return c.Status(201).JSON(fiber.Map{
				"order":   order,
				"message": "Order created but payment failed",
			})
		}

		// Store Payment Details (VA, QRIS URL, etc.)
		details := make(utils.JSONField)
		if len(resp.VaNumbers) > 0 {
			details["va_number"] = resp.VaNumbers[0].VANumber
			details["bank"] = resp.VaNumbers[0].Bank
		}
		if resp.PaymentType == string(coreapi.PaymentTypeQris) {
			for _, action := range resp.Actions {
				if action.Name == "generate-qr-code" {
					details["qr_url"] = action.URL
				}
			}
		}
		if resp.PaymentType == string(coreapi.PaymentTypeGopay) {
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
		order.PaymentDetails = details

		return c.Status(201).JSON(fiber.Map{
			"order": order,
			"mode":  "CORE",
		})

	} else {
		// Midtrans Snap (Default)
		reqSnap := &snap.Request{
			TransactionDetails: midtrans.TransactionDetails{
				OrderID:  order.ID,
				GrossAmt: int64(finalAmount),
			},
			CustomerDetail: &midtrans.CustomerDetails{
				FName: user.UserID,
			},
		}

		resp, err := SnapClient.CreateTransaction(reqSnap)
		if err != nil {
			fmt.Println("Midtrans Error:", err)
			return c.Status(201).JSON(fiber.Map{
				"order":   order,
				"message": "Order created but payment token failed",
			})
		}

		// Update Order
		database.DB.Model(&order).Updates(models.Order{
			SnapToken: resp.Token,
			SnapUrl:   resp.RedirectURL,
		})

		order.SnapToken = resp.Token
		order.SnapUrl = resp.RedirectURL

		return c.Status(201).JSON(fiber.Map{
			"order":     order,
			"snapToken": resp.Token,
			"snapUrl":   resp.RedirectURL,
			"mode":      "SNAP",
		})
	}
}

func GetOrderById(c *fiber.Ctx) error {
	id := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)

	var order models.Order
	if err := database.DB.Preload("Items.Product").Preload("User").Preload("Timeline").First(&order, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	// 1. Security Check: Only owner or admin
	if userClaims.Role != "ADMIN" && userClaims.Role != "SUPER_ADMIN" && order.UserID != userClaims.UserID {
		return c.Status(403).JSON(fiber.Map{"message": "Forbidden"})
	}

	// 2. Expiration Logic (Auto-Regenerate)
	if order.Status == models.OrderStatusPending {
		timeSinceCreated := time.Since(order.CreatedAt)
		if timeSinceCreated > 24*time.Hour {
			database.DB.Model(&order).Update("status", models.OrderStatusCancelled)
			order.Status = models.OrderStatusCancelled
		} else {
			// Check if Core API payment is expired
			expiryStr, ok := order.PaymentDetails["expiry_time"].(string)
			if ok && expiryStr != "" {
				expiryTime, _ := time.Parse("2006-01-02 15:04:05", expiryStr)
				if !expiryTime.IsZero() && time.Now().After(expiryTime) {
					// AUTO REGENERATE
					fmt.Println("DEBUG: Payment expired, auto-regenerating...")
					newTxId := fmt.Sprintf("%s-%d", order.ID, time.Now().Unix())
					coreReq := &coreapi.ChargeReq{
						PaymentType: coreapi.CoreapiPaymentType(order.PaymentType),
						TransactionDetails: midtrans.TransactionDetails{
							OrderID:  newTxId,
							GrossAmt: int64(order.TotalAmount),
						},
					}
					// Handle specific bank details if needed
					if order.PaymentType == string(coreapi.PaymentTypeBankTransfer) {
						coreReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.Bank(order.PaymentMethod)}
					}

					resp, err := CoreClient.ChargeTransaction(coreReq)
					if err == nil {
						details := make(utils.JSONField)
						if len(resp.VaNumbers) > 0 {
							details["va_number"] = resp.VaNumbers[0].VANumber
							details["bank"] = resp.VaNumbers[0].Bank
						}
						if resp.PaymentType == "qris" || resp.PaymentType == "gopay" {
							for _, action := range resp.Actions {
								if action.Name == "generate-qr-code" { details["qr_url"] = action.URL }
								if action.Name == "deeplink-redirect" { details["deeplink"] = action.URL }
							}
						}
						details["expiry_time"] = resp.ExpiryTime
						database.DB.Model(&order).Update("paymentDetails", details)
						order.PaymentDetails = details
					}
				}
			}
		}
	}

	return c.JSON(order)
}

func HandleMidtransWebhook(c *fiber.Ctx) error {
	var notification map[string]interface{}
	if err := c.BodyParser(&notification); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	rawOrderId := fmt.Sprintf("%v", notification["order_id"])
	transactionStatus := fmt.Sprintf("%v", notification["transaction_status"])
	
	// Strip suffix if exists (e.g., UUID-timestamp)
	orderId := rawOrderId
	if len(rawOrderId) > 36 {
		orderId = rawOrderId[:36]
	}

	var orderStatus string = models.OrderStatusPending

	if transactionStatus == "settlement" || transactionStatus == "capture" {
		orderStatus = models.OrderStatusPaid
	} else if transactionStatus == "cancel" || transactionStatus == "deny" || transactionStatus == "expire" {
		orderStatus = models.OrderStatusCancelled
	}

	// Update Order
	if err := database.DB.Model(&models.Order{}).Where("id = ?", orderId).Update("status", orderStatus).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Database error"})
	}

	return c.Status(200).SendString("OK")
}

func GetMyOrders(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	var orders []models.Order
	database.DB.Preload("Items.Product").Where("\"userId\" = ?", userClaims.UserID).Order("\"createdAt\" desc").Find(&orders)
	return c.JSON(orders)
}

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

func HandleMidtransWebhook(c *fiber.Ctx) error {
	var notification map[string]interface{}
	if err := c.BodyParser(&notification); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	orderId := fmt.Sprintf("%v", notification["order_id"])
	transactionStatus := fmt.Sprintf("%v", notification["transaction_status"])
	fraudStatus := fmt.Sprintf("%v", notification["fraud_status"])

	var orderStatus string = models.OrderStatusPending

	if transactionStatus == "capture" {
		if fraudStatus == "challenge" {
			orderStatus = models.OrderStatusPending
		} else if fraudStatus == "accept" {
			orderStatus = models.OrderStatusPaid
		}
	} else if transactionStatus == "settlement" {
		orderStatus = models.OrderStatusPaid
	} else if transactionStatus == "cancel" || transactionStatus == "deny" || transactionStatus == "expire" {
		orderStatus = models.OrderStatusCancelled
	} else if transactionStatus == "pending" {
		orderStatus = models.OrderStatusPending
	}

	// Extract real Order ID if suffixed (for regenerate logic)
	// Example: ORDERID-1234567890
	// We should just use the ID as is if we stored the unique ID, 
	// BUT our DB ID is UUID usually. 
	// If regenerate logic creates "ORDERID-TIMESTAMP", we need to update that specific transaction?
	// Actually, Update only by ID. If ID in DB is UUID, and Midtrans sends "UUID-TIME", we need to strip suffix.
	// But `RegeneratePaymentToken` updates `SnapToken` on the *original* order row.
	// So we should find the order by the prefix.
	// Simple fix: Try finding exact ID first.
	
	// Assuming orderId matches DB ID for now as per `CreateOrder`. 
	// `RegeneratePaymentToken` uses `newTxId` which is different. 
	// We need to parse it.
	
	// Quick parse:
	// If ID contains "-", split? No, UUID has dashes.
	// We'll rely on the fact that `order_handler` used `order.ID` directly.
	// `Regenerate` used `order.ID + "-" + timestamp`.
	// So we take first 36 chars if it looks like UUID? Or split by last dash?
	// Let's keep it simple: Try update. If 0 rows affected, try stripping suffix.
	
	// Simple approach: Use raw ID.
	if dbRes := database.DB.Model(&models.Order{}).Where("id = ?", orderId).Update("status", orderStatus); dbRes.RowsAffected == 0 {
		// Try stripping suffix (UUID is 36 chars)
		if len(orderId) > 36 {
			realId := orderId[:36]
			database.DB.Model(&models.Order{}).Where("id = ?", realId).Update("status", orderStatus)
		}
	}

	return c.JSON(fiber.Map{"message": "Webhook received", "status": orderStatus})
}

// Fixed GetMyOrders (Moved from separate file to avoid conflict or just ensuring correct imports)
func GetMyOrders(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	var orders []models.Order
	database.DB.Preload("Items.Product").Where("\"userId\" = ?", userClaims.UserID).Order("\"createdAt\" desc").Find(&orders)
	return c.JSON(orders)
}

func GetOrderById(c *fiber.Ctx) error {
	id := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)
	
	var order models.Order
	
	// Logic: Admin can see all, User can see own
	if userClaims.Role == "ADMIN" || userClaims.Role == "SUPER_ADMIN" {
		if err := database.DB.Preload("Items.Product").Preload("User").Preload("Timeline").First(&order, "id = ?", id).Error; err != nil {
			return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
		}
	} else {
		if err := database.DB.Preload("Items.Product").Preload("User").Preload("Timeline").Where("id = ? AND \"userId\" = ?", id, userClaims.UserID).First(&order).Error; err != nil {
			return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
		}
	}
	
	return c.JSON(order)
}

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
	userClaims := c.Locals("user").(*utils.JWTClaims)

	// Fetch full user data from DB
	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	type ItemReq struct {
		ProductId string `json:"productId"`
		Quantity  int    `json:"quantity"`
	}

	type OrderReq struct {
		Items         []ItemReq `json:"items"`
		Address       string    `json:"address"`
		VoucherCode   string    `json:"voucherCode"`
		PaymentType   string    `json:"paymentType"`
		PaymentMethod string    `json:"paymentMethod"`
	}

	var req OrderReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

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
				database.DB.Model(&voucher).Update("usedCount", voucher.UsedCount+1)
			}
		}
	}

	finalAmount := totalAmount - discountApplied
	if finalAmount < 0 { finalAmount = 0 }

	invoiceNumber := fmt.Sprintf("INV-%d-%d", time.Now().UnixMilli(), 100+time.Now().Unix()%900)

	order := models.Order{
		UserID:          user.ID,
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

	database.DB.Where("\"userId\" = ?", user.ID).Delete(&models.CartItem{})

	if paymentSetting.Mode == models.MidtransModeCore {
		coreReq := &coreapi.ChargeReq{
			PaymentType: coreapi.CoreapiPaymentType(req.PaymentType),
			TransactionDetails: midtrans.TransactionDetails{
				OrderID:  order.ID,
				GrossAmt: int64(finalAmount),
			},
			CustomerDetails: &midtrans.CustomerDetails{
				FName: user.Name,
				Email: user.Email,
			},
		}

		callbackURL := config.ClientURL + "/orders/" + order.ID
		if req.PaymentType == "gopay" {
			coreReq.Gopay = &coreapi.GopayDetails{EnableCallback: true, CallbackUrl: callbackURL}
		} else if req.PaymentType == "shopeepay" {
			coreReq.ShopeePay = &coreapi.ShopeePayDetails{CallbackUrl: callbackURL}
		}

		if req.PaymentType == "bank_transfer" {
			coreReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.Bank(req.PaymentMethod)}
		}

		resp, err := CoreClient.ChargeTransaction(coreReq)
		if err != nil {
			fmt.Println("MIDTRANS_ERROR:", err)
			return c.Status(201).JSON(fiber.Map{"order": order, "message": "Payment system busy"})
		}

		details := make(utils.JSONField)
		details["payment_type"] = string(resp.PaymentType)

		if len(resp.VaNumbers) > 0 {
			details["va_number"] = resp.VaNumbers[0].VANumber
			details["bank"] = resp.VaNumbers[0].Bank
		}
		if resp.PermataVaNumber != "" {
			details["va_number"] = resp.PermataVaNumber
			details["bank"] = "permata"
		}

		// Fill deeplink from RedirectURL (Mandatory for DANA)
		if resp.RedirectURL != "" {
			details["deeplink"] = resp.RedirectURL
		}

		for _, action := range resp.Actions {
			if action.Name == "generate-qr-code" {
				details["qr_url"] = action.URL
			}
			if action.Name == "deeplink-redirect" && (details["deeplink"] == nil || details["deeplink"] == "") {
				details["deeplink"] = action.URL
			}
		}

		details["expiry_time"] = resp.ExpiryTime
		database.DB.Model(&order).Update("paymentDetails", details)
		order.PaymentDetails = details

		return c.Status(201).JSON(fiber.Map{"order": order, "mode": "CORE"})
	} else {
		reqSnap := &snap.Request{
			TransactionDetails: midtrans.TransactionDetails{OrderID: order.ID, GrossAmt: int64(finalAmount)},
			CustomerDetail: &midtrans.CustomerDetails{FName: user.UserID},
		}
		resp, _ := SnapClient.CreateTransaction(reqSnap)
		database.DB.Model(&order).Updates(models.Order{SnapToken: resp.Token, SnapUrl: resp.RedirectURL})
		return c.Status(201).JSON(fiber.Map{"order": order, "snapToken": resp.Token, "snapUrl": resp.RedirectURL, "mode": "SNAP"})
	}
}

func GetOrderById(c *fiber.Ctx) error {
	id := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)

	var order models.Order
	if err := database.DB.Preload("Items.Product").Preload("User").Preload("Timeline").First(&order, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	if userClaims.Role != "ADMIN" && userClaims.Role != "SUPER_ADMIN" && order.UserID != userClaims.UserID {
		return c.Status(403).JSON(fiber.Map{"message": "Forbidden"})
	}

	if order.Status == models.OrderStatusPending && order.PaymentDetails != nil {
		expiryStr, ok := order.PaymentDetails["expiry_time"].(string)
		if ok && expiryStr != "" {
			expiryTime, _ := time.Parse("2006-01-02 15:04:05", expiryStr)
			if !expiryTime.IsZero() && time.Now().After(expiryTime) {
				newTxId := fmt.Sprintf("%s-%d", order.ID, time.Now().Unix())
				coreReq := &coreapi.ChargeReq{
					PaymentType: coreapi.CoreapiPaymentType(order.PaymentType),
					TransactionDetails: midtrans.TransactionDetails{OrderID: newTxId, GrossAmt: int64(order.TotalAmount)},
				}
				if order.PaymentType == "bank_transfer" {
					coreReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.Bank(order.PaymentMethod)}
				}
				resp, err := CoreClient.ChargeTransaction(coreReq)
				if err == nil {
					details := make(utils.JSONField)
					if len(resp.VaNumbers) > 0 {
						details["va_number"] = resp.VaNumbers[0].VANumber
						details["bank"] = resp.VaNumbers[0].Bank
					}
					for _, action := range resp.Actions {
						if action.Name == "generate-qr-code" { details["qr_url"] = action.URL }
						if action.Name == "deeplink-redirect" { details["deeplink"] = action.URL }
					}
					if (details["deeplink"] == nil || details["deeplink"] == "") && resp.RedirectURL != "" {
						details["deeplink"] = resp.RedirectURL
					}
					details["expiry_time"] = resp.ExpiryTime
					database.DB.Model(&order).Update("paymentDetails", details)
					order.PaymentDetails = details
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

	orderIdRaw := fmt.Sprintf("%v", notification["order_id"])
	statusCode := fmt.Sprintf("%v", notification["status_code"])
	grossAmount := fmt.Sprintf("%v", notification["gross_amount"])
	signatureKey := fmt.Sprintf("%v", notification["signature_key"])

	payload := orderIdRaw + statusCode + grossAmount + config.MidtransServerKey
	expectedSignature := utils.ComputeSHA512(payload)

	if signatureKey != expectedSignature {
		return c.Status(401).JSON(fiber.Map{"message": "Invalid signature"})
	}

	transactionStatus := fmt.Sprintf("%v", notification["transaction_status"])
	orderId := orderIdRaw
	if len(orderIdRaw) > 36 { orderId = orderIdRaw[:36] }

	var orderStatus string = models.OrderStatusPending
	if transactionStatus == "settlement" || transactionStatus == "capture" {
		orderStatus = models.OrderStatusPaid
	} else if transactionStatus == "cancel" || transactionStatus == "deny" || transactionStatus == "expire" {
		orderStatus = models.OrderStatusCancelled
	}

	database.DB.Model(&models.Order{}).Where("id = ?", orderId).Update("status", orderStatus)
	return c.Status(200).SendString("OK")
}

func GetMyOrders(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	var orders []models.Order
	database.DB.Preload("Items.Product").Where("\"userId\" = ?", userClaims.UserID).Order("\"createdAt\" desc").Find(&orders)
	return c.JSON(orders)
}

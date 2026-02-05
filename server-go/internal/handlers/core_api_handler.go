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
)

var CoreApiClient coreapi.Client

func InitMidtransCoreApi() {
	env := midtrans.Sandbox
	if config.MidtransIsProd == "true" {
		env = midtrans.Production
	}
	CoreApiClient.New(config.MidtransServerKey, env)
}

// CreateCoreApiCharge - Create payment with selected method
func CreateCoreApiCharge(c *fiber.Ctx) error {
	orderID := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)

	type Req struct {
		PaymentMethod string `json:"paymentMethod"` // "bca_va", "qris", "gopay", etc
	}
	var req Req
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	// Get order
	var order models.Order
	if err := database.DB.Preload("Items.Product").Where("id = ? AND \"userId\" = ?", orderID, userClaims.UserID).First(&order).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	if order.Status != models.OrderStatusPending {
		return c.Status(400).JSON(fiber.Map{"message": "Order sudah dibayar atau dibatalkan"})
	}

	// Check if order expired (24 hours)
	if time.Since(order.CreatedAt) > 24*time.Hour {
		database.DB.Model(&order).Update("status", models.OrderStatusCancelled)
		return c.Status(400).JSON(fiber.Map{"message": "Order sudah expired (>24 jam)"})
	}

	// Prepare charge request
	chargeReq := &coreapi.ChargeReq{
		PaymentType: getPaymentType(req.PaymentMethod),
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  order.ID,
			GrossAmt: int64(order.TotalAmount),
		},
		CustomerDetails: &midtrans.CustomerDetails{
			FName: userClaims.UserID,
		},
	}

	// Set payment-specific parameters
	switch req.PaymentMethod {
	case "bca":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankBca}
	case "bni":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankBni}
	case "bri":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankBri}
	case "permata":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankPermata}
	case "cimb":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankCimb}
	case "mandiri":
		chargeReq.EChannel = &coreapi.EChannelDetail{
			BillInfo1: "Payment:",
			BillInfo2: order.InvoiceNumber,
		}
	case "qris":
		chargeReq.PaymentType = coreapi.PaymentTypeQris
		chargeReq.Qris = &coreapi.QrisDetails{Acquirer: "gopay"}
	case "gopay":
		chargeReq.PaymentType = coreapi.PaymentTypeGopay
		chargeReq.Gopay = &coreapi.GopayDetails{
			EnableCallback: true,
			CallbackUrl:    config.ClientURL + "/orders/" + order.ID,
		}
	case "shopeepay":
		chargeReq.PaymentType = coreapi.PaymentTypeShopeepay
		chargeReq.ShopeePay = &coreapi.ShopeePayDetails{CallbackUrl: config.ClientURL + "/orders/" + order.ID}
	case "credit_card":
		chargeReq.PaymentType = coreapi.PaymentTypeCreditCard
	default:
		return c.Status(400).JSON(fiber.Map{"message": "Payment method tidak didukung"})
	}

	// Create charge
	resp, err := CoreApiClient.ChargeTransaction(chargeReq)
	if err != nil {
		fmt.Println("Midtrans Core API Error:", err)
		return c.Status(500).JSON(fiber.Map{"message": "Gagal membuat pembayaran"})
	}

	// Parse expiry time from Midtrans response
	var expiryTime *time.Time
	if resp.ExpiryTime != "" {
		parsedTime, err := time.Parse("2006-01-02 15:04:05", resp.ExpiryTime)
		if err == nil {
			expiryTime = &parsedTime
		}
	}

	// If no expiry from Midtrans, set default based on payment method
	if expiryTime == nil {
		defaultExpiry := time.Now()
		if isInstantPayment(req.PaymentMethod) {
			defaultExpiry = defaultExpiry.Add(15 * time.Minute)
		} else {
			defaultExpiry = defaultExpiry.Add(24 * time.Hour)
		}
		expiryTime = &defaultExpiry
	}

	// Update order with payment details
	updateData := models.Order{
		UseCoreApi:           true,
		CoreApiPaymentMethod: req.PaymentMethod,
		PaymentExpiredAt:     expiryTime,
	}

	// Set payment-specific data
	if resp.VaNumbers != nil && len(resp.VaNumbers) > 0 {
		updateData.CoreApiVaNumber = resp.VaNumbers[0].VANumber
		updateData.CoreApiBankCode = resp.VaNumbers[0].Bank
	}
	if resp.PermataVaNumber != "" {
		updateData.CoreApiVaNumber = resp.PermataVaNumber
		updateData.CoreApiBankCode = "permata"
	}
	if resp.BillKey != "" { // Mandiri Bill
		updateData.CoreApiVaNumber = resp.BillKey
		updateData.CoreApiBankCode = "mandiri"
	}
	if resp.QRString != "" { // QRIS
		updateData.CoreApiQrisUrl = resp.QRString
	}
	if resp.Actions != nil {
		for _, action := range resp.Actions {
			if action.Name == "deeplink-redirect" && action.URL != "" {
				updateData.CoreApiDeeplinkUrl = action.URL
				break
			}
		}
	}

	database.DB.Model(&order).Updates(updateData)

	// Return payment data
	return c.JSON(fiber.Map{
		"success":       true,
		"paymentMethod": req.PaymentMethod,
		"vaNumber":      updateData.CoreApiVaNumber,
		"bankCode":      updateData.CoreApiBankCode,
		"qrisUrl":       updateData.CoreApiQrisUrl,
		"deeplinkUrl":   updateData.CoreApiDeeplinkUrl,
		"expiredAt":     expiryTime,
		"transactionId": resp.TransactionID,
	})
}

// GetPaymentStatus - Check payment status
func GetPaymentStatus(c *fiber.Ctx) error {
	orderID := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)

	var order models.Order
	if err := database.DB.Where("id = ? AND \"userId\" = ?", orderID, userClaims.UserID).First(&order).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	// Check Midtrans status
	status, err := CoreApiClient.CheckTransaction(order.ID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal mengecek status"})
	}

	// Check if payment expired
	paymentExpired := false
	if order.PaymentExpiredAt != nil && time.Now().After(*order.PaymentExpiredAt) {
		paymentExpired = true
	}

	return c.JSON(fiber.Map{
		"orderId":           order.ID,
		"status":            order.Status,
		"transactionStatus": status.TransactionStatus,
		"paymentExpired":    paymentExpired,
		"expiredAt":         order.PaymentExpiredAt,
	})
}

// RegenerateCoreApiPayment - Regenerate payment if expired
func RegenerateCoreApiPayment(c *fiber.Ctx) error {
	orderID := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)

	var order models.Order
	if err := database.DB.Where("id = ? AND \"userId\" = ?", orderID, userClaims.UserID).First(&order).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	// Validation
	if order.Status != models.OrderStatusPending {
		return c.Status(400).JSON(fiber.Map{"message": "Order sudah dibayar atau dibatalkan"})
	}

	if time.Since(order.CreatedAt) > 24*time.Hour {
		database.DB.Model(&order).Update("status", models.OrderStatusCancelled)
		return c.Status(400).JSON(fiber.Map{"message": "Order sudah expired (>24 jam)"})
	}

	if order.PaymentExpiredAt != nil && time.Now().Before(*order.PaymentExpiredAt) {
		return c.Status(400).JSON(fiber.Map{"message": "Payment belum expired, gunakan payment yang ada"})
	}

	// Regenerate with same payment method
	if order.CoreApiPaymentMethod == "" {
		return c.Status(400).JSON(fiber.Map{"message": "Payment method tidak ditemukan"})
	}

	// Create new charge with timestamp suffix for unique transaction ID
	newOrderID := fmt.Sprintf("%s-%d", order.ID, time.Now().Unix())

	chargeReq := &coreapi.ChargeReq{
		PaymentType: getPaymentType(order.CoreApiPaymentMethod),
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  newOrderID,
			GrossAmt: int64(order.TotalAmount),
		},
		CustomerDetails: &midtrans.CustomerDetails{
			FName: userClaims.UserID,
		},
	}

	// Set payment-specific parameters (same as CreateCoreApiCharge)
	switch order.CoreApiPaymentMethod {
	case "bca":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankBca}
	case "bni":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankBni}
	case "bri":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankBri}
	case "permata":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankPermata}
	case "cimb":
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{Bank: midtrans.BankCimb}
	case "mandiri":
		chargeReq.EChannel = &coreapi.EChannelDetail{BillInfo1: "Payment:", BillInfo2: order.InvoiceNumber}
	case "qris":
		chargeReq.PaymentType = coreapi.PaymentTypeQris
		chargeReq.Qris = &coreapi.QrisDetails{Acquirer: "gopay"}
	case "gopay":
		chargeReq.PaymentType = coreapi.PaymentTypeGopay
		chargeReq.Gopay = &coreapi.GopayDetails{EnableCallback: true, CallbackUrl: config.ClientURL + "/orders/" + order.ID}
	case "shopeepay":
		chargeReq.PaymentType = coreapi.PaymentTypeShopeepay
		chargeReq.ShopeePay = &coreapi.ShopeePayDetails{CallbackUrl: config.ClientURL + "/orders/" + order.ID}
	case "credit_card":
		chargeReq.PaymentType = coreapi.PaymentTypeCreditCard
	}

	resp, err := CoreApiClient.ChargeTransaction(chargeReq)
	if err != nil {
		fmt.Println("Regenerate Error:", err)
		return c.Status(500).JSON(fiber.Map{"message": "Gagal regenerate payment"})
	}

	// Parse new expiry
	var expiryTime *time.Time
	if resp.ExpiryTime != "" {
		parsedTime, err := time.Parse("2006-01-02 15:04:05", resp.ExpiryTime)
		if err == nil {
			expiryTime = &parsedTime
		}
	}
	if expiryTime == nil {
		defaultExpiry := time.Now()
		if isInstantPayment(order.CoreApiPaymentMethod) {
			defaultExpiry = defaultExpiry.Add(15 * time.Minute)
		} else {
			defaultExpiry = defaultExpiry.Add(24 * time.Hour)
		}
		expiryTime = &defaultExpiry
	}

	// Update order
	updateData := models.Order{PaymentExpiredAt: expiryTime}
	if resp.VaNumbers != nil && len(resp.VaNumbers) > 0 {
		updateData.CoreApiVaNumber = resp.VaNumbers[0].VANumber
		updateData.CoreApiBankCode = resp.VaNumbers[0].Bank
	}
	if resp.PermataVaNumber != "" {
		updateData.CoreApiVaNumber = resp.PermataVaNumber
		updateData.CoreApiBankCode = "permata"
	}
	if resp.BillKey != "" {
		updateData.CoreApiVaNumber = resp.BillKey
		updateData.CoreApiBankCode = "mandiri"
	}
	if resp.QRString != "" {
		updateData.CoreApiQrisUrl = resp.QRString
	}
	if resp.Actions != nil {
		for _, action := range resp.Actions {
			if action.Name == "deeplink-redirect" && action.URL != "" {
				updateData.CoreApiDeeplinkUrl = action.URL
				break
			}
		}
	}

	database.DB.Model(&order).Updates(updateData)

	return c.JSON(fiber.Map{
		"success":       true,
		"paymentMethod": order.CoreApiPaymentMethod,
		"vaNumber":      updateData.CoreApiVaNumber,
		"bankCode":      updateData.CoreApiBankCode,
		"qrisUrl":       updateData.CoreApiQrisUrl,
		"deeplinkUrl":   updateData.CoreApiDeeplinkUrl,
		"expiredAt":     expiryTime,
	})
}

// Helper functions
func getPaymentType(method string) coreapi.CoreapiPaymentType {
	switch method {
	case "qris":
		return coreapi.PaymentTypeQris
	case "gopay":
		return coreapi.PaymentTypeGopay
	case "shopeepay":
		return coreapi.PaymentTypeShopeepay
	default:
		return coreapi.PaymentTypeBankTransfer
	}
}

func isInstantPayment(method string) bool {
	return method == "qris" || method == "gopay" || method == "shopeepay" || method == "credit_card"
}

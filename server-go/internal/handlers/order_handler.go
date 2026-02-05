package handlers

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"
	"fmt"
	"strings"
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

func GetPaymentMethods(c *fiber.Ctx) error {
	mode := GetPaymentMode()
	if mode != "CORE" {
		return c.JSON([]models.PaymentMethod{})
	}

	productIds := c.Query("productIds") // Expect comma separated: "id1,id2"
	
	var methods []models.PaymentMethod

	if productIds == "" {
		// If no products specified, return ALL active methods (or none? Let's return all active as default/fallback)
		database.DB.Where("\"isActive\" = ?", true).Find(&methods)
	} else {
		ids := strings.Split(productIds, ",")
		// Find intersection: Methods that are associated with ALL given product IDs.
		// Query: Select * from payment_methods where id IN (select payment_method_id from product_payment_methods where product_id = ID1) AND id IN (select ... ID2)
		// This is complex in GORM.
		// Easier approach: Get all products with their methods, then intersect in Go.
		// Or: Raw SQL.
		
		// Let's use Go logic for simplicity unless performance is critical (cart usually < 20 items).
		
		var products []models.Product
		if err := database.DB.Preload("PaymentMethods").Where("id IN ?", ids).Find(&products).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"message": "Error fetching products"})
		}

		if len(products) == 0 {
			return c.JSON([]models.PaymentMethod{})
		}

		// Map to count occurrences. A method is valid if it appears in ALL products.
		counts := make(map[string]int)
		methodMap := make(map[string]models.PaymentMethod)

		for _, p := range products {
			// Optimization: If a product has NO methods, result is empty immediately.
			if len(p.PaymentMethods) == 0 {
				return c.JSON([]models.PaymentMethod{})
			}
			for _, m := range p.PaymentMethods {
				if m.IsActive {
					counts[m.ID]++
					methodMap[m.ID] = m
				}
			}
		}

		// Filter
		for id, count := range counts {
			if count == len(products) {
				methods = append(methods, methodMap[id])
			}
		}
	}

	return c.JSON(methods)
}

func GetPaymentMode() string {
	var config models.SystemConfig
	if err := database.DB.First(&config, "key = ?", "payment_gateway_mode").Error; err != nil {
		return "SNAP" // Default
	}
	return config.Value
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
		PaymentMethod string    `json:"paymentMethod"` // Required if mode is CORE
	}

	var req OrderReq
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	mode := GetPaymentMode()
	if mode == "CORE" && req.PaymentMethod == "" {
		return c.Status(400).JSON(fiber.Map{"message": "Payment method required for Core API"})
	}

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

	// Voucher Logic
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
		UserID:          user.UserID,
		InvoiceNumber:   invoiceNumber,
		TotalAmount:     finalAmount,
		Status:          models.OrderStatusPending,
		DiscountApplied: discountApplied,
		VoucherCode:     req.VoucherCode,
		Address:         req.Address,
		Items:           orderItems,
		PaymentMethod:   req.PaymentMethod,
	}

	if err := database.DB.Create(&order).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to create order"})
	}

	if mode == "CORE" {
		return processCoreApiPayment(c, &order, req.PaymentMethod)
	} else {
		return processSnapPayment(c, &order, user)
	}
}

func processSnapPayment(c *fiber.Ctx, order *models.Order, user *utils.JWTClaims) error {
	reqSnap := &snap.Request{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  order.ID,
			GrossAmt: int64(order.TotalAmount),
		},
		CustomerDetail: &midtrans.CustomerDetails{
			FName: user.UserID, 
		},
	}

	resp, err := SnapClient.CreateTransaction(reqSnap)
	if err != nil {
		fmt.Println("Midtrans Error:", err)
		return c.Status(201).JSON(fiber.Map{
			"order": order,
			"message": "Order created but payment token failed",
		})
	}

	database.DB.Model(order).Updates(models.Order{
		SnapToken: resp.Token,
		SnapUrl:   resp.RedirectURL,
	})
	
	order.SnapToken = resp.Token
	order.SnapUrl = resp.RedirectURL

	return c.Status(201).JSON(fiber.Map{
		"order":     order,
		"snapToken": resp.Token,
		"snapUrl":   resp.RedirectURL,
	})
}

func processCoreApiPayment(c *fiber.Ctx, order *models.Order, paymentMethodCode string) error {
	// Find Payment Method details
	var pm models.PaymentMethod
	if err := database.DB.Where("code = ?", paymentMethodCode).First(&pm).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid payment method"})
	}

	chargeReq := &coreapi.ChargeReq{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  order.ID, // Use exact ID first time
			GrossAmt: int64(order.TotalAmount),
		},
	}

	// Helper to set chargeReq based on Type
	switch pm.Type {
	case "VA":
		// Example: "bca_va", "bni_va" -> bank: "bca", "bni"
		bank := strings.TrimSuffix(pm.Code, "_va")
		chargeReq.PaymentType = coreapi.PaymentTypeBankTransfer
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{
			Bank: midtrans.Bank(bank),
		}
	case "QRIS":
		chargeReq.PaymentType = coreapi.PaymentTypeQris
	case "EWALLET":
		// Example: "gopay", "shopeepay"
		chargeReq.PaymentType = coreapi.CoreapiPaymentType(pm.Code)
		if pm.Code == "gopay" {
			chargeReq.Gopay = &coreapi.GopayDetails{
				EnableCallback: true, // For deeplink
			}
		}
	}

	// 15 Minutes Expiry
	chargeReq.CustomExpiry = &coreapi.CustomExpiry{
		OrderTime:      time.Now().Format("2006-01-02 15:04:05 -0700"),
		ExpiryDuration: 15,
		Unit:           "minute",
	}

	resp, err := CoreClient.ChargeTransaction(chargeReq)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Payment Gateway Error: " + err.Error()})
	}

	// Extract Data
	var paymentCode, paymentUrl string
	expiryTime := time.Now().Add(15 * time.Minute)

	if len(resp.VaNumbers) > 0 {
		paymentCode = resp.VaNumbers[0].VANumber
	} else if resp.PaymentType == "qris" {
		paymentUrl = resp.Actions[0].URL // Usually the QR image
	} else if resp.PaymentType == "gopay" {
		if len(resp.Actions) > 0 {
			paymentUrl = resp.Actions[0].URL // Deeplink
		}
	} else if resp.PermataVaNumber != "" {
		paymentCode = resp.PermataVaNumber
	}

	// Update Order
	updates := models.Order{
		PaymentMethod: pm.Code,
		PaymentCode:   paymentCode,
		PaymentUrl:    paymentUrl,
		PaymentExpiry: &expiryTime,
	}
	database.DB.Model(order).Updates(updates)

	// Refresh struct
	order.PaymentMethod = updates.PaymentMethod
	order.PaymentCode = updates.PaymentCode
	order.PaymentUrl = updates.PaymentUrl
	order.PaymentExpiry = updates.PaymentExpiry

	return c.Status(201).JSON(fiber.Map{
		"order": order,
	})
}

// Regenerate Payment for Expired Core API Orders
func RegeneratePayment(c *fiber.Ctx) error {
	id := c.Params("id")
	userClaims := c.Locals("user").(*utils.JWTClaims)

	var order models.Order
	if err := database.DB.First(&order, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}

	if order.UserID != userClaims.UserID && userClaims.Role != "ADMIN" {
		return c.Status(403).JSON(fiber.Map{"message": "Unauthorized"})
	}

	if order.Status != models.OrderStatusPending {
		return c.Status(400).JSON(fiber.Map{"message": "Order is not pending"})
	}

	// Check if allowed (within 24 hours of creation)
	if time.Since(order.CreatedAt) > 24*time.Hour {
		database.DB.Model(&order).Update("status", models.OrderStatusCancelled)
		return c.Status(400).JSON(fiber.Map{"message": "Order expired (24h limit)"})
	}

	// New Transaction ID needed for Midtrans (Unique)
	newTxId := fmt.Sprintf("%s-%d", order.ID, time.Now().Unix())

	// Re-run logic similar to processCoreApiPayment but with newTxId
	var pm models.PaymentMethod
	if err := database.DB.Where("code = ?", order.PaymentMethod).First(&pm).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid payment method"})
	}

	chargeReq := &coreapi.ChargeReq{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  newTxId, 
			GrossAmt: int64(order.TotalAmount),
		},
	}

	// ... (Copy switch case logic or extract to function)
	// Simplified copy for now
	switch pm.Type {
	case "VA":
		bank := strings.TrimSuffix(pm.Code, "_va")
		chargeReq.PaymentType = coreapi.PaymentTypeBankTransfer
		chargeReq.BankTransfer = &coreapi.BankTransferDetails{
			Bank: midtrans.Bank(bank),
		}
	case "QRIS":
		chargeReq.PaymentType = coreapi.PaymentTypeQris
	case "EWALLET":
		chargeReq.PaymentType = coreapi.CoreapiPaymentType(pm.Code)
		if pm.Code == "gopay" {
			chargeReq.Gopay = &coreapi.GopayDetails{ EnableCallback: true }
		}
	}
	
	chargeReq.CustomExpiry = &coreapi.CustomExpiry{
		OrderTime:      time.Now().Format("2006-01-02 15:04:05 -0700"),
		ExpiryDuration: 15,
		Unit:           "minute",
	}

	resp, err := CoreClient.ChargeTransaction(chargeReq)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Payment Gateway Error: " + err.Error()})
	}

	var paymentCode, paymentUrl string
	expiryTime := time.Now().Add(15 * time.Minute)

	if len(resp.VaNumbers) > 0 {
		paymentCode = resp.VaNumbers[0].VANumber
	} else if resp.PaymentType == "qris" {
		paymentUrl = resp.Actions[0].URL
	} else if resp.PaymentType == "gopay" && len(resp.Actions) > 0 {
		paymentUrl = resp.Actions[0].URL
	} else if resp.PermataVaNumber != "" {
		paymentCode = resp.PermataVaNumber
	}

	updates := models.Order{
		PaymentCode:   paymentCode,
		PaymentUrl:    paymentUrl,
		PaymentExpiry: &expiryTime,
	}
	database.DB.Model(&order).Updates(updates)
	order.PaymentCode = paymentCode
	order.PaymentUrl = paymentUrl
	order.PaymentExpiry = &expiryTime

	return c.JSON(fiber.Map{"message": "Payment regenerated", "order": order})
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

	// Update logic for suffixed IDs
	if dbRes := database.DB.Model(&models.Order{}).Where("id = ?", orderId).Update("status", orderStatus); dbRes.RowsAffected == 0 {
		if len(orderId) > 36 {
			// Try to find the original ID prefix
			// Heuristic: Check if split by "-" works or just take substring
			// Since our ID is generated via cuid/random string in previous code, it might not be fixed length 36?
			// But Prisma cuid is typically ~25 chars.
			// Let's assume we split by last dash if we used "ID-Timestamp" format.
			parts := strings.Split(orderId, "-")
			if len(parts) > 1 {
				// Rejoin all except last
				realId := strings.Join(parts[:len(parts)-1], "-")
				database.DB.Model(&models.Order{}).Where("id = ?", realId).Update("status", orderStatus)
			}
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

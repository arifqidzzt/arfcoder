package handlers

import (
	"os"

	"github.com/arifqi/arfcoder-server/internal/config"
	"github.com/arifqi/arfcoder-server/internal/models"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/snap"
)

type CreateOrderRequest struct {
	Items   []models.OrderItem `json:"items"`
	Address string             `json:"address"`
}

type UpdateOrderRequest struct {
	Status       models.OrderStatus `json:"status"`
	RefundProof  string             `json:"refundProof"`
	DeliveryInfo string             `json:"deliveryInfo"`
}

// User: Create Order
func CreateOrder(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userId := claims["userId"].(string)

	var user models.User
	if err := config.DB.First(&user, "id = ?", userId).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	var req CreateOrderRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}

	var totalAmount float64
	var orderItems []models.OrderItem

	for _, item := range req.Items {
		var product models.Product
		if err := config.DB.First(&product, "id = ?", item.ProductId).Error; err != nil {
			continue
		}
		
		finalPrice := product.Price * (1 - product.Discount/100)
		totalAmount += finalPrice * float64(item.Quantity)

		orderItems = append(orderItems, models.OrderItem{
			ID:        uuid.New().String(),
			ProductId: product.ID,
			Quantity:  item.Quantity,
			Price:     finalPrice,
		})
	}

	order := models.Order{
		ID:            uuid.New().String(),
		InvoiceNumber: "INV-" + uuid.New().String()[:8],
		UserId:        userId,
		TotalAmount:   totalAmount,
		Status:        models.StatusPending,
		Address:       &req.Address,
		Items:         orderItems,
	}

	if err := config.DB.Create(&order).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to create order"})
	}

	// Midtrans Logic
	midtrans.ServerKey = os.Getenv("MIDTRANS_SERVER_KEY")
	midtrans.Environment = midtrans.Sandbox
	if os.Getenv("MIDTRANS_IS_PRODUCTION") == "true" {
		midtrans.Environment = midtrans.Production
	}

	snapReq := &snap.Request{
		TransactionDetails: midtrans.TransactionDetails{
			OrderID:  order.ID,
			GrossAmt: int64(totalAmount),
		},
		CustomerDetail: &midtrans.CustomerDetails{
			FName: user.Name,
			Email: user.Email,
		},
	}

	snapResp, err := snap.CreateTransaction(snapReq)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Midtrans Error", "error": err.Message})
	}

	config.DB.Model(&order).Updates(models.Order{
		SnapToken: &snapResp.Token,
		SnapUrl:   &snapResp.RedirectURL,
	})

	return c.JSON(fiber.Map{
		"orderId":   order.ID,
		"snapToken": snapResp.Token,
		"snapUrl":   snapResp.RedirectURL,
	})
}

// User: Get My Orders
func GetMyOrders(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userId := claims["userId"].(string)

	var orders []models.Order
	config.DB.Preload("Items.Product").Where("user_id = ?", userId).Order("created_at desc").Find(&orders)
	return c.JSON(orders)
}

// User & Admin: Get Order Detail
func GetOrder(c *fiber.Ctx) error {
	id := c.Params("id")
	var order models.Order
	if err := config.DB.Preload("User").Preload("Items.Product").First(&order, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Order not found"})
	}
	return c.JSON(order)
}

// Admin: Get All Orders
func GetAllOrders(c *fiber.Ctx) error {
	var orders []models.Order
	config.DB.Preload("User").Preload("Items.Product").Order("created_at desc").Find(&orders)
	return c.JSON(orders)
}

// Admin: Update Order Status / Delivery
func UpdateOrder(c *fiber.Ctx) error {
	id := c.Params("id")
	var req UpdateOrderRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	updates := map[string]interface{}{}
	if req.Status != "" { updates["status"] = req.Status }
	if req.RefundProof != "" { updates["refund_proof"] = req.RefundProof }
	if req.DeliveryInfo != "" { 
		updates["delivery_info"] = req.DeliveryInfo 
		updates["status"] = models.StatusShipped
	}

	if err := config.DB.Model(&models.Order{}).Where("id = ?", id).Updates(updates).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to update"})
	}

	return c.JSON(fiber.Map{"message": "Order updated"})
}

// User: Pay (Re-snap)
func PayOrder(c *fiber.Ctx) error {
	id := c.Params("id")
	var order models.Order
	config.DB.Preload("User").First(&order, "id = ?", id)

	// Re-generate snap token (simplified logic, reuse CreateOrder logic ideally)
	// For now, return existing token
	return c.JSON(fiber.Map{
		"snapToken": order.SnapToken,
		"snapUrl":   order.SnapUrl,
	})
}

// User: Cancel Order
func CancelOrder(c *fiber.Ctx) error {
	id := c.Params("id")
	config.DB.Model(&models.Order{}).Where("id = ?", id).Update("status", models.StatusCancelled)
	return c.JSON(fiber.Map{"message": "Order cancelled"})
}

// User: Request Refund
type RefundRequest struct {
	Reason  string `json:"reason"`
	Account string `json:"account"`
}
func RequestRefund(c *fiber.Ctx) error {
	id := c.Params("id")
	var req RefundRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid"})
	}
	
	config.DB.Model(&models.Order{}).Where("id = ?", id).Updates(map[string]interface{}{
		"status":         models.StatusRefundReq,
		"refund_reason":  req.Reason,
		"refund_account": req.Account,
	})
	return c.JSON(fiber.Map{"message": "Refund requested"})
}

func MidtransWebhook(c *fiber.Ctx) error {
	var notif map[string]interface{}
	if err := c.BodyParser(&notif); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid"})
	}

	orderId := notif["order_id"].(string)
	status := notif["transaction_status"].(string)
	
	var newStatus models.OrderStatus
	if status == "settlement" || status == "capture" {
		newStatus = models.StatusPaid
	} else if status == "expire" || status == "cancel" {
		newStatus = models.StatusCancelled
	}

	if newStatus != "" {
		config.DB.Model(&models.Order{}).Where("id = ?", orderId).Update("status", newStatus)
	}

	return c.SendStatus(200)
}

package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"

	"github.com/gofiber/fiber/v2"
)

// GetSettings - Get global payment settings
func GetSettings(c *fiber.Ctx) error {
	var settings models.Settings

	// Try to get settings with key "payment_config"
	err := database.DB.Where("key = ?", "payment_config").First(&settings).Error
	if err != nil {
		// If not found, create default settings
		settings = models.Settings{
			Key:                   "payment_config",
			PaymentMode:           "snap",
			DefaultPaymentMethods: []string{},
		}
		database.DB.Create(&settings)
	}

	return c.JSON(settings)
}

// UpdateSettings - Update global payment settings (ADMIN ONLY)
func UpdateSettings(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)

	// Check admin
	if userClaims.Role != models.RoleAdmin && userClaims.Role != models.RoleSuperAdmin {
		return c.Status(403).JSON(fiber.Map{"message": "Forbidden: Admin only"})
	}

	type Req struct {
		PaymentMode           string   `json:"paymentMode"`           // "snap" or "core_api"
		DefaultPaymentMethods []string `json:"defaultPaymentMethods"` // for core_api mode
	}

	var req Req
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	// Validate payment mode
	if req.PaymentMode != "snap" && req.PaymentMode != "core_api" {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid payment mode. Must be 'snap' or 'core_api'"})
	}

	// Get or create settings
	var settings models.Settings
	err := database.DB.Where("key = ?", "payment_config").First(&settings).Error
	if err != nil {
		// Create if not exists
		settings = models.Settings{
			Key:                   "payment_config",
			PaymentMode:           req.PaymentMode,
			DefaultPaymentMethods: req.DefaultPaymentMethods,
		}
		database.DB.Create(&settings)
	} else {
		// Update existing
		database.DB.Model(&settings).Updates(models.Settings{
			PaymentMode:           req.PaymentMode,
			DefaultPaymentMethods: req.DefaultPaymentMethods,
		})
	}

	return c.JSON(fiber.Map{
		"message":  "Settings updated successfully",
		"settings": settings,
	})
}

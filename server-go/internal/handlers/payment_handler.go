package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"github.com/gofiber/fiber/v2"
)

func GetPaymentSettings(c *fiber.Ctx) error {
	var settings models.PaymentSetting
	if err := database.DB.First(&settings).Error; err != nil {
		// If not exists, return default
		defaultSettings := models.PaymentSetting{
			Mode: models.MidtransModeSnap,
		}
		return c.JSON(defaultSettings)
	}
	return c.JSON(settings)
}

func UpdatePaymentSettings(c *fiber.Ctx) error {
	var req models.PaymentSetting
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var settings models.PaymentSetting
	result := database.DB.First(&settings)
	
	if result.Error != nil {
		// Create new
		if err := database.DB.Create(&req).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"message": "Failed to create settings"})
		}
		return c.JSON(req)
	}

	// Update existing
	settings.Mode = req.Mode
	settings.ActiveMethods = req.ActiveMethods
	
	if err := database.DB.Save(&settings).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to update settings"})
	}

	return c.JSON(settings)
}

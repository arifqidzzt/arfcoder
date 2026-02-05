package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"fmt"
	"github.com/gofiber/fiber/v2"
)

func GetPaymentSettings(c *fiber.Ctx) error {
	var settings models.PaymentSetting
	if err := database.DB.First(&settings).Error; err != nil {
		return c.JSON(models.PaymentSetting{Mode: "SNAP"})
	}
	return c.JSON(settings)
}

func UpdatePaymentSettings(c *fiber.Ctx) error {
	fmt.Println("DEBUG: Masuk ke UpdatePaymentSettings")
	var req models.PaymentSetting
	if err := c.BodyParser(&req); err != nil {
		fmt.Println("DEBUG: BodyParser Error:", err)
		return c.Status(400).JSON(fiber.Map{"message": "Format data tidak valid"})
	}

	fmt.Printf("DEBUG: Data diterima: Mode=%s, Methods=%v\n", req.Mode, req.ActiveMethods)

	var settings models.PaymentSetting
	result := database.DB.First(&settings)
	
	if result.Error != nil {
		fmt.Println("DEBUG: Membuat pengaturan baru di database")
		if err := database.DB.Create(&req).Error; err != nil {
			fmt.Println("DEBUG: DB Create Error:", err)
			return c.Status(500).JSON(fiber.Map{"message": err.Error()})
		}
	} else {
		fmt.Println("DEBUG: Memperbarui pengaturan yang sudah ada")
		settings.Mode = req.Mode
		settings.ActiveMethods = req.ActiveMethods
		if err := database.DB.Save(&settings).Error; err != nil {
			fmt.Println("DEBUG: DB Save Error:", err)
			return c.Status(500).JSON(fiber.Map{"message": err.Error()})
		}
	}

	fmt.Println("DEBUG: Pengaturan berhasil disimpan")
	return c.JSON(fiber.Map{"status": "success"})
}

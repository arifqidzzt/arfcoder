package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"time"

	"github.com/gofiber/fiber/v2"
)

// --- VOUCHERS ---

func CreateVoucher(c *fiber.Ctx) error {
	var voucher models.Voucher
	if err := c.BodyParser(&voucher); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}

	// Check existing
	var existing models.Voucher
	if err := database.DB.Where("code = ?", voucher.Code).First(&existing).Error; err == nil {
		return c.Status(400).JSON(fiber.Map{"message": "Kode voucher sudah ada"})
	}

	if err := database.DB.Create(&voucher).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Create failed"})
	}
	return c.Status(201).JSON(voucher)
}

func GetAllVouchers(c *fiber.Ctx) error {
	var vouchers []models.Voucher
	database.DB.Order("created_at desc").Find(&vouchers)
	return c.JSON(vouchers)
}

func DeleteVoucher(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Voucher{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Voucher deleted"})
}

func CheckVoucher(c *fiber.Ctx) error {
	type Req struct {
		Code        string  `json:"code"`
		TotalAmount float64 `json:"totalAmount"`
	}
	var req Req
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid Request"})
	}

	var voucher models.Voucher
	if err := database.DB.Where("code = ?", req.Code).First(&voucher).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Voucher tidak ditemukan"})
	}

	if !voucher.IsActive {
		return c.Status(400).JSON(fiber.Map{"message": "Voucher tidak aktif"})
	}
	if time.Now().After(voucher.ExpiresAt) {
		return c.Status(400).JSON(fiber.Map{"message": "Voucher kedaluwarsa"})
	}
	if voucher.UsageLimit > 0 && voucher.UsedCount >= voucher.UsageLimit {
		return c.Status(400).JSON(fiber.Map{"message": "Kuota voucher habis"})
	}
	if req.TotalAmount < voucher.MinPurchase {
		return c.Status(400).JSON(fiber.Map{
			"message": "Minimal belanja tidak terpenuhi",
		})
	}

	discountAmount := 0.0
	if voucher.Type == models.DiscountTypeFixed {
		discountAmount = voucher.Value
	} else {
		discountAmount = (req.TotalAmount * voucher.Value) / 100
		if voucher.MaxDiscount > 0 && discountAmount > voucher.MaxDiscount {
			discountAmount = voucher.MaxDiscount
		}
	}

	if discountAmount > req.TotalAmount {
		discountAmount = req.TotalAmount
	}

	return c.JSON(fiber.Map{
		"valid":          true,
		"voucher":        voucher,
		"discountAmount": discountAmount,
		"finalAmount":    req.TotalAmount - discountAmount,
	})
}

// --- FLASH SALE ---

func CreateFlashSale(c *fiber.Ctx) error {
	var fs models.FlashSale
	if err := c.BodyParser(&fs); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}
	database.DB.Create(&fs)
	return c.Status(201).JSON(fs)
}

func GetActiveFlashSales(c *fiber.Ctx) error {
	var sales []models.FlashSale
	now := time.Now()
	database.DB.Preload("Product").Where("is_active = ? AND start_time <= ? AND end_time > ?", true, now, now).Order("end_time asc").Find(&sales)
	return c.JSON(sales)
}

func GetAllFlashSales(c *fiber.Ctx) error {
	var sales []models.FlashSale
	database.DB.Preload("Product").Order("created_at desc").Find(&sales)
	return c.JSON(sales)
}

func DeleteFlashSale(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.FlashSale{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"time"

	"github.com/gofiber/fiber/v2"
)

func CreateFlashSale(c *fiber.Ctx) error {
	type Req struct {
		ProductId     string    `json:"productId"`
		DiscountPrice float64   `json:"discountPrice"`
		StartTime     time.Time `json:"startTime"`
		EndTime       time.Time `json:"endTime"`
	}
	var req Req
	c.BodyParser(&req)

	fs := models.FlashSale{
		ProductID:     req.ProductId,
		DiscountPrice: req.DiscountPrice,
		StartTime:     req.StartTime,
		EndTime:       req.EndTime,
		IsActive:      true,
	}
	database.DB.Create(&fs)
	return c.Status(201).JSON(fs)
}

func GetActiveFlashSales(c *fiber.Ctx) error {
	now := time.Now()
	var flashSales []models.FlashSale
	
	err := database.DB.Preload("Product").Where("\"isActive\" = ? AND \"startTime\" <= ? AND \"endTime\" > ?", true, now, now).Order("\"endTime\" asc").Find(&flashSales).Error
	
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Error fetching flash sales"})
	}
	return c.JSON(flashSales)
}

// FIX: Added GetAllFlashSales for Admin
func GetAllFlashSales(c *fiber.Ctx) error {
	var flashSales []models.FlashSale
	database.DB.Preload("Product").Order("\"createdAt\" desc").Find(&flashSales)
	return c.JSON(flashSales)
}

func DeleteFlashSale(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.FlashSale{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}
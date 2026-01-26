package handlers

import (
	"github.com/arifqi/arfcoder-server/internal/config"
	"github.com/arifqi/arfcoder-server/internal/models"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

func GetAllProducts(c *fiber.Ctx) error {
	var products []models.Product
	search := c.Query("search")

	query := config.DB.Preload("Category").Order("\"createdAt\" desc") // Preload Category
	if search != "" {
		query = query.Where("\"name\" ILIKE ?", "%"+search+"%")
	}

	query.Find(&products)
	return c.JSON(products)
}

func GetProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := config.DB.Preload("Category").First(&product, "\"id\" = ?", id).Error; err != nil { // Preload Category
		return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
	}
	return c.JSON(product)
}

// Admin Only
func CreateProduct(c *fiber.Ctx) error {
	var req models.Product
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}

	req.ID = uuid.New().String()
	if err := config.DB.Create(&req).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to create product"})
	}

	return c.JSON(req)
}

func UpdateProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := config.DB.First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
	}

	var updateData models.Product
	if err := c.BodyParser(&updateData); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}

	config.DB.Model(&product).Updates(updateData)
	return c.JSON(product)
}

func DeleteProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	config.DB.Delete(&models.Product{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Product deleted"})
}

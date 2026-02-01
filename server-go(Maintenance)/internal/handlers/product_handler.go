package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// Public Services
func GetPublicServices(c *fiber.Ctx) error {
	var services []models.Service
	database.DB.Order("created_at desc").Find(&services)
	return c.JSON(services)
}

// Get All Products (With Search & Category Filter)
func GetAllProducts(c *fiber.Ctx) error {
	category := c.Query("category")
	search := c.Query("search")

	db := database.DB.Preload("Category").Model(&models.Product{})

	if category != "" {
		// Join category to filter by name
		db = db.Joins("JOIN categories ON categories.id = products.category_id").
			Where("categories.name = ?", category)
	}

	if search != "" {
		// Case insensitive search (Postgres ILIKE)
		searchLower := "%" + strings.ToLower(search) + "%"
		db = db.Where("LOWER(products.name) LIKE ?", searchLower)
	}

	var products []models.Product
	if err := db.Find(&products).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Error fetching products"})
	}

	return c.JSON(products)
}

func GetProductById(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := database.DB.Preload("Category").Preload("Reviews.User").First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
	}
	return c.JSON(product)
}

// Admin Product CRUD
func CreateProduct(c *fiber.Ctx) error {
	var product models.Product
	if err := c.BodyParser(&product); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}
	database.DB.Create(&product)
	return c.Status(201).JSON(product)
}

func UpdateProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := database.DB.First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
	}

	var updates models.Product
	if err := c.BodyParser(&updates); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}

	database.DB.Model(&product).Updates(updates)
	return c.JSON(product)
}

func DeleteProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Product{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Product deleted"})
}

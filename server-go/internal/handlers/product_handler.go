package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"

	"github.com/gofiber/fiber/v2"
	"github.com/lib/pq"
)

func GetPublicServices(c *fiber.Ctx) error {
	var services []models.Service
	database.DB.Order("\"createdAt\" desc").Find(&services)
	return c.JSON(services)
}

func GetAllProducts(c *fiber.Ctx) error {
	var products []models.Product
	if err := database.DB.Order("\"createdAt\" desc").Find(&products).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Error fetching products"})
	}
	return c.JSON(products)
}

func GetProductById(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := database.DB.First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
	}
	return c.JSON(product)
}

func CreateProduct(c *fiber.Ctx) error {
	type Req struct {
		Name        string   `json:"name"`
		Description string   `json:"description"`
		Price       float64  `json:"price"`
		Discount    float64  `json:"discount"`
		Stock       int      `json:"stock"`
		Type        string   `json:"type"`
		Images      []string `json:"images"`
		CategoryId  string   `json:"categoryId"`
	}
	var req Req
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid data"})
	}

	product := models.Product{
		Name:        req.Name,
		Description: req.Description,
		Price:       req.Price,
		Discount:    req.Discount,
		Stock:       req.Stock,
		Type:        req.Type,
		Images:      pq.StringArray(req.Images), // Cast to pq.StringArray
	}
	
	if req.CategoryId != "" {
		product.CategoryID = &req.CategoryId
	}

	database.DB.Create(&product)
	return c.Status(201).JSON(product)
}

func UpdateProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	type Req struct {
		Name        string   `json:"name"`
		Description string   `json:"description"`
		Price       float64  `json:"price"`
		Discount    float64  `json:"discount"`
		Stock       int      `json:"stock"`
		Type        string   `json:"type"`
		Images      []string `json:"images"`
	}
	var req Req
	c.BodyParser(&req)

	var product models.Product
	if err := database.DB.First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Not found"})
	}

	product.Name = req.Name
	product.Description = req.Description
	product.Price = req.Price
	product.Discount = req.Discount
	product.Stock = req.Stock
	product.Type = req.Type
	product.Images = pq.StringArray(req.Images)

	database.DB.Save(&product)
	return c.JSON(product)
}

func DeleteProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Product{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

// --- ADMIN SERVICES ---

func GetAdminServices(c *fiber.Ctx) error {
	return GetPublicServices(c)
}

func UpsertService(c *fiber.Ctx) error {
	type Req struct {
		ID          string `json:"id"`
		Title       string `json:"title"`
		Description string `json:"description"`
		Price       string `json:"price"`
		Icon        string `json:"icon"`
	}
	var req Req
	c.BodyParser(&req)

	if req.ID == "" || req.ID == "new" {
		service := models.Service{
			Title: req.Title, Description: req.Description, Price: req.Price, Icon: req.Icon,
		}
		database.DB.Create(&service)
		return c.Status(201).JSON(service)
	} else {
		var service models.Service
		if err := database.DB.First(&service, "id = ?", req.ID).Error; err != nil {
			return c.Status(404).JSON(fiber.Map{"message": "Not found"})
		}
		service.Title = req.Title
		service.Description = req.Description
		service.Price = req.Price
		service.Icon = req.Icon
		database.DB.Save(&service)
		return c.JSON(service)
	}
}

func DeleteService(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Service{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

func GetAllVouchers(c *fiber.Ctx) error {
	var vouchers []models.Voucher
	database.DB.Order("\"createdAt\" desc").Find(&vouchers)
	return c.JSON(vouchers)
}

func CreateVoucher(c *fiber.Ctx) error {
	// ... implementation same as Node ...
	return c.JSON(fiber.Map{"message": "Voucher created"})
}

func DeleteVoucher(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Voucher{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

func CheckVoucher(c *fiber.Ctx) error {
	// Logic check voucher
	return c.JSON(fiber.Map{"valid": false})
}
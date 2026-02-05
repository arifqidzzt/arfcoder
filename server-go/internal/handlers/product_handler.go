package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"fmt"
	"time"

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
	if err := database.DB.Preload("PaymentMethods").Order("\"createdAt\" desc").Find(&products).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Error fetching products"})
	}
	return c.JSON(products)
}

func GetProductById(c *fiber.Ctx) error {
	id := c.Params("id")
	var product models.Product
	if err := database.DB.Preload("PaymentMethods").First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Product not found"})
	}
	return c.JSON(product)
}

func CreateProduct(c *fiber.Ctx) error {
	type Req struct {
		Name             string   `json:"name"`
		Description      string   `json:"description"`
		Price            float64  `json:"price"`
		Discount         float64  `json:"discount"`
		Stock            int      `json:"stock"`
		Type             string   `json:"type"`
		Images           []string `json:"images"`
		CategoryId       string   `json:"categoryId"`
		PaymentMethodIds []string `json:"paymentMethodIds"` // Added
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
		Images:      pq.StringArray(req.Images), 
	}
	
	if req.CategoryId != "" {
		product.CategoryID = &req.CategoryId
	}

	// Association
	if len(req.PaymentMethodIds) > 0 {
		var methods []models.PaymentMethod
		database.DB.Where("id IN ?", req.PaymentMethodIds).Find(&methods)
		product.PaymentMethods = methods
	}

	database.DB.Create(&product)
	return c.Status(201).JSON(product)
}

func UpdateProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	type Req struct {
		Name             string   `json:"name"`
		Description      string   `json:"description"`
		Price            float64  `json:"price"`
		Discount         float64  `json:"discount"`
		Stock            int      `json:"stock"`
		Type             string   `json:"type"`
		Images           []string `json:"images"`
		PaymentMethodIds []string `json:"paymentMethodIds"` // Added
	}
	var req Req
	c.BodyParser(&req)

	var product models.Product
	if err := database.DB.Preload("PaymentMethods").First(&product, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Not found"})
	}

	product.Name = req.Name
	product.Description = req.Description
	product.Price = req.Price
	product.Discount = req.Discount
	product.Stock = req.Stock
	product.Type = req.Type
	product.Images = pq.StringArray(req.Images)

	// Update Association
	database.DB.Model(&product).Association("PaymentMethods").Clear()
	if len(req.PaymentMethodIds) > 0 {
		var methods []models.PaymentMethod
		database.DB.Where("id IN ?", req.PaymentMethodIds).Find(&methods)
		database.DB.Model(&product).Association("PaymentMethods").Append(methods)
	}

	database.DB.Save(&product)
	return c.JSON(product)
}

func DeleteProduct(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Product{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

func GetAllVouchers(c *fiber.Ctx) error {
	var vouchers []models.Voucher
	database.DB.Order("\"createdAt\" desc").Find(&vouchers)
	return c.JSON(vouchers)
}

func CreateVoucher(c *fiber.Ctx) error {
	var voucher models.Voucher
	if err := c.BodyParser(&voucher); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}
	// Defaults
	if voucher.StartDate.IsZero() { voucher.StartDate = time.Now() }
	if voucher.ExpiresAt.IsZero() { voucher.ExpiresAt = time.Now().Add(30 * 24 * time.Hour) }
	
	if err := database.DB.Create(&voucher).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to create voucher"})
	}
	return c.Status(201).JSON(voucher)
}

func DeleteVoucher(c *fiber.Ctx) error {
	id := c.Params("id")
	database.DB.Delete(&models.Voucher{}, "id = ?", id)
	return c.JSON(fiber.Map{"message": "Deleted"})
}

func CheckVoucher(c *fiber.Ctx) error {
	type Req struct {
		Code        string  `json:"code"`
		TotalAmount float64 `json:"totalAmount"`
	}
	var req Req
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"valid": false, "message": "Invalid Request"})
	}

	var voucher models.Voucher
	if err := database.DB.Where("code = ?", req.Code).First(&voucher).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"valid": false, "message": "Kode voucher tidak ditemukan"})
	}

	if !voucher.IsActive {
		return c.Status(400).JSON(fiber.Map{"valid": false, "message": "Voucher tidak aktif"})
	}

	if time.Now().After(voucher.ExpiresAt) {
		return c.Status(400).JSON(fiber.Map{"valid": false, "message": "Voucher kadaluarsa"})
	}

	if voucher.UsageLimit > 0 && voucher.UsedCount >= voucher.UsageLimit {
		return c.Status(400).JSON(fiber.Map{"valid": false, "message": "Kuota voucher habis"})
	}

	if req.TotalAmount < voucher.MinPurchase {
		return c.Status(400).JSON(fiber.Map{"valid": false, "message": fmt.Sprintf("Min pembelian Rp %.0f", voucher.MinPurchase)})
	}

	discount := 0.0
	if voucher.Type == models.DiscountTypeFixed {
		discount = voucher.Value
	} else {
		discount = (req.TotalAmount * voucher.Value) / 100
		if voucher.MaxDiscount > 0 && discount > voucher.MaxDiscount {
			discount = voucher.MaxDiscount
		}
	}

	return c.JSON(fiber.Map{
		"valid":          true,
		"discountAmount": discount,
		"code":           voucher.Code,
		"type":           voucher.Type,
		"finalAmount":    req.TotalAmount - discount,
	})
}
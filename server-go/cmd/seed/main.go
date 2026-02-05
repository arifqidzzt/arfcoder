package main

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"fmt"
)

func main() {
	config.LoadConfig()
	database.Connect()

	fmt.Println("🌱 Starting Seeding Process...")

	// 1. Seed Category
	var category models.Category
	if err := database.DB.Where("name = ?", "Software").First(&category).Error; err != nil {
		category = models.Category{Name: "Software"}
		database.DB.Create(&category)
		fmt.Println("✅ Category 'Software' created")
	} else {
		fmt.Println("ℹ️ Category 'Software' already exists")
	}

	// 2. Seed Products
	products := []models.Product{
		{
			Name:        "ArfCoder E-Commerce Template",
			Description: "Template e-commerce siap pakai dengan desain minimalis.",
			Price:       1500000,
			Type:        models.ProductTypeBarang,
			Stock:       100,
			Images:      []string{"https://placehold.co/600x400/000000/FFFFFF?text=E-Commerce+Template"},
			CategoryID:  &category.ID,
		},
		{
			Name:        "Custom Web Development",
			Description: "Jasa pembuatan website kustom sesuai kebutuhan Anda.",
			Price:       5000000,
			Type:        models.ProductTypeJasa,
			Stock:       999,
			Images:      []string{"https://placehold.co/600x400/000000/FFFFFF?text=Custom+Web"},
			CategoryID:  &category.ID,
		},
	}

	for _, p := range products {
		var exist int64
		database.DB.Model(&models.Product{}).Where("name = ?", p.Name).Count(&exist)
		if exist == 0 {
			database.DB.Create(&p)
			fmt.Printf("✅ Product '%s' created\n", p.Name)
		}
	}

	// [REMOVED] Admin creation logic to prevent overwriting existing data

	// 4. Seed Payment Methods
	methods := []models.PaymentMethod{
		{Code: "bca_va", Name: "BCA Virtual Account", Type: "VA", IsActive: true},
		{Code: "bni_va", Name: "BNI Virtual Account", Type: "VA", IsActive: true},
		{Code: "bri_va", Name: "BRI Virtual Account", Type: "VA", IsActive: true},
		{Code: "gopay", Name: "GoPay", Type: "EWALLET", IsActive: true},
		{Code: "shopeepay", Name: "ShopeePay", Type: "EWALLET", IsActive: true},
		{Code: "qris", Name: "QRIS", Type: "QRIS", IsActive: true},
	}

	for _, m := range methods {
		var exist int64
		database.DB.Model(&models.PaymentMethod{}).Where("code = ?", m.Code).Count(&exist)
		if exist == 0 {
			database.DB.Create(&m)
			fmt.Printf("✅ Payment Method '%s' created\n", m.Name)
		}
	}

	// 5. Seed System Config
	configs := []models.SystemConfig{
		{Key: "payment_gateway_mode", Value: "SNAP"}, // Default SNAP
	}
	for _, c := range configs {
		var exist int64
		database.DB.Model(&models.SystemConfig{}).Where("key = ?", c.Key).Count(&exist)
		if exist == 0 {
			database.DB.Create(&c)
			fmt.Printf("✅ Config '%s' created\n", c.Key)
		}
	}

	fmt.Println("\n✨ Seeding Completed!")
}

package middleware

import (
	"encoding/json"
	"strings"

	"arfcoder-go/internal/utils"

	"github.com/gofiber/fiber/v2"
)

func SecureMiddleware(c *fiber.Ctx) error {
	// --- PENGECEKAN WEBHOOK (WAJIB DI ATAS) ---
	// Jika URL mengandung kata "webhook", abaikan semua proteksi keamanan
	if strings.Contains(c.Path(), "webhook") {
		return c.Next()
	}

	// 1. Check Header Keamanan
	secureHeader := c.Get("x-arf-secure-token")
	if !utils.VerifySecureHeader(secureHeader) {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"message": "Access Denied: Invalid Security Header",
		})
	}

	// 2. Handle Body Decryption for POST/PUT/PATCH
	method := c.Method()
	if method == "POST" || method == "PUT" || method == "PATCH" {
		var rawBody interface{}
		if err := json.Unmarshal(c.Body(), &rawBody); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Access Denied: Invalid Body Format",
			})
		}

		bodyArray, ok := rawBody.([]interface{})
		if !ok || len(bodyArray) != 5 {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Access Denied: Invalid Obfuscated Payload",
			})
		}

		decrypted, err := utils.DecryptPayload(bodyArray)
		if err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"message": "Access Denied: Decryption Failed",
			})
		}

		newBody, err := json.Marshal(decrypted)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"message": "Re-marshal failed"})
		}
		
		c.Request().SetBody(newBody)
		c.Request().Header.SetContentType("application/json")
	}

	return c.Next()
}

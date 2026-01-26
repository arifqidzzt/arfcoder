package middleware

import (
	"github.com/arifqi/arfcoder-server/pkg/utils"
	"github.com/gofiber/fiber/v2"
)

func SecureHeaders(c *fiber.Ctx) error {
	// Skip for public webhook
	if c.Path() == "/api/midtrans-webhook" {
		return c.Next()
	}

	headerToken := c.Get("x-arf-secure-token")
	if headerToken == "" {
		return c.Status(403).JSON(fiber.Map{"message": "Access Denied: Missing Security Header"})
	}

	if !utils.VerifyHeader(headerToken) {
		return c.Status(403).JSON(fiber.Map{"message": "Access Denied: Invalid Security Header"})
	}

	return c.Next()
}
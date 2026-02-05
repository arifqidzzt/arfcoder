package middleware

import (
	"encoding/json"
	"strings"

	"arfcoder-go/internal/utils"

	"github.com/gofiber/fiber/v2"
)

func SecureMiddleware(c *fiber.Ctx) error {
	// 1. Check Header
	path := c.Path()
	// Skip Webhook Security Checks
	if strings.Contains(path, "webhook") {
		return c.Next()
	}

	secureHeader := c.Get("x-arf-secure-token")

		// Read Body as generic Interface to check if it's the Array[5] format
		var rawBody interface{}
		if err := json.Unmarshal(c.Body(), &rawBody); err != nil {
			// If not JSON or empty, maybe proceed (depends on logic), but Node version checks strictly
			// However, if parsing fails, it might not be the encrypted payload.
			// Let's assume strict compliance.
			// Actually, if it's standard JSON (not encrypted), Node version fails? 
			// Node version: if (!Array.isArray(req.body) || req.body.length !== 5) return 400.
			// So YES, strict.
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

		// Replace Body with Decrypted JSON
		newBody, err := json.Marshal(decrypted)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"message": "Re-marshal failed"})
		}
		
		c.Request().SetBody(newBody)
		// Update Content-Length? Fiber might handle it or ignore if we set body directly.
		// Important: Set Content-Type to application/json just in case
		c.Request().Header.SetContentType("application/json")
	}

	return c.Next()
}

package middleware

import (
	"arfcoder-go/internal/utils"
	"strings"

	"github.com/gofiber/fiber/v2"
)

func AuthMiddleware(c *fiber.Ctx) error {
	authHeader := c.Get("Authorization")
	if authHeader == "" {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"message": "Unauthorized"})
	}

	tokenString := strings.Replace(authHeader, "Bearer ", "", 1)
	claims, err := utils.VerifyToken(tokenString)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"message": "Invalid Token"})
	}

	c.Locals("user", claims)
	return c.Next()
}

func AdminOnly(c *fiber.Ctx) error {
	user := c.Locals("user").(*utils.JWTClaims)
	if user.Role != "ADMIN" && user.Role != "SUPER_ADMIN" {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"message": "Admin Access Required"})
	}
	return c.Next()
}

// OptionalAuth extracts user from token if present, but doesn't require auth
// Used for view pages that need user info but are accessible to guests
func OptionalAuth(c *fiber.Ctx) error {
	authHeader := c.Get("Authorization")
	if authHeader == "" {
		// No auth header, continue as guest
		return c.Next()
	}

	tokenString := strings.Replace(authHeader, "Bearer ", "", 1)
	claims, err := utils.VerifyToken(tokenString)
	if err != nil {
		// Invalid token, continue as guest
		return c.Next()
	}

	c.Locals("user", claims)
	return c.Next()
}

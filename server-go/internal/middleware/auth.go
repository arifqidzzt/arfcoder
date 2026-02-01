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

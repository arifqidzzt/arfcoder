package middleware

import (
	"arfcoder-go/internal/utils"
	"strings"

	"github.com/gofiber/fiber/v2"
)

func AuthMiddleware(c *fiber.Ctx) error {
	authHeader := c.Get("Authorization")
	var tokenString string

	if authHeader != "" && strings.HasPrefix(authHeader, "Bearer ") {
		tokenString = strings.TrimPrefix(authHeader, "Bearer ")
	} else {
		// Try Cookie
		tokenString = c.Cookies("auth_token")
	}

	if tokenString == "" {
		if c.Get("HX-Request") != "" || c.Accepts("text/html") != "" {
			return c.Redirect("/login")
		}
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"message": "Unauthorized"})
	}
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

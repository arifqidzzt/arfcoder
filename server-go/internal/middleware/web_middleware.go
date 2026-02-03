package middleware

import (
	"arfcoder-go/internal/utils"
	"strings"

	"github.com/gofiber/fiber/v2"
)

// SoftWebAuth checks for a token in the cookie but doesn't block request if missing
func SoftWebAuth(c *fiber.Ctx) error {
	tokenString := c.Cookies("token")
	
	// If no cookie, check header just in case (for hybrid use)
	if tokenString == "" {
		authHeader := c.Get("Authorization")
		if authHeader != "" {
			tokenString = strings.Replace(authHeader, "Bearer ", "", 1)
		}
	}

	if tokenString != "" {
		claims, err := utils.VerifyToken(tokenString)
		if err == nil {
			c.Locals("user", claims)
		}
	}

	return c.Next()
}

// RequireWebAuth ensures user is logged in, otherwise redirects to login
func RequireWebAuth(c *fiber.Ctx) error {
	// Re-use SoftWebAuth logic to populate user if possible
	SoftWebAuth(c)
	
	user := c.Locals("user")
	if user == nil {
		return c.Redirect("/auth/login")
	}

	return c.Next()
}

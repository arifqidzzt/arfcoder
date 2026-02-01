package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/services/email"
	"arfcoder-go/internal/services/whatsapp"
	"arfcoder-go/internal/utils"
	"fmt"
	"math/rand"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/pquerna/otp/totp"
)

// 1. Setup 2FA (Generate Secret & QR)
func SetupTwoFactor(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	secret := user.TwoFactorSecret
	if secret == "" {
		key, err := totp.Generate(totp.GenerateOpts{
			Issuer:      "ArfCoder",
			AccountName: user.Email,
		})
		if err != nil {
			return c.Status(500).JSON(fiber.Map{"message": "Error generating 2FA"})
		}
		secret = key.Secret()
		database.DB.Model(&user).Update("two_factor_secret", secret)
	}

	// QR Code Placeholder
	// Note: In a real scenario with full dependencies, we would generate the PNG here.
	// For this migration, we return the secret and otpauth URL so the Frontend can generate it
	// OR use the text secret manually.
	
	// Removing unused imports (bytes, encoding, png) to fix compiler error.
	
	return c.JSON(fiber.Map{
		"secret": secret,
		"otpauth": fmt.Sprintf("otpauth://totp/ArfCoder:%s?secret=%s&issuer=ArfCoder", user.Email, secret),
	})
}

// 2. Enable 2FA
func EnableTwoFactor(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		Token string `json:"token"`
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	valid := totp.Validate(req.Token, user.TwoFactorSecret)
	if !valid {
		return c.Status(400).JSON(fiber.Map{"message": "Kode OTP salah"})
	}

	database.DB.Model(&user).Update("two_factor_enabled", true)
	return c.JSON(fiber.Map{"message": "2FA berhasil diaktifkan!"})
}

// 3. Login Verify (The critical one)
func VerifyLogin2FA(c *fiber.Ctx) error {
	type Req struct {
		UserID string `json:"userId"`
		Code   string `json:"code"`
		Method string `json:"method"` // authenticator, email, whatsapp
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	if err := database.DB.First(&user, "id = ?", req.UserID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	verified := false

	if req.Method == "authenticator" {
		if user.TwoFactorSecret == "" {
			return c.Status(400).JSON(fiber.Map{"message": "Google Auth belum aktif"})
		}
		verified = totp.Validate(req.Code, user.TwoFactorSecret)
	} else {
		// DB OTP
		var otp models.Otp
		if err := database.DB.Where("user_id = ? AND code = ? AND expires_at > ?", req.UserID, req.Code, time.Now()).First(&otp).Error; err == nil {
			verified = true
			database.DB.Delete(&otp)
		}
	}

	if verified {
		token, _ := utils.GenerateToken(user.ID, user.Role)
		refreshToken, _ := utils.GenerateRefreshToken(user.ID)
		
		// Log
		database.DB.Create(&models.ActivityLog{
			UserID: user.ID,
			Action: "LOGIN",
			Details: "Login via 2FA (" + req.Method + ")",
			IPAddress: c.IP(),
		})

		return c.JSON(fiber.Map{
			"token":        token,
			"refreshToken": refreshToken,
			"user":         user,
		})
	}

	return c.Status(400).JSON(fiber.Map{"message": "Kode Verifikasi Salah"})
}

// 4. Send Backup OTP
func SendBackupOtp(c *fiber.Ctx) error {
	type Req struct {
		UserID string `json:"userId"`
		Method string `json:"method"`
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	if err := database.DB.First(&user, "id = ?", req.UserID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	otpCode := fmt.Sprintf("%06d", rand.Intn(1000000))
	
	// Clear old
	database.DB.Delete(&models.Otp{}, "user_id = ?", user.ID)

	database.DB.Create(&models.Otp{
		Code:      otpCode,
		UserID:    user.ID,
		Email:     user.Email,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	if req.Method == "email" {
		go email.SendEmail(user.Email, "Kode Login Admin", "Kode: "+otpCode)
	} else if req.Method == "whatsapp" {
		if user.PhoneNumber == "" {
			return c.Status(400).JSON(fiber.Map{"message": "Nomor WA belum diset"})
		}
		go whatsapp.SendMessage(user.PhoneNumber, "Kode Login: "+otpCode)
	}

	return c.JSON(fiber.Map{"message": "OTP dikirim"})
}
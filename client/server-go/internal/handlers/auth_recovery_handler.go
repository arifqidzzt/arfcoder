package handlers

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/services/email"
	"arfcoder-go/internal/utils"
	"fmt"
	"math/rand"
	"time"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

// Forgot Password
func ForgotPassword(c *fiber.Ctx) error {
	type Req struct {
		Email string `json:"email"`
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Email tidak terdaftar"})
	}

	// Generate Token
	resetToken := utils.GenerateRandomString(32)
	expiry := time.Now().Add(1 * time.Hour)

	database.DB.Model(&user).Updates(map[string]interface{}{
		"resetToken":       resetToken,
		"resetTokenExpiry": expiry,
	})

	resetUrl := fmt.Sprintf("%s/reset-password?token=%s", config.ClientURL, resetToken)
	
	go email.SendEmail(user.Email, "Permintaan Ganti Password", email.GenerateLinkEmail(user.Name, resetUrl, "Reset Password", "Ganti Password"))

	return c.JSON(fiber.Map{"message": "Link reset dikirim ke email"})
}

// Reset Password
func ResetPassword(c *fiber.Ctx) error {
	type Req struct {
		Token       string `json:"token"`
		NewPassword string `json:"newPassword"`
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	if err := database.DB.Where("\"resetToken\" = ? AND \"resetTokenExpiry\" > ?", req.Token, time.Now()).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Token invalid atau expired"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.NewPassword), 10)
	
	// Reset & Clear Token
	database.DB.Model(&user).Updates(map[string]interface{}{
		"password":           string(hashed),
		"resetToken":         nil,
		"resetTokenExpiry":   nil,
	})

	return c.JSON(fiber.Map{"message": "Password berhasil direset"})
}

// Resend OTP (Registration)
func ResendOtp(c *fiber.Ctx) error {
	type Req struct {
		UserID string `json:"userId"`
		Email  string `json:"email"`
	}
	var req Req
	c.BodyParser(&req)

	otpCode := fmt.Sprintf("%06d", rand.Intn(1000000))

	// Clear old
	database.DB.Delete(&models.Otp{}, "\"userId\" = ? AND email = ?", req.UserID, req.Email)

	database.DB.Create(&models.Otp{
		Code:      otpCode,
		UserID:    req.UserID,
		Email:     req.Email,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	go email.SendEmail(req.Email, "Kode Verifikasi Baru", email.GenerateOtpEmail(req.Email, otpCode, "Verifikasi Baru"))

	return c.JSON(fiber.Map{"message": "Kode OTP baru telah dikirim"})
}

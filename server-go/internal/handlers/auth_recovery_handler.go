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
		"reset_token":        resetToken,
		"reset_token_expiry": expiry,
	})

	resetUrl := fmt.Sprintf("%s/reset-password?token=%s", config.ClientURL, resetToken)
	
	// Send Email
	htmlContent := fmt.Sprintf(`
		<div style="font-family: Arial, sans-serif;">
			<h2>Halo, %s</h2>
			<p>Klik tombol di bawah untuk reset password:</p>
			<a href="%s" style="padding: 10px 20px; background: black; color: white;">Ganti Password</a>
		</div>
	`, user.Name, resetUrl)
	
	go email.SendEmail(user.Email, "Permintaan Ganti Password", htmlContent)

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
	if err := database.DB.Where("reset_token = ? AND reset_token_expiry > ?", req.Token, time.Now()).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Token invalid atau expired"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.NewPassword), 10)
	
	// Reset & Clear Token
	database.DB.Model(&user).Updates(map[string]interface{}{
		"password":           string(hashed),
		"reset_token":        nil,
		"reset_token_expiry": nil,
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
	database.DB.Delete(&models.Otp{}, "user_id = ? AND email = ?", req.UserID, req.Email)

	database.DB.Create(&models.Otp{
		Code:      otpCode,
		UserID:    req.UserID,
		Email:     req.Email,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	go email.SendEmail(req.Email, "Kode Verifikasi Baru", "Kode: "+otpCode)

	return c.JSON(fiber.Map{"message": "Kode OTP baru telah dikirim"})
}

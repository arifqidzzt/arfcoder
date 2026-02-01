package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/services/email"
	"arfcoder-go/internal/utils"
	"fmt"
	"math/rand"
	"time"

	"github.com/gofiber/fiber/v2"
)

// --- EMAIL CHANGE FLOW ---

func RequestEmailChange(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	var user models.User
	if err := database.DB.First(&user, "id = ?", userClaims.UserID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	otpCode := fmt.Sprintf("%06d", rand.Intn(1000000))
	database.DB.Create(&models.Otp{
		Code:      otpCode,
		UserID:    user.ID,
		Email:     user.Email,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	go email.SendEmail(user.Email, "Kode Ganti Email", "Kode Anda: "+otpCode)

	return c.JSON(fiber.Map{"message": "OTP dikirim ke email lama"})
}

func VerifyOldEmail(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		Code     string `json:"code"`
		NewEmail string `json:"newEmail"`
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	var otp models.Otp
	if err := database.DB.Where("user_id = ? AND code = ? AND email = ? AND expires_at > ?", userClaims.UserID, req.Code, user.Email, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "OTP Salah/Expired"})
	}
	database.DB.Delete(&otp)

	// Send OTP to NEW Email
	newOtpCode := fmt.Sprintf("%06d", rand.Intn(1000000))
	database.DB.Create(&models.Otp{
		Code:      newOtpCode,
		UserID:    user.ID,
		Email:     req.NewEmail,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	go email.SendEmail(req.NewEmail, "Verifikasi Email Baru", "Kode Anda: "+newOtpCode)

	return c.JSON(fiber.Map{"message": "Verifikasi berhasil. OTP dikirim ke email baru."})
}

func VerifyNewEmail(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		Code     string `json:"code"`
		NewEmail string `json:"newEmail"`
	}
	var req Req
	c.BodyParser(&req)

	var otp models.Otp
	if err := database.DB.Where("user_id = ? AND code = ? AND email = ? AND expires_at > ?", userClaims.UserID, req.Code, req.NewEmail, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "OTP Salah/Expired"})
	}
	database.DB.Delete(&otp)

	database.DB.Model(&models.User{}).Where("id = ?", userClaims.UserID).Update("email", req.NewEmail)
	return c.JSON(fiber.Map{"message": "Email berhasil diubah!"})
}

// --- PHONE CHANGE FLOW (Missing VerifyOld) ---

func VerifyOldPhone(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		Code string `json:"code"`
	}
	var req Req
	c.BodyParser(&req)

	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	var otp models.Otp
	// Check "old_" prefix logic from Node
	if err := database.DB.Where("user_id = ? AND code = ? AND email = ?", userClaims.UserID, req.Code, "old_"+user.PhoneNumber).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "OTP Salah"})
	}
	database.DB.Delete(&otp)

	return c.JSON(fiber.Map{"message": "Verifikasi berhasil. Masukkan nomor baru."})
}

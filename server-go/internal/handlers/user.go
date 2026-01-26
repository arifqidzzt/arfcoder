package handlers

import (
	"fmt"
	"time"

	"github.com/arifqi/arfcoder-server/internal/config"
	"github.com/arifqi/arfcoder-server/internal/models"
	"github.com/arifqi/arfcoder-server/pkg/services"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type PhoneRequest struct {
	PhoneNumber string `json:"phoneNumber"`
	Code        string `json:"code"`
}

type EmailChangeRequest struct {
	NewEmail string `json:"newEmail"`
	Code     string `json:"code"`
}

func RequestPhoneChange(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	var user models.User
	config.DB.First(&user, ""id" = ?", userId)

	if user.PhoneNumber == nil || *user.PhoneNumber == "" {
		return c.JSON(fiber.Map{"skipOld": true})
	}

	otp := generateOTP()
	config.DB.Create(&models.Otp{
		ID:        uuid.New().String(),
		Code:      otp,
		UserId:    userId,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	})

	msg := fmt.Sprintf("*Kode Verifikasi ArfCoder*\n\nKode Anda: *%s*\n\nJangan berikan kode ini kepada siapapun.", otp)
	err := services.SendMessage(*user.PhoneNumber, msg)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal mengirim WhatsApp"})
	}

	return c.JSON(fiber.Map{"message": "OTP dikirim ke WhatsApp lama"})
}

func VerifyOldPhone(c *fiber.Ctx) error {
	var req PhoneRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	var otp models.Otp
	if err := config.DB.Where(""userId" = ? AND ""code" = ? AND ""expiresAt" > ?", userId, req.Code, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Kode salah atau kadaluarsa"})
	}

	config.DB.Delete(&otp)
	return c.JSON(fiber.Map{"message": "Verified"})
}

func RequestNewPhone(c *fiber.Ctx) error {
	var req PhoneRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	otp := generateOTP()
	config.DB.Create(&models.Otp{
		ID:        uuid.New().String(),
		Code:      otp,
		UserId:    userId,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	})

	msg := fmt.Sprintf("*Kode Verifikasi ArfCoder*\n\nKode Baru Anda: *%s*", otp)
	err := services.SendMessage(req.PhoneNumber, msg)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal mengirim ke nomor baru"})
	}

	return c.JSON(fiber.Map{"message": "OTP dikirim ke nomor baru"})
}

func VerifyNewPhone(c *fiber.Ctx) error {
	var req PhoneRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	var otp models.Otp
	if err := config.DB.Where(""userId" = ? AND ""code" = ? AND ""expiresAt" > ?", userId, req.Code, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Kode salah"})
	}

	config.DB.Model(&models.User{}).Where(""id" = ?", userId).Update("phoneNumber", req.PhoneNumber)
	config.DB.Delete(&otp)

	return c.JSON(fiber.Map{"message": "Phone updated"})
}

func RequestEmailChange(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	var user models.User
	config.DB.First(&user, ""id" = ?", userId)

	otp := generateOTP()
	config.DB.Create(&models.Otp{
		ID:        uuid.New().String(),
		Code:      otp,
		UserId:    userId,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	})

	go sendEmail(user.Email, "Ganti Email", "Kode Verifikasi: <b>"+otp+"</b>")
	return c.JSON(fiber.Map{"message": "OTP dikirim ke email lama"})
}

func VerifyOldEmail(c *fiber.Ctx) error {
	var req EmailChangeRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid"})
	}

	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	var otp models.Otp
	if err := config.DB.Where(""userId" = ? AND ""code" = ?", userId, req.Code).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Kode salah"})
	}

	// Send to new email
	newOtp := generateOTP()
	config.DB.Create(&models.Otp{
		ID:        uuid.New().String(),
		Code:      newOtp,
		UserId:    userId,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	})
	
go sendEmail(req.NewEmail, "Verifikasi Email Baru", "Kode Verifikasi Baru: <b>"+newOtp+"</b>")
	config.DB.Delete(&otp)

	return c.JSON(fiber.Map{"message": "OTP dikirim ke email baru"})
}

func VerifyNewEmail(c *fiber.Ctx) error {
	var req EmailChangeRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid"})
	}

	userToken := c.Locals("user").(*jwt.Token)
	userId := userToken.Claims.(jwt.MapClaims)["userId"].(string)

	var otp models.Otp
	if err := config.DB.Where(""userId" = ? AND ""code" = ?", userId, req.Code).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Kode salah"})
	}

	config.DB.Model(&models.User{}).Where(""id" = ?", userId).Update("email", req.NewEmail)
	config.DB.Delete(&otp)

	return c.JSON(fiber.Map{"message": "Email updated"})
}

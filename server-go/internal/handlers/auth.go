package handlers

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"fmt"
	"math/big"
	"os"
	"time"

	"github.com/arifqi/arfcoder-server/internal/config"
	"github.com/arifqi/arfcoder-server/internal/models"
	"github.com/arifqi/arfcoder-server/pkg/utils"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/resend/resend-go/v2"
	"golang.org/x/crypto/bcrypt"
	"google.golang.org/api/idtoken"
)

type EncryptedRequest struct {
	Payload   string `json:"payload"`
	Signature string `json:"signature"`
	Timestamp string `json:"timestamp"`
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type RegisterRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type VerifyOtpRequest struct {
	UserId string `json:"userId"`
	Code   string `json:"code"`
}

type ResendOtpRequest struct {
	UserId string `json:"userId"`
	Email  string `json:"email"`
}

type GoogleLoginRequest struct {
	Token string `json:"token"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email"`
}

type ResetPasswordRequest struct {
	Token       string `json:"token"`
	NewPassword string `json:"newPassword"`
}

type UpdateProfileRequest struct {
	Name   string `json:"name"`
	Avatar string `json:"avatar"`
}

type ChangePasswordRequest struct {
	OldPassword string `json:"oldPassword"`
	NewPassword string `json:"newPassword"`
}

// --- HELPERS ---
func parseEncryptedBody(c *fiber.Ctx, out interface{}) error {
	var req EncryptedRequest
	if err := c.BodyParser(&req); err != nil {
		return err
	}
	if !utils.VerifySignature(req.Payload, req.Timestamp, req.Signature) {
		return fmt.Errorf("invalid signature")
	}
	jsonStr, err := utils.DecryptPayload(req.Payload)
	if err != nil {
		return err
	}
	return json.Unmarshal([]byte(jsonStr), out)
}

func generateOTP() string {
	n, _ := rand.Int(rand.Reader, big.NewInt(900000))
	return fmt.Sprintf("%06d", n.Int64()+100000)
}

func sendEmail(to, subject, html string) {
	apiKey := os.Getenv("RESEND_API_KEY")
	if apiKey == "" {
		fmt.Println("[Email] Resend API Key missing")
		return
	}
	client := resend.NewClient(apiKey)
	params := &resend.SendEmailRequest{
		From:    os.Getenv("EMAIL_FROM"),
		To:      []string{to},
		Subject: subject,
		Html:    html,
	}
	_, err := client.Emails.Send(params)
	if err != nil {
		fmt.Println("[Email] Failed:", err)
	}
}

// --- HANDLERS ---

func Login(c *fiber.Ctx) error {
	var data LoginRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var user models.User
	if err := config.DB.Where("email = ?", data.Email).First(&user).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	if !user.IsVerified {
		return c.Status(403).JSON(fiber.Map{
			"message": "Please verify email",
			"userId":  user.ID,
		})
	}

	if user.Password == "" && user.GoogleId != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Please login with Google"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(data.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Wrong password"})
	}

	token, _ := utils.GenerateToken(user.ID, string(user.Role))
	return c.JSON(fiber.Map{"token": token, "user": user})
}

func Register(c *fiber.Ctx) error {
	var data RegisterRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(data.Password), 10)
	user := models.User{
		ID:        uuid.New().String(),
		Name:      data.Name,
		Email:     data.Email,
		Password:  string(hashed),
		Role:      models.RoleUser,
		CreatedAt: time.Now(),
		UpdatedAt: time.Now(),
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Email already exists"})
	}

	// Send OTP
	otpCode := generateOTP()
	otp := models.Otp{
		ID:        uuid.New().String(),
		Code:      otpCode,
		Email:     user.Email,
		UserId:    user.ID,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	}
	config.DB.Create(&otp)
	
	go sendEmail(user.Email, "Verifikasi Akun", "Kode OTP Anda: <b>"+otpCode+"</b>")

	return c.JSON(fiber.Map{"message": "Success", "userId": user.ID})
}

func VerifyOtp(c *fiber.Ctx) error {
	var data VerifyOtpRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var otp models.Otp
	if err := config.DB.Where("user_id = ? AND code = ? AND expires_at > ?", data.UserId, data.Code, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid or expired OTP"})
	}

	config.DB.Model(&models.User{}).Where("id = ?", data.UserId).Update("is_verified", true)
	config.DB.Delete(&otp) // Burn OTP

	return c.JSON(fiber.Map{"message": "Verified"})
}

func ResendOtp(c *fiber.Ctx) error {
	var data ResendOtpRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	otpCode := generateOTP()
	config.DB.Create(&models.Otp{
		ID:        uuid.New().String(),
		Code:      otpCode,
		Email:     data.Email,
		UserId:    data.UserId,
		ExpiresAt: time.Now().Add(10 * time.Minute),
	})

	go sendEmail(data.Email, "Resend OTP", "Kode OTP Baru: <b>"+otpCode+"</b>")
	return c.JSON(fiber.Map{"message": "OTP Resent"})
}

func GoogleLogin(c *fiber.Ctx) error {
	var data GoogleLoginRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	payload, err := idtoken.Validate(context.Background(), data.Token, os.Getenv("GOOGLE_CLIENT_ID"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid Google Token"})
	}

	email := payload.Claims["email"].(string)
	name := payload.Claims["name"].(string)
	sub := payload.Subject

	var user models.User
	result := config.DB.Where("email = ?", email).First(&user)

	if result.Error != nil {
		// Create new user
		user = models.User{
			ID:         uuid.New().String(),
			Email:      email,
			Name:       name,
			GoogleId:   &sub,
			IsVerified: true,
			Role:       models.RoleUser,
		}
		config.DB.Create(&user)
	} else {
		// Update existing
		if user.GoogleId == nil {
			config.DB.Model(&user).Update("google_id", sub)
		}
	}

	token, _ := utils.GenerateToken(user.ID, string(user.Role))
	return c.JSON(fiber.Map{"token": token, "user": user})
}

func ForgotPassword(c *fiber.Ctx) error {
	var data ForgotPasswordRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var user models.User
	if err := config.DB.Where("email = ?", data.Email).First(&user).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Email not found"})
	}

	resetToken := uuid.New().String()
	expiry := time.Now().Add(1 * time.Hour)
	config.DB.Model(&user).Updates(map[string]interface{}{
		"reset_token":        resetToken,
		"reset_token_expiry": expiry,
	})

	link := os.Getenv("CLIENT_URL") + "/reset-password?token=" + resetToken
	go sendEmail(user.Email, "Reset Password", "Klik link ini: <a href='"+link+"'>Reset Password</a>")

	return c.JSON(fiber.Map{"message": "Reset link sent"})
}

func ResetPassword(c *fiber.Ctx) error {
	var data ResetPasswordRequest
	if err := parseEncryptedBody(c, &data); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var user models.User
	if err := config.DB.Where("reset_token = ? AND reset_token_expiry > ?", data.Token, time.Now()).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid or expired token"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(data.NewPassword), 10)
	config.DB.Model(&user).Updates(map[string]interface{}{
		"password":           string(hashed),
		"reset_token":        nil,
		"reset_token_expiry": nil,
	})

	return c.JSON(fiber.Map{"message": "Password updated"})
}

func GetMe(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userId := claims["userId"].(string)

	var user models.User
	config.DB.First(&user, "id = ?", userId)
	return c.JSON(user)
}

func UpdateProfile(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userId := claims["userId"].(string)

	var req UpdateProfileRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	updates := map[string]interface{}{}
	if req.Name != "" { updates["name"] = req.Name }
	if req.Avatar != "" { updates["avatar"] = req.Avatar }

	if len(updates) > 0 {
		config.DB.Model(&models.User{}).Where("id = ?", userId).Updates(updates)
	}

	return c.JSON(fiber.Map{"message": "Profile updated"})
}

func UpdatePassword(c *fiber.Ctx) error {
	userToken := c.Locals("user").(*jwt.Token)
	claims := userToken.Claims.(jwt.MapClaims)
	userId := claims["userId"].(string)

	var req ChangePasswordRequest
	if err := parseEncryptedBody(c, &req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var user models.User
	config.DB.First(&user, "id = ?", userId)

	// Check Old Password
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.OldPassword)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Password lama salah"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.NewPassword), 10)
	config.DB.Model(&user).Update("password", string(hashed))

	return c.JSON(fiber.Map{"message": "Password updated"})
}

package handlers

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/services/email"
	"arfcoder-go/internal/utils"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"time"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

// ... (Existing functions: Register, Login, VerifyOtp, GoogleLogin - keeping them to ensure file integrity) ...

func Register(c *fiber.Ctx) error {
	type RegisterRequest struct {
		Email    string `json:"email"`
		Password string `json:"password"`
		Name     string `json:"name"`
	}

	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var existing models.User
	if err := database.DB.Where("email = ?", req.Email).First(&existing).Error; err == nil {
		return c.Status(400).JSON(fiber.Map{"message": "Email already exists"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.Password), 10)

	user := models.User{
		Email:    req.Email,
		Password: string(hashed),
		Name:     req.Name,
		Role:     models.RoleUser,
	}

	if err := database.DB.Create(&user).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to create user"})
	}

	otpCode := fmt.Sprintf("%06d", rand.Intn(1000000))
	database.DB.Create(&models.Otp{
		Code:      otpCode,
		Email:     req.Email,
		UserID:    user.ID,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	go email.SendEmail(req.Email, "Verifikasi Email ArfCoder", email.GenerateOtpEmail(req.Name, otpCode, "Verifikasi Email"))

	return c.Status(201).JSON(fiber.Map{
		"message": "User registered. Please check your email.",
		"userId":  user.ID,
	})
}

func Login(c *fiber.Ctx) error {
	type LoginRequest struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}

	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var user models.User
	if err := database.DB.Where("email = ?", req.Email).First(&user).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid credentials"})
	}

	if user.Password == "" { 
		return c.Status(400).JSON(fiber.Map{"message": "Invalid credentials"})
	}

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid credentials"})
	}

	if !user.IsVerified {
		return c.Status(403).JSON(fiber.Map{
			"message": "Please verify your email first",
			"userId":  user.ID,
		})
	}

	if user.Role == models.RoleAdmin || user.Role == models.RoleSuperAdmin {
		if c.Get("HX-Request") != "" {
			return c.Redirect("/verify-admin?userId=" + user.ID)
		}
		return c.Status(202).JSON(fiber.Map{
			"require2fa": true,
			"userId":     user.ID,
			"email":      user.Email,
			"message":    "2FA Verification Required",
		})
	}

	token, _ := utils.GenerateToken(user.ID, user.Role)
	refreshToken, _ := utils.GenerateRefreshToken(user.ID)

	// Set Cookie for Go Frontend
	c.Cookie(&fiber.Cookie{
		Name:     "auth_token",
		Value:    token,
		Expires:  time.Now().Add(7 * 24 * time.Hour),
		HTTPOnly: true,
		Secure:   config.MidtransIsProd == "true",
		SameSite: "Lax",
	})

	go database.DB.Create(&models.ActivityLog{
		UserID: user.ID,
		Action: "LOGIN",
		Details: "Login via Password",
		IPAddress: c.IP(),
	})

	if c.Get("HX-Request") != "" {
		return c.Redirect("/")
	}

	return c.JSON(fiber.Map{
		"token":        token,
		"refreshToken": refreshToken,
		"user": fiber.Map{
			"id":    user.ID,
			"email": user.Email,
			"name":  user.Name,
			"role":  user.Role,
		},
	})
}

func Logout(c *fiber.Ctx) error {
	c.ClearCookie("auth_token")
	if c.Get("HX-Request") != "" {
		return c.Redirect("/login")
	}
	return c.JSON(fiber.Map{"message": "Logged out"})
}

func VerifyOtp(c *fiber.Ctx) error {
	type VerifyRequest struct {
		UserID string `json:"userId"`
		Code   string `json:"code"`
	}
	var req VerifyRequest
	c.BodyParser(&req)

	var otp models.Otp
	if err := database.DB.Where("\"userId\" = ? AND code = ? AND \"expiresAt\" > ?", req.UserID, req.Code, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid or expired OTP"})
	}

	database.DB.Model(&models.User{}).Where("id = ?", req.UserID).Update("isVerified", true)
	database.DB.Delete(&otp)

	return c.JSON(fiber.Map{"message": "Email verified successfully"})
}

func GoogleLogin(c *fiber.Ctx) error {
	type GoogleRequest struct {
		Token string `json:"token"`
	}
	var req GoogleRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid Request"})
	}

	resp, err := http.Get("https://www.googleapis.com/oauth2/v3/tokeninfo?id_token=" + req.Token)
	if err != nil || resp.StatusCode != 200 {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid Google Token"})
	}
	defer resp.Body.Close()

	var payload struct {
		Email string `json:"email"`
		Name  string `json:"name"`
		Sub   string `json:"sub"`
		Aud   string `json:"aud"`
	}

	if err := json.NewDecoder(resp.Body).Decode(&payload); err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Error parsing Google response"})
	}

	if config.GoogleClientID != "" && payload.Aud != config.GoogleClientID {
		return c.Status(403).JSON(fiber.Map{"message": "Token audience mismatch"})
	}

	var user models.User
	result := database.DB.Where("email = ?", payload.Email).First(&user)

	if result.Error != nil {
		user = models.User{
			Email:      payload.Email,
			Name:       payload.Name,
			GoogleID:   payload.Sub,
			Role:       models.RoleUser,
			IsVerified: true,
		}
		database.DB.Create(&user)
	} else {
		if user.GoogleID == "" {
			database.DB.Model(&user).Updates(models.User{
				GoogleID:   payload.Sub,
				IsVerified: true,
			})
		}
	}

	token, _ := utils.GenerateToken(user.ID, user.Role)
	refreshToken, _ := utils.GenerateRefreshToken(user.ID)

	// Set Cookie
	c.Cookie(&fiber.Cookie{
		Name:     "auth_token",
		Value:    token,
		Expires:  time.Now().Add(7 * 24 * time.Hour),
		HTTPOnly: true,
		Secure:   config.MidtransIsProd == "true",
		SameSite: "Lax",
	})

	go database.DB.Create(&models.ActivityLog{
		UserID: user.ID,
		Action: "LOGIN",
		Details: "Login via Google",
		IPAddress: c.IP(),
	})

	return c.JSON(fiber.Map{
		"token":        token,
		"refreshToken": refreshToken,
		"user": fiber.Map{
			"id":    user.ID,
			"email": user.Email,
			"name":  user.Name,
			"role":  user.Role,
		},
	})
}

// [FIX]: Added missing legacy OTP Login handler
func VerifyLoginOtp(c *fiber.Ctx) error {
	type Req struct {
		UserID string `json:"userId"`
		Code   string `json:"code"`
	}
	var req Req
	c.BodyParser(&req)

	var otp models.Otp
	if err := database.DB.Where("\"userId\" = ? AND code = ? AND \"expiresAt\" > ?", req.UserID, req.Code, time.Now()).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid or expired OTP"})
	}

	var user models.User
	if err := database.DB.First(&user, "id = ?", req.UserID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	token, _ := utils.GenerateToken(user.ID, user.Role)
	refreshToken, _ := utils.GenerateRefreshToken(user.ID)

	// Clean up OTP
	database.DB.Delete(&otp)

	go database.DB.Create(&models.ActivityLog{
		UserID: user.ID,
		Action: "LOGIN",
		Details: "Login via OTP (Legacy)",
		IPAddress: c.IP(),
	})

	return c.JSON(fiber.Map{
		"token":        token,
		"refreshToken": refreshToken,
		"user": fiber.Map{
			"id":    user.ID,
			"email": user.Email,
			"name":  user.Name,
			"role":  user.Role,
		},
	})
}

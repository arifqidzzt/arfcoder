package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/services/whatsapp"
	"arfcoder-go/internal/utils"
	"fmt"
	"math/rand"
	"time"

	"github.com/gofiber/fiber/v2"
	"golang.org/x/crypto/bcrypt"
)

// --- USER PROFILE ---

func GetProfile(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	
	// Lazy Auto-Cancel
	yesterday := time.Now().Add(-24 * time.Hour)
	database.DB.Model(&models.Order{}).Where("\"userId\" = ? AND status = ? AND \"createdAt\" < ?", userClaims.UserID, models.OrderStatusPending, yesterday).Update("status", models.OrderStatusCancelled)

	var user models.User
	if err := database.DB.First(&user, "id = ?", userClaims.UserID).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "User not found"})
	}

	// Calculate Spending
	var totalSpent float64
	database.DB.Model(&models.Order{}).Where("\"userId\" = ? AND status IN ?", user.ID, []string{models.OrderStatusPaid, models.OrderStatusProcessing, models.OrderStatusShipped, models.OrderStatusCompleted}).Select("COALESCE(SUM(\"totalAmount\"), 0)").Scan(&totalSpent)

	return c.JSON(fiber.Map{
		"id":               user.ID,
		"name":             user.Name,
		"email":            user.Email,
		"avatar":           user.Avatar,
		"phoneNumber":      user.PhoneNumber,
		"role":             user.Role,
		"twoFactorEnabled": user.TwoFactorEnabled,
		"totalSpent":       totalSpent,
	})
}

func UpdateProfile(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		Name        string `json:"name"`
		Avatar      string `json:"avatar"`
		PhoneNumber string `json:"phoneNumber"`
	}
	var req Req
	c.BodyParser(&req)

	database.DB.Model(&models.User{}).Where("id = ?", userClaims.UserID).Updates(models.User{
		Name:        req.Name,
		Avatar:      req.Avatar,
		PhoneNumber: req.PhoneNumber,
	})
	
	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)
	return c.JSON(user)
}

func UpdatePhoneDirect(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		PhoneNumber string `json:"phoneNumber"`
	}
	var req Req
	c.BodyParser(&req)

	database.DB.Model(&models.User{}).Where("id = ?", userClaims.UserID).Update("phoneNumber", req.PhoneNumber)
	
	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)
	return c.JSON(user)
}

func ChangePassword(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		OldPassword string `json:"oldPassword"`
		NewPassword string `json:"newPassword"`
	}
	var req Req
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.OldPassword)); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Password lama salah"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.NewPassword), 10)
	database.DB.Model(&user).Update("password", string(hashed))

	return c.JSON(fiber.Map{"message": "Password berhasil diubah"})
}

// --- PHONE CHANGE (OTP FLOW) ---

func RequestPhoneChange(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	var user models.User
	database.DB.First(&user, "id = ?", userClaims.UserID)

	if user.PhoneNumber == "" {
		return c.JSON(fiber.Map{"message": "Langsung verifikasi nomor baru", "skipOld": true})
	}

	otpCode := fmt.Sprintf("%06d", rand.Intn(1000000))
	whatsapp.SendMessage(user.PhoneNumber, "Kode Ganti HP: "+otpCode)

	database.DB.Create(&models.Otp{
		Code:      otpCode,
		UserID:    user.ID,
		Email:     "old_" + user.PhoneNumber,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	return c.JSON(fiber.Map{"message": "OTP dikirim ke WhatsApp lama", "skipOld": false})
}

func RequestNewPhoneOtp(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		NewPhoneNumber string `json:"newPhoneNumber"`
	}
	var req Req
	c.BodyParser(&req)

	otpCode := fmt.Sprintf("%06d", rand.Intn(1000000))
	whatsapp.SendMessage(req.NewPhoneNumber, "Kode Ganti HP Baru: "+otpCode)

	database.DB.Create(&models.Otp{
		Code:      otpCode,
		UserID:    userClaims.UserID,
		Email:     "new_" + req.NewPhoneNumber,
		ExpiresAt: time.Now().Add(5 * time.Minute),
	})

	return c.JSON(fiber.Map{"message": "OTP dikirim ke WhatsApp baru"})
}

func VerifyNewPhone(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		Code           string `json:"code"`
		NewPhoneNumber string `json:"newPhoneNumber"`
	}
	var req Req
	c.BodyParser(&req)

	var otp models.Otp
	if err := database.DB.Where("\"userId\" = ? AND code = ? AND email = ?", userClaims.UserID, req.Code, "new_"+req.NewPhoneNumber).First(&otp).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "OTP Salah"})
	}

	database.DB.Delete(&otp)
	database.DB.Model(&models.User{}).Where("id = ?", userClaims.UserID).Update("phoneNumber", req.NewPhoneNumber)

	return c.JSON(fiber.Map{"message": "Nomor WhatsApp berhasil disimpan!"})
}

// --- REVIEWS ---

func CreateReview(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	type Req struct {
		ProductId string `json:"productId"`
		Rating    int    `json:"rating"`
		Comment   string `json:"comment"`
	}
	var req Req
	c.BodyParser(&req)

	// Check Purchase
	var orders []models.Order
	database.DB.Preload("Items").Where("\"userId\" = ? AND status = ?", userClaims.UserID, models.OrderStatusCompleted).Find(&orders)
	
hasPurchased := false
	for _, o := range orders {
		for _, i := range o.Items {
			if i.ProductID == req.ProductId {
				hasPurchased = true
				break
			}
		}
	}

	if !hasPurchased {
		return c.Status(403).JSON(fiber.Map{"message": "Anda harus membeli produk ini sebelum memberi ulasan."} )
	}

	// Check Duplicate
	var existing int64
	database.DB.Model(&models.Review{}).Where("\"userId\" = ? AND \"productId\" = ?", userClaims.UserID, req.ProductId).Count(&existing)
	if existing > 0 {
		return c.Status(400).JSON(fiber.Map{"message": "Anda sudah mengulas produk ini."}) 
	}

	review := models.Review{
		UserID:    userClaims.UserID,
		ProductID: req.ProductId,
		Rating:    req.Rating,
		Comment:   req.Comment,
	}
	database.DB.Create(&review)

	return c.Status(201).JSON(review)
}

func GetProductReviews(c *fiber.Ctx) error {
	productId := c.Params("productId")
	var reviews []models.Review
	database.DB.Preload("User").Where("\"productId\" = ? AND \"isVisible\" = ?", productId, true).Order("\"createdAt\" desc").Find(&reviews)
	return c.JSON(reviews)
}

// --- LOGS ---
func GetLogs(c *fiber.Ctx) error {
	var logs []models.ActivityLog
	database.DB.Preload("User").Order("\"createdAt\" desc").Limit(100).Find(&logs)
	return c.JSON(logs)
}

// --- MISSING HANDLERS ---
func VerifyOldEmail(c *fiber.Ctx) error { return nil }
func VerifyOldPhone(c *fiber.Ctx) error { return nil }
func RequestEmailChange(c *fiber.Ctx) error { return nil }
func VerifyNewEmail(c *fiber.Ctx) error { return nil }
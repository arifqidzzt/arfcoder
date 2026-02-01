package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"

	"github.com/gofiber/fiber/v2"
)

// SendMessage handles the chat logic via REST.
// It replicates the Socket.IO "sendMessage" event logic:
// 1. Check Anti-Spam (if not admin)
// 2. Save Message
// 3. Mark Read (if admin)
func SendMessage(c *fiber.Ctx) error {
	var req struct {
		Content      string `json:"content"`
		SenderID     string `json:"senderId"` // Usually from Token, but sticking to Node payload
		IsAdmin      bool   `json:"isAdmin"`
		TargetUserID string `json:"targetUserId"` // For admin replying
	}
	
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Invalid request"})
	}

	// Validate Sender if not Admin (Security Check)
	userClaims, ok := c.Locals("user").(*utils.JWTClaims)
	if ok && !req.IsAdmin && userClaims.UserID != req.SenderID {
		return c.Status(403).JSON(fiber.Map{"message": "Sender ID mismatch"})
	}

	// 1. Anti-Spam Check (Non-Admin)
	if !req.IsAdmin {
		var lastMessages []models.Message
		database.DB.Where("\"senderId\" = ?", req.SenderID).Order("\"createdAt\" desc").Limit(11).Find(&lastMessages)

		unrepliedCount := -1
		for i, msg := range lastMessages {
			if msg.IsAdmin {
				unrepliedCount = i
				break
			}
		}

		if unrepliedCount == -1 && len(lastMessages) >= 10 {
			return c.Status(429).JSON(fiber.Map{"message": "Batas pesan tercapai. Tunggu balasan admin."})
		}
	}

	// 2. Save Message
	msg := models.Message{
		Content:      req.Content,
		SenderID:     req.SenderID,
		IsAdmin:      req.IsAdmin,
		IsRead:       false,
		TargetUserID: req.TargetUserID,
	}
	
	if err := database.DB.Create(&msg).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Failed to save message"})
	}

	// 3. Mark Read (If Admin replying)
	if req.IsAdmin && req.TargetUserID != "" {
		database.DB.Model(&models.Message{}).
			Where("\"senderId\" = ? AND \"isAdmin\" = ?", req.TargetUserID, false).
			Update("isRead", true)
	}

	return c.Status(201).JSON(msg)
}

package handlers

import (
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"arfcoder-go/internal/utils"

	"github.com/gofiber/fiber/v2"
)

// Simplified Chat Handler for REST History
// Socket.IO logic is handled separately or via new WebSocket implementation later
func GetUserChatHistory(c *fiber.Ctx) error {
	userClaims := c.Locals("user").(*utils.JWTClaims)
	targetUserId := c.Params("userId")

	// Logic: Fetch messages where sender is Target OR sender is Admin (to Target)
	// Actually Node logic: senderId = userId OR (senderId = me AND isAdmin)
	// Node params: :userId is usually the user we are looking at.
	// If Admin requests, they want chat with `targetUserId`.
	// If User requests, they want their own chat.
	
	queryUserId := targetUserId
	if queryUserId == "me" || queryUserId == "" {
		queryUserId = userClaims.UserID
	}

	var messages []models.Message
	// Select * FROM messages WHERE (sender_id = X) OR (target_user_id = X AND is_admin = true)
	// Simplified approximation of Node logic:
	database.DB.Where("(\"senderId\" = ?) OR (\"targetUserId\" = ?)", queryUserId, queryUserId).Order("\"createdAt\" asc").Find(&messages)
	
	return c.JSON(messages)
}

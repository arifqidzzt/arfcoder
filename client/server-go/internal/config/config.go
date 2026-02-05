package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

var (
	Port               string
	DatabaseURL        string
	JWTSecret          string
	RefreshTokenSecret string
	AppSecretKey       string
	MidtransServerKey  string
	MidtransClientKey  string
	MidtransIsProd     string
	ResendAPIKey       string
	GoogleClientID     string
	EmailFrom          string
	ClientURL          string
)

func LoadConfig() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	Port = getEnv("PORT", "5000")
	DatabaseURL = getEnv("DATABASE_URL", "")
	JWTSecret = getEnv("JWT_SECRET", "secret")
	RefreshTokenSecret = getEnv("REFRESH_TOKEN_SECRET", "refresh_secret")
	AppSecretKey = getEnv("APP_SECRET_KEY", "default-secret-key-change-me")
	MidtransServerKey = getEnv("MIDTRANS_SERVER_KEY", "")
	MidtransClientKey = getEnv("MIDTRANS_CLIENT_KEY", "")
	MidtransIsProd = getEnv("MIDTRANS_IS_PRODUCTION", "false")
	ResendAPIKey = getEnv("RESEND_API_KEY", "")
	GoogleClientID = getEnv("GOOGLE_CLIENT_ID", "")
	EmailFrom = getEnv("EMAIL_FROM", "onboarding@resend.dev")
	ClientURL = getEnv("CLIENT_URL", "http://localhost:3000")
}

func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return fallback
}

package database

import (
	"arfcoder-go/internal/config"
	"log"
	"strings"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

var DB *gorm.DB

func Connect() {
	dsn := config.DatabaseURL
	if dsn == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	// [FIX] Force SSL Mode Disable if local/IP access causes hang
	// Many Postgres instances (especially Docker/Local/Self-hosted) hang if SSL is expected but not provided.
	if !strings.Contains(dsn, "sslmode=") {
		if strings.Contains(dsn, "?") {
			dsn += "&sslmode=disable"
		} else {
			dsn += "?sslmode=disable"
		}
	}

	var err error
	DB, err = gorm.Open(postgres.Open(dsn), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
		NowFunc: func() time.Time {
			return time.Now().Local()
		},
	})

	if err != nil {
		log.Fatalf("Failed to connect to database: %v", err)
	}

	// [FIX] Connection Pool Settings (Prevent Connection Leak/Timeout)
	sqlDB, err := DB.DB()
	if err != nil {
		log.Fatalf("Failed to get SQL DB: %v", err)
	}

	// SetMaxIdleConns sets the maximum number of connections in the idle connection pool.
	sqlDB.SetMaxIdleConns(10)
	// SetMaxOpenConns sets the maximum number of open connections to the database.
	sqlDB.SetMaxOpenConns(100)
	// SetConnMaxLifetime sets the maximum amount of time a connection may be reused.
	sqlDB.SetConnMaxLifetime(time.Hour)

	log.Println("Database connected successfully (Pool Configured)")
}
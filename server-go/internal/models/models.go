package models

import (
	"time"
)

// Enums (mapped as strings)
const (
	RoleUser       = "USER"
	RoleAdmin      = "ADMIN"
	RoleSuperAdmin = "SUPER_ADMIN"
)

const (
	ProductTypeBarang = "BARANG"
	ProductTypeJasa   = "JASA"
)

const (
	OrderStatusPending         = "PENDING"
	OrderStatusPaid            = "PAID"
	OrderStatusProcessing      = "PROCESSING"
	OrderStatusShipped         = "SHIPPED"
	OrderStatusCompleted       = "COMPLETED"
	OrderStatusCancelled       = "CANCELLED"
	OrderStatusRefundRequested = "REFUND_REQUESTED"
	OrderStatusRefundApproved  = "REFUND_APPROVED"
	OrderStatusRefundCompleted = "REFUND_COMPLETED"
	OrderStatusRefundRejected  = "REFUND_REJECTED"
)

const (
	DiscountTypePercent = "PERCENT"
	DiscountTypeFixed   = "FIXED"
)

type User struct {
	ID               string    `gorm:"primaryKey;default:gen_random_uuid()"` // Assuming Postgres gen_random_uuid or handling ID generation in app
	Email            string    `gorm:"uniqueIndex;not null"`
	Password         string    `gorm:"type:text"`
	Name             string
	Role             string    `gorm:"default:'USER'"`
	IsVerified       bool      `gorm:"default:false"`
	GoogleID         string    `gorm:"uniqueIndex"`
	Avatar           string
	PhoneNumber      string
	ResetToken       string
	ResetTokenExpiry *time.Time
	TwoFactorSecret  string
	TwoFactorEnabled bool      `gorm:"default:false"`
	CreatedAt        time.Time `gorm:"autoCreateTime"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime"`

	// Relations
	Otps         []Otp         `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Orders       []Order       `gorm:"foreignKey:UserID"`
	CartItems    []CartItem    `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Reviews      []Review      `gorm:"foreignKey:UserID"`
	ActivityLogs []ActivityLog `gorm:"foreignKey:UserID"`
}

type ActivityLog struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid()"`
	UserID    string    `gorm:"not null"`
	User      User      `gorm:"foreignKey:UserID"`
	Action    string    `gorm:"not null"`
	Details   string
	IPAddress string
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

type Otp struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid()"`
	Code      string    `gorm:"not null"`
	Email     string    `gorm:"not null"`
	UserID    string    `gorm:"not null"`
	ExpiresAt time.Time `gorm:"not null"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

type Category struct {
	ID       string    `gorm:"primaryKey;default:gen_random_uuid()"`
	Name     string    `gorm:"uniqueIndex;not null"`
	Products []Product `gorm:"foreignKey:CategoryID"`
}

type Product struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid()"`
	Name        string    `gorm:"not null"`
	Description string    `gorm:"type:text"`
	Price       float64   `gorm:"not null"`
	Discount    float64   `gorm:"default:0"`
	Stock       int       `gorm:"default:0"`
	Type        string    `gorm:"default:'BARANG'"` // ProductType
	Images      []string  `gorm:"type:text[]"`      // GORM Postgres array support
	CategoryID  *string
	Category    Category  `gorm:"foreignKey:CategoryID"`
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`

	CartItems  []CartItem  `gorm:"foreignKey:ProductID"`
	OrderItems []OrderItem `gorm:"foreignKey:ProductID"`
	Reviews    []Review    `gorm:"foreignKey:ProductID"`
	FlashSales []FlashSale `gorm:"foreignKey:ProductID"`
}

type Service struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid()"`
	Title       string    `gorm:"not null"`
	Description string    `gorm:"type:text"`
	Price       string    `gorm:"not null"`
	Icon        string
	CreatedAt   time.Time `gorm:"autoCreateTime"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime"`
}

type CartItem struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid()"`
	UserID    string    `gorm:"not null;uniqueIndex:idx_cart_user_product"`
	User      User      `gorm:"foreignKey:UserID"`
	ProductID string    `gorm:"not null;uniqueIndex:idx_cart_user_product"`
	Product   Product   `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE"`
	Quantity  int       `gorm:"default:1"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
	UpdatedAt time.Time `gorm:"autoUpdateTime"`
}

type Order struct {
	ID            string    `gorm:"primaryKey;default:gen_random_uuid()"`
	InvoiceNumber string    `gorm:"uniqueIndex;not null"`
	UserID        string    `gorm:"not null"`
	User          User      `gorm:"foreignKey:UserID"`
	TotalAmount   float64   `gorm:"not null"`
	Status        string    `gorm:"default:'PENDING'"`
	PaymentType   string
	SnapToken     string
	SnapUrl       string
	Address       string
	DeliveryInfo  string
	RefundReason  string
	RefundAccount string
	RefundProof   string
	DiscountApplied float64 `gorm:"default:0"`
	VoucherCode     string

	Items     []OrderItem     `gorm:"foreignKey:OrderID"`
	Timeline  []OrderTimeline `gorm:"foreignKey:OrderID"`
	CreatedAt time.Time       `gorm:"autoCreateTime"`
	UpdatedAt time.Time       `gorm:"autoUpdateTime"`
}

type OrderItem struct {
	ID        string  `gorm:"primaryKey;default:gen_random_uuid()"`
	OrderID   string  `gorm:"not null"`
	ProductID string  `gorm:"not null"`
	Product   Product `gorm:"foreignKey:ProductID"`
	Quantity  int     `gorm:"not null"`
	Price     float64 `gorm:"not null"`
}

type OrderTimeline struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid()"`
	OrderID     string    `gorm:"not null"`
	Title       string    `gorm:"not null"`
	Description string
	Timestamp   time.Time `gorm:"default:now()"`
}

type Message struct {
	ID           string    `gorm:"primaryKey;default:gen_random_uuid()"`
	Content      string    `gorm:"type:text;not null"`
	SenderID     string    `gorm:"not null"`
	Sender       User      `gorm:"foreignKey:SenderID"`
	IsAdmin      bool      `gorm:"default:false"`
	IsRead       bool      `gorm:"default:false"`
	TargetUserID string
	CreatedAt    time.Time `gorm:"autoCreateTime"`
}

type Voucher struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid()"`
	Code        string    `gorm:"uniqueIndex;not null"`
	Type        string    `gorm:"default:'FIXED'"`
	Value       float64   `gorm:"not null"`
	MinPurchase float64   `gorm:"default:0"`
	MaxDiscount float64
	StartDate   time.Time `gorm:"default:now()"`
	ExpiresAt   time.Time `gorm:"not null"`
	UsageLimit  int       `gorm:"default:0"`
	UsedCount   int       `gorm:"default:0"`
	IsActive    bool      `gorm:"default:true"`
	CreatedAt   time.Time `gorm:"autoCreateTime"`
}

type FlashSale struct {
	ID            string    `gorm:"primaryKey;default:gen_random_uuid()"`
	ProductID     string    `gorm:"not null"`
	Product       Product   `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE"`
	DiscountPrice float64   `gorm:"not null"`
	StartTime     time.Time `gorm:"not null"`
	EndTime       time.Time `gorm:"not null"`
	IsActive      bool      `gorm:"default:true"`
	CreatedAt     time.Time `gorm:"autoCreateTime"`
}

type Review struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid()"`
	UserID    string    `gorm:"not null"`
	User      User      `gorm:"foreignKey:UserID"`
	ProductID string    `gorm:"not null"`
	Product   Product   `gorm:"foreignKey:ProductID"`
	Rating    int       `gorm:"not null"`
	Comment   string    `gorm:"type:text"`
	IsVisible bool      `gorm:"default:true"`
	CreatedAt time.Time `gorm:"autoCreateTime"`
}

package models

import (
	"time"
)

type ProductType string
type OrderStatus string
type Role string

const (
	TypeBarang ProductType = "BARANG"
	TypeJasa   ProductType = "JASA"
)

const (
	StatusPending   OrderStatus = "PENDING"
	StatusPaid      OrderStatus = "PAID"
	StatusProcessing OrderStatus = "PROCESSING"
	StatusShipped   OrderStatus = "SHIPPED"
	StatusCompleted OrderStatus = "COMPLETED"
	StatusCancelled OrderStatus = "CANCELLED"
	StatusRefundReq OrderStatus = "REFUND_REQUESTED"
	StatusRefundApp OrderStatus = "REFUND_APPROVED"
	StatusRefundCom OrderStatus = "REFUND_COMPLETED"
	StatusRefundRej OrderStatus = "REFUND_REJECTED"
)

const (
	RoleUser       Role = "USER"
	RoleAdmin      Role = "ADMIN"
	RoleSuperAdmin Role = "SUPER_ADMIN"
)

// User
type User struct {
	ID               string    `gorm:"primaryKey;type:text" json:"id"`
	Email            string    `gorm:"uniqueIndex;not null" json:"email"`
	Password         string    `json:"-"`
	Name             string    `json:"name"`
	Role             Role      `gorm:"default:'USER'" json:"role"`
	IsVerified       bool      `gorm:"default:false" json:"isVerified"`
	GoogleId         *string   `gorm:"uniqueIndex" json:"googleId"`
	Avatar           *string   `json:"avatar"`
	PhoneNumber      *string   `json:"phoneNumber"`
	ResetToken       *string   `json:"-"`
	ResetTokenExpiry *time.Time `json:"-"`
	CreatedAt        time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}
func (User) TableName() string { return "User" }

// OTP
type Otp struct {
	ID        string    `gorm:"primaryKey;type:text" json:"id"`
	Code      string    `json:"code"`
	Email     string    `json:"email"`
	UserId    string    `json:"userId"`
	User      User      `gorm:"foreignKey:UserId" json:"user"`
	ExpiresAt time.Time `json:"expiresAt"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"createdAt"`
}
func (Otp) TableName() string { return "Otp" }

// Product
type Product struct {
	ID          string      `gorm:"primaryKey;type:text" json:"id"`
	Name        string      `json:"name"`
	Description string      `json:"description"`
	Price       float64     `json:"price"`
	Discount    float64     `gorm:"default:0" json:"discount"`
	Stock       int         `gorm:"default:0" json:"stock"`
	Type        ProductType `gorm:"default:'BARANG'" json:"type"`
	Images      []string    `gorm:"type:text[]" json:"images"`
	CategoryId  *string     `json:"categoryId"`
	CreatedAt   time.Time   `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt   time.Time   `gorm:"autoUpdateTime" json:"updatedAt"`
}
func (Product) TableName() string { return "Product" }

// Order
type Order struct {
	ID            string      `gorm:"primaryKey;type:text" json:"id"`
	InvoiceNumber string      `gorm:"unique" json:"invoiceNumber"`
	UserId        string      `json:"userId"`
	User          User        `gorm:"foreignKey:UserId" json:"user"`
	TotalAmount   float64     `json:"totalAmount"`
	Status        OrderStatus `gorm:"default:'PENDING'" json:"status"`
	PaymentType   *string     `json:"paymentType"`
	SnapToken     *string     `json:"snapToken"`
	SnapUrl       *string     `json:"snapUrl"`
	Address       *string     `json:"address"`
	DeliveryInfo  *string     `json:"deliveryInfo"`
	RefundReason  *string     `json:"refundReason"`
	RefundAccount *string     `json:"refundAccount"`
	RefundProof   *string     `json:"refundProof"`
	Items         []OrderItem `gorm:"foreignKey:OrderId" json:"items"`
	CreatedAt     time.Time   `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt     time.Time   `gorm:"autoUpdateTime" json:"updatedAt"`
}
func (Order) TableName() string { return "Order" }

// OrderItem
type OrderItem struct {
	ID        string  `gorm:"primaryKey;type:text" json:"id"`
	OrderId   string  `json:"orderId"`
	ProductId string  `json:"productId"`
	Product   Product `gorm:"foreignKey:ProductId" json:"product"`
	Quantity  int     `json:"quantity"`
	Price     float64 `json:"price"`
}
func (OrderItem) TableName() string { return "OrderItem" }

// Service
type Service struct {
	ID          string    `gorm:"primaryKey;type:text" json:"id"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Price       string    `json:"price"` 
	Icon        string    `json:"icon"`
	CreatedAt   time.Time `gorm:"autoCreateTime" json:"createdAt"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime" json:"updatedAt"`
}
func (Service) TableName() string { return "Service" }

// Message
type Message struct {
	ID           string    `gorm:"primaryKey;type:text" json:"id"`
	Content      string    `json:"content"`
	SenderId     string    `json:"senderId"`
	Sender       User      `gorm:"foreignKey:SenderId" json:"sender"`
	IsAdmin      bool      `gorm:"default:false" json:"isAdmin"`
	IsRead       bool      `gorm:"default:false" json:"isRead"`
	TargetUserId *string   `json:"targetUserId"`
	CreatedAt    time.Time `gorm:"autoCreateTime" json:"createdAt"`
}
func (Message) TableName() string { return "Message" }
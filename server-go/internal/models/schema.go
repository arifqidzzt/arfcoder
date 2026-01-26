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
	ID               string    `gorm:"primaryKey;type:text;column:id" json:"id"`
	Email            string    `gorm:"uniqueIndex;not null;column:email" json:"email"`
	Password         string    `gorm:"column:password" json:"-"`
	Name             string    `gorm:"column:name" json:"name"`
	Role             Role      `gorm:"default:'USER';column:role" json:"role"`
	IsVerified       bool      `gorm:"default:false;column:isVerified" json:"isVerified"`
	GoogleId         *string   `gorm:"uniqueIndex;column:googleId" json:"googleId"`
	Avatar           *string   `gorm:"column:avatar" json:"avatar"`
	PhoneNumber      *string   `gorm:"column:phoneNumber" json:"phoneNumber"`
	ResetToken       *string   `gorm:"column:resetToken" json:"-"`
	ResetTokenExpiry *time.Time `gorm:"column:resetTokenExpiry" json:"-"`
	CreatedAt        time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}
func (User) TableName() string { return "User" }

// OTP
type Otp struct {
	ID        string    `gorm:"primaryKey;type:text;column:id" json:"id"`
	Code      string    `gorm:"column:code" json:"code"`
	Email     string    `gorm:"column:email" json:"email"`
	UserId    string    `gorm:"column:userId" json:"userId"`
	User      User      `gorm:"foreignKey:UserId;references:ID" json:"user"`
	ExpiresAt time.Time `gorm:"column:expiresAt" json:"expiresAt"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}
func (Otp) TableName() string { return "Otp" }

// Product
type Product struct {
	ID          string      `gorm:"primaryKey;type:text;column:id" json:"id"`
	Name        string      `gorm:"column:name" json:"name"`
	Description string      `gorm:"column:description" json:"description"`
	Price       float64     `gorm:"column:price" json:"price"`
	Discount    float64     `gorm:"default:0;column:discount" json:"discount"`
	Stock       int         `gorm:"default:0;column:stock" json:"stock"`
	Type        ProductType `gorm:"default:'BARANG';column:type" json:"type"`
	Images      []string    `gorm:"type:text[];column:images" json:"images"`
	CategoryId  *string     `gorm:"column:categoryId" json:"categoryId"`
	CreatedAt   time.Time   `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt   time.Time   `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}
func (Product) TableName() string { return "Product" }

// Order
type Order struct {
	ID            string      `gorm:"primaryKey;type:text;column:id" json:"id"`
	InvoiceNumber string      `gorm:"unique;column:invoiceNumber" json:"invoiceNumber"`
	UserId        string      `gorm:"column:userId" json:"userId"`
	User          User        `gorm:"foreignKey:UserId;references:ID" json:"user"`
	TotalAmount   float64     `gorm:"column:totalAmount" json:"totalAmount"`
	Status        OrderStatus `gorm:"default:'PENDING';column:status" json:"status"`
	PaymentType   *string     `gorm:"column:paymentType" json:"paymentType"`
	SnapToken     *string     `gorm:"column:snapToken" json:"snapToken"`
	SnapUrl       *string     `gorm:"column:snapUrl" json:"snapUrl"`
	Address       *string     `gorm:"column:address" json:"address"`
	DeliveryInfo  *string     `gorm:"column:deliveryInfo" json:"deliveryInfo"`
	RefundReason  *string     `gorm:"column:refundReason" json:"refundReason"`
	RefundAccount *string     `gorm:"column:refundAccount" json:"refundAccount"`
	RefundProof   *string     `gorm:"column:refundProof" json:"refundProof"`
	Items         []OrderItem `gorm:"foreignKey:OrderId;references:ID" json:"items"`
	CreatedAt     time.Time   `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt     time.Time   `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}
func (Order) TableName() string { return "Order" }

// OrderItem
type OrderItem struct {
	ID        string  `gorm:"primaryKey;type:text;column:id" json:"id"`
	OrderId   string  `gorm:"column:orderId" json:"orderId"`
	ProductId string  `gorm:"column:productId" json:"productId"`
	Product   Product `gorm:"foreignKey:ProductId;references:ID" json:"product"`
	Quantity  int     `gorm:"column:quantity" json:"quantity"`
	Price     float64 `gorm:"column:price" json:"price"`
}
func (OrderItem) TableName() string { return "OrderItem" }

// Service
type Service struct {
	ID          string    `gorm:"primaryKey;type:text;column:id" json:"id"`
	Title       string    `gorm:"column:title" json:"title"`
	Description string    `gorm:"column:description" json:"description"`
	Price       string    `gorm:"column:price" json:"price"` 
	Icon        string    `gorm:"column:icon" json:"icon"`
	CreatedAt   time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}
func (Service) TableName() string { return "Service" }

// Message
type Message struct {
	ID           string    `gorm:"primaryKey;type:text;column:id" json:"id"`
	Content      string    `gorm:"column:content" json:"content"`
	SenderId     string    `gorm:"column:senderId" json:"senderId"`
	Sender       User      `gorm:"foreignKey:SenderId;references:ID" json:"sender"`
	IsAdmin      bool      `gorm:"default:false;column:isAdmin" json:"isAdmin"`
	IsRead       bool      `gorm:"default:false;column:isRead" json:"isRead"`
	TargetUserId *string   `gorm:"column:targetUserId" json:"targetUserId"`
	CreatedAt    time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}
func (Message) TableName() string { return "Message" }
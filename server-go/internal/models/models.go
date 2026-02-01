package models

import (
	"time"
	"github.com/lib/pq"
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
	ID               string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Email            string    `gorm:"uniqueIndex;not null;column:email"`
	Password         string    `gorm:"type:text;column:password"`
	Name             string    `gorm:"column:name"`
	Role             string    `gorm:"default:'USER';column:role"`
	IsVerified       bool      `gorm:"default:false;column:isVerified"`
	GoogleID         string    `gorm:"uniqueIndex;column:googleId"`
	Avatar           string    `gorm:"column:avatar"`
	PhoneNumber      string    `gorm:"column:phoneNumber"`
	ResetToken       string    `gorm:"column:resetToken"`
	ResetTokenExpiry *time.Time `gorm:"column:resetTokenExpiry"`
	TwoFactorSecret  string    `gorm:"column:twoFactorSecret"`
	TwoFactorEnabled bool      `gorm:"default:false;column:twoFactorEnabled"`
	CreatedAt        time.Time `gorm:"autoCreateTime;column:createdAt"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime;column:updatedAt"`

	// Relations
	Otps         []Otp         `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Orders       []Order       `gorm:"foreignKey:UserID"`
	CartItems    []CartItem    `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE"`
	Reviews      []Review      `gorm:"foreignKey:UserID"`
	ActivityLogs []ActivityLog `gorm:"foreignKey:UserID"`
}

func (User) TableName() string {
	return "User"
}

type ActivityLog struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	UserID    string    `gorm:"not null;column:userId"`
	User      User      `gorm:"foreignKey:UserID"`
	Action    string    `gorm:"not null;column:action"`
	Details   string    `gorm:"column:details"`
	IPAddress string    `gorm:"column:ipAddress"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt"`
}

func (ActivityLog) TableName() string {
	return "ActivityLog"
}

type Otp struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Code      string    `gorm:"not null;column:code"`
	Email     string    `gorm:"not null;column:email"`
	UserID    string    `gorm:"not null;column:userId"`
	ExpiresAt time.Time `gorm:"not null;column:expiresAt"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt"`
}

func (Otp) TableName() string {
	return "Otp"
}

type Category struct {
	ID       string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Name     string    `gorm:"uniqueIndex;not null;column:name"`
	Products []Product `gorm:"foreignKey:CategoryID"`
}

func (Category) TableName() string {
	return "Category"
}

type Product struct {
	ID          string         `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Name        string         `gorm:"not null;column:name"`
	Description string         `gorm:"type:text;column:description"`
	Price       float64        `gorm:"not null;column:price"`
	Discount    float64        `gorm:"default:0;column:discount"`
	Stock       int            `gorm:"default:0;column:stock"`
	Type        string         `gorm:"default:'BARANG';column:type"`
	Images      pq.StringArray `gorm:"type:text[];column:images"` // Fixed: Use pq.StringArray
	CategoryID  *string        `gorm:"column:categoryId"`
	Category    Category       `gorm:"foreignKey:CategoryID"`
	CreatedAt   time.Time      `gorm:"autoCreateTime;column:createdAt"`
	UpdatedAt   time.Time      `gorm:"autoUpdateTime;column:updatedAt"`

	CartItems  []CartItem  `gorm:"foreignKey:ProductID"`
	OrderItems []OrderItem `gorm:"foreignKey:ProductID"`
	Reviews    []Review    `gorm:"foreignKey:ProductID"`
	FlashSales []FlashSale `gorm:"foreignKey:ProductID"`
}

func (Product) TableName() string {
	return "Product"
}

type Service struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Title       string    `gorm:"not null;column:title"`
	Description string    `gorm:"type:text;column:description"`
	Price       string    `gorm:"not null;column:price"`
	Icon        string    `gorm:"column:icon"`
	CreatedAt   time.Time `gorm:"autoCreateTime;column:createdAt"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime;column:updatedAt"`
}

func (Service) TableName() string {
	return "Service"
}

type CartItem struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	UserID    string    `gorm:"not null;uniqueIndex:idx_cart_user_product;column:userId"`
	User      User      `gorm:"foreignKey:UserID"`
	ProductID string    `gorm:"not null;uniqueIndex:idx_cart_user_product;column:productId"`
	Product   Product   `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE"`
	Quantity  int       `gorm:"default:1;column:quantity"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt"`
	UpdatedAt time.Time `gorm:"autoUpdateTime;column:updatedAt"`
}

func (CartItem) TableName() string {
	return "CartItem"
}

type Order struct {
	ID            string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	InvoiceNumber string    `gorm:"uniqueIndex;not null;column:invoiceNumber"`
	UserID        string    `gorm:"not null;column:userId"`
	User          User      `gorm:"foreignKey:UserID"`
	TotalAmount   float64   `gorm:"not null;column:totalAmount"`
	Status        string    `gorm:"default:'PENDING';column:status"`
	PaymentType   string    `gorm:"column:paymentType"`
	SnapToken     string    `gorm:"column:snapToken"`
	SnapUrl       string    `gorm:"column:snapUrl"`
	Address       string    `gorm:"column:address"`
	DeliveryInfo  string    `gorm:"column:deliveryInfo"`
	RefundReason  string    `gorm:"column:refundReason"`
	RefundAccount string    `gorm:"column:refundAccount"`
	RefundProof   string    `gorm:"column:refundProof"`
	DiscountApplied float64 `gorm:"default:0;column:discountApplied"`
	VoucherCode     string  `gorm:"column:voucherCode"`

	Items     []OrderItem     `gorm:"foreignKey:OrderID"`
	Timeline  []OrderTimeline `gorm:"foreignKey:OrderID"`
	CreatedAt time.Time       `gorm:"autoCreateTime;column:createdAt"`
	UpdatedAt time.Time       `gorm:"autoUpdateTime;column:updatedAt"`
}

func (Order) TableName() string {
	return "Order"
}

type OrderItem struct {
	ID        string  `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	OrderID   string  `gorm:"not null;column:orderId"`
	ProductID string  `gorm:"not null;column:productId"`
	Product   Product `gorm:"foreignKey:ProductID"`
	Quantity  int     `gorm:"not null;column:quantity"`
	Price     float64 `gorm:"not null;column:price"`
}

func (OrderItem) TableName() string {
	return "OrderItem"
}

type OrderTimeline struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	OrderID     string    `gorm:"not null;column:orderId"`
	Title       string    `gorm:"not null;column:title"`
	Description string    `gorm:"column:description"`
	Timestamp   time.Time `gorm:"default:now();column:timestamp"`
}

func (OrderTimeline) TableName() string {
	return "OrderTimeline"
}

type Message struct {
	ID           string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Content      string    `gorm:"type:text;not null;column:content"`
	SenderID     string    `gorm:"not null;column:senderId"`
	Sender       User      `gorm:"foreignKey:SenderID"`
	IsAdmin      bool      `gorm:"default:false;column:isAdmin"`
	IsRead       bool      `gorm:"default:false;column:isRead"`
	TargetUserID string    `gorm:"column:targetUserId"`
	CreatedAt    time.Time `gorm:"autoCreateTime;column:createdAt"`
}

func (Message) TableName() string {
	return "Message"
}

type Voucher struct {
	ID          string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	Code        string    `gorm:"uniqueIndex;not null;column:code"`
	Type        string    `gorm:"default:'FIXED';column:type"`
	Value       float64   `gorm:"not null;column:value"`
	MinPurchase float64   `gorm:"default:0;column:minPurchase"`
	MaxDiscount float64   `gorm:"column:maxDiscount"`
	StartDate   time.Time `gorm:"default:now();column:startDate"`
	ExpiresAt   time.Time `gorm:"not null;column:expiresAt"`
	UsageLimit  int       `gorm:"default:0;column:usageLimit"`
	UsedCount   int       `gorm:"default:0;column:usedCount"`
	IsActive    bool      `gorm:"default:true;column:isActive"`
	CreatedAt   time.Time `gorm:"autoCreateTime;column:createdAt"`
}

func (Voucher) TableName() string {
	return "Voucher"
}

type FlashSale struct {
	ID            string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	ProductID     string    `gorm:"not null;column:productId"`
	Product       Product   `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE"`
	DiscountPrice float64   `gorm:"not null;column:discountPrice"`
	StartTime     time.Time `gorm:"not null;column:startTime"`
	EndTime       time.Time `gorm:"not null;column:endTime"`
	IsActive      bool      `gorm:"default:true;column:isActive"`
	CreatedAt     time.Time `gorm:"autoCreateTime;column:createdAt"`
}

func (FlashSale) TableName() string {
	return "FlashSale"
}

type Review struct {
	ID        string    `gorm:"primaryKey;default:gen_random_uuid();column:id"`
	UserID    string    `gorm:"not null;column:userId"`
	User      User      `gorm:"foreignKey:UserID"`
	ProductID string    `gorm:"not null;column:productId"`
	Product   Product   `gorm:"foreignKey:ProductID"`
	Rating    int       `gorm:"not null;column:rating"`
	Comment   string    `gorm:"type:text;column:comment"`
	IsVisible bool      `gorm:"default:true;column:isVisible"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt"`
}

func (Review) TableName() string {
	return "Review"
}

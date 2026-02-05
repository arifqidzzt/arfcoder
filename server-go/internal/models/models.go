package models

import (
	"time"

	"github.com/lib/pq"
	"gorm.io/gorm"
	"arfcoder-go/internal/utils"
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
	ID               string    `gorm:"primaryKey;column:id" json:"id"`
	Email            string    `gorm:"uniqueIndex;not null;column:email" json:"email"`
	Password         string    `gorm:"type:text;column:password" json:"-"`
	Name             string    `gorm:"column:name" json:"name"`
	Role             string    `gorm:"default:'USER';column:role" json:"role"`
	IsVerified       bool      `gorm:"default:false;column:isVerified" json:"isVerified"`
	GoogleID         string    `gorm:"uniqueIndex;column:googleId" json:"googleId"`
	Avatar           string    `gorm:"column:avatar" json:"avatar"`
	PhoneNumber      string    `gorm:"column:phoneNumber" json:"phoneNumber"`
	WABotNumber      string    `gorm:"column:waBotNumber" json:"waBotNumber"`
	ResetToken       string    `gorm:"column:resetToken" json:"-"`
	ResetTokenExpiry *time.Time `gorm:"column:resetTokenExpiry" json:"-"`
	TwoFactorSecret  string    `gorm:"column:twoFactorSecret" json:"-"`
	TwoFactorEnabled bool      `gorm:"default:false;column:twoFactorEnabled" json:"twoFactorEnabled"`
	CreatedAt        time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt        time.Time `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`

	// Relations
	Otps         []Otp         `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"otps,omitempty"`
	Orders       []Order       `gorm:"foreignKey:UserID" json:"orders,omitempty"`
	CartItems    []CartItem    `gorm:"foreignKey:UserID;constraint:OnDelete:CASCADE" json:"cartItems,omitempty"`
	Reviews      []Review      `gorm:"foreignKey:UserID" json:"reviews,omitempty"`
	ActivityLogs []ActivityLog `gorm:"foreignKey:UserID" json:"activityLogs,omitempty"`
}

func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == "" {
		u.ID = utils.GenerateRandomString(12)
	}
	return
}

func (User) TableName() string {
	return "User"
}

type ActivityLog struct {
	ID        string    `gorm:"primaryKey;column:id" json:"id"`
	UserID    string    `gorm:"not null;column:userId" json:"userId"`
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	Action    string    `gorm:"not null;column:action" json:"action"`
	Details   string    `gorm:"column:details" json:"details"`
	IPAddress string    `gorm:"column:ipAddress" json:"ipAddress"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}

func (a *ActivityLog) BeforeCreate(tx *gorm.DB) (err error) {
	if a.ID == "" {
		a.ID = utils.GenerateRandomString(12)
	}
	return
}

func (ActivityLog) TableName() string {
	return "ActivityLog"
}

type Otp struct {
	ID        string    `gorm:"primaryKey;column:id" json:"id"`
	Code      string    `gorm:"not null;column:code" json:"code"`
	Email     string    `gorm:"not null;column:email" json:"email"`
	UserID    string    `gorm:"not null;column:userId" json:"userId"`
	ExpiresAt time.Time `gorm:"not null;column:expiresAt" json:"expiresAt"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}

func (o *Otp) BeforeCreate(tx *gorm.DB) (err error) {
	if o.ID == "" {
		o.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Otp) TableName() string {
	return "Otp"
}

type Category struct {
	ID       string    `gorm:"primaryKey;column:id" json:"id"`
	Name     string    `gorm:"uniqueIndex;not null;column:name" json:"name"`
	Products []Product `gorm:"foreignKey:CategoryID" json:"products,omitempty"`
}

func (c *Category) BeforeCreate(tx *gorm.DB) (err error) {
	if c.ID == "" {
		c.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Category) TableName() string {
	return "Category"
}

type Product struct {
	ID          string         `gorm:"primaryKey;column:id" json:"id"`
	Name        string         `gorm:"not null;column:name" json:"name"`
	Description string         `gorm:"type:text;column:description" json:"description"`
	Price       float64        `gorm:"not null;column:price" json:"price"`
	Discount    float64        `gorm:"default:0;column:discount" json:"discount"`
	Stock       int            `gorm:"default:0;column:stock" json:"stock"`
	Type        string         `gorm:"default:'BARANG';column:type" json:"type"`
	Images      pq.StringArray `gorm:"type:text[];column:images" json:"images"` 
	CategoryID  *string        `gorm:"column:categoryId" json:"categoryId"`
	Category    Category       `gorm:"foreignKey:CategoryID" json:"category,omitempty"`
	CreatedAt   time.Time      `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt   time.Time      `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`

	CartItems  []CartItem  `gorm:"foreignKey:ProductID" json:"cartItems,omitempty"`
	OrderItems []OrderItem `gorm:"foreignKey:ProductID" json:"orderItems,omitempty"`
	Reviews    []Review    `gorm:"foreignKey:ProductID" json:"reviews,omitempty"`
	FlashSales []FlashSale `gorm:"foreignKey:ProductID" json:"flashSales,omitempty"`
}

func (p *Product) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == "" {
		p.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Product) TableName() string {
	return "Product"
}

type Service struct {
	ID          string    `gorm:"primaryKey;column:id" json:"id"`
	Title       string    `gorm:"not null;column:title" json:"title"`
	Description string    `gorm:"type:text;column:description" json:"description"`
	Price       string    `gorm:"not null;column:price" json:"price"`
	Icon        string    `gorm:"column:icon" json:"icon"`
	CreatedAt   time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt   time.Time `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}

func (s *Service) BeforeCreate(tx *gorm.DB) (err error) {
	if s.ID == "" {
		s.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Service) TableName() string {
	return "Service"
}

type CartItem struct {
	ID        string    `gorm:"primaryKey;column:id" json:"id"`
	UserID    string    `gorm:"not null;uniqueIndex:idx_cart_user_product;column:userId" json:"userId"`
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	ProductID string    `gorm:"not null;uniqueIndex:idx_cart_user_product;column:productId" json:"productId"`
	Product   Product   `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE" json:"product,omitempty"`
	Quantity  int       `gorm:"default:1;column:quantity" json:"quantity"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt time.Time `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}

func (c *CartItem) BeforeCreate(tx *gorm.DB) (err error) {
	if c.ID == "" {
		c.ID = utils.GenerateRandomString(12)
	}
	return
}

func (CartItem) TableName() string {
	return "CartItem"
}

type Order struct {
	ID            string    `gorm:"primaryKey;column:id" json:"id"`
	InvoiceNumber string    `gorm:"uniqueIndex;not null;column:invoiceNumber" json:"invoiceNumber"`
	UserID        string    `gorm:"not null;column:userId" json:"userId"`
	User          User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	TotalAmount   float64   `gorm:"not null;column:totalAmount" json:"totalAmount"`
	Status        string    `gorm:"default:'PENDING';column:status" json:"status"`
	PaymentType   string    `gorm:"column:paymentType" json:"paymentType"`
	SnapToken     string    `gorm:"column:snapToken" json:"snapToken"`
	SnapUrl       string    `gorm:"column:snapUrl" json:"snapUrl"`
	Address       string    `gorm:"column:address" json:"address"`
	DeliveryInfo  string    `gorm:"column:deliveryInfo" json:"deliveryInfo"`
	RefundReason  string    `gorm:"column:refundReason" json:"refundReason"`
	RefundAccount string    `gorm:"column:refundAccount" json:"refundAccount"`
	RefundProof   string    `gorm:"column:refundProof" json:"refundProof"`
	DiscountApplied float64 `gorm:"default:0;column:discountApplied" json:"discountApplied"`
	VoucherCode     string  `gorm:"column:voucherCode" json:"voucherCode"`

	Items     []OrderItem     `gorm:"foreignKey:OrderID" json:"items,omitempty"`
	Timeline  []OrderTimeline `gorm:"foreignKey:OrderID" json:"timeline,omitempty"`
	CreatedAt time.Time       `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
	UpdatedAt time.Time       `gorm:"autoUpdateTime;column:updatedAt" json:"updatedAt"`
}

func (o *Order) BeforeCreate(tx *gorm.DB) (err error) {
	if o.ID == "" {
		o.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Order) TableName() string {
	return "Order"
}

type OrderItem struct {
	ID        string  `gorm:"primaryKey;column:id" json:"id"`
	OrderID   string  `gorm:"not null;column:orderId" json:"orderId"`
	ProductID string  `gorm:"not null;column:productId" json:"productId"`
	Product   Product `gorm:"foreignKey:ProductID" json:"product,omitempty"`
	Quantity  int     `gorm:"not null;column:quantity" json:"quantity"`
	Price     float64 `gorm:"not null;column:price" json:"price"`
}

func (o *OrderItem) BeforeCreate(tx *gorm.DB) (err error) {
	if o.ID == "" {
		o.ID = utils.GenerateRandomString(12)
	}
	return
}

func (OrderItem) TableName() string {
	return "OrderItem"
}

type OrderTimeline struct {
	ID          string    `gorm:"primaryKey;column:id" json:"id"`
	OrderID     string    `gorm:"not null;column:orderId" json:"orderId"`
	Title       string    `gorm:"not null;column:title" json:"title"`
	Description string    `gorm:"column:description" json:"description"`
	Timestamp   time.Time `gorm:"default:now();column:timestamp" json:"timestamp"`
}

func (o *OrderTimeline) BeforeCreate(tx *gorm.DB) (err error) {
	if o.ID == "" {
		o.ID = utils.GenerateRandomString(12)
	}
	return
}

func (OrderTimeline) TableName() string {
	return "OrderTimeline"
}

type Message struct {
	ID           string    `gorm:"primaryKey;column:id" json:"id"`
	Content      string    `gorm:"type:text;not null;column:content" json:"content"`
	SenderID     string    `gorm:"not null;column:senderId" json:"senderId"`
	Sender       User      `gorm:"foreignKey:SenderID" json:"sender,omitempty"`
	IsAdmin      bool      `gorm:"default:false;column:isAdmin" json:"isAdmin"`
	IsRead       bool      `gorm:"default:false;column:isRead" json:"isRead"`
	TargetUserID string    `gorm:"column:targetUserId" json:"targetUserId"`
	CreatedAt    time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}

func (m *Message) BeforeCreate(tx *gorm.DB) (err error) {
	if m.ID == "" {
		m.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Message) TableName() string {
	return "Message"
}

type Voucher struct {
	ID          string    `gorm:"primaryKey;column:id" json:"id"`
	Code        string    `gorm:"uniqueIndex;not null;column:code" json:"code"`
	Type        string    `gorm:"default:'FIXED';column:type" json:"type"`
	Value       float64   `gorm:"not null;column:value" json:"value"`
	MinPurchase float64   `gorm:"default:0;column:minPurchase" json:"minPurchase"`
	MaxDiscount float64   `gorm:"column:maxDiscount" json:"maxDiscount"`
	StartDate   time.Time `gorm:"default:now();column:startDate" json:"startDate"`
	ExpiresAt   time.Time `gorm:"not null;column:expiresAt" json:"expiresAt"`
	UsageLimit  int       `gorm:"default:0;column:usageLimit" json:"usageLimit"`
	UsedCount   int       `gorm:"default:0;column:usedCount" json:"usedCount"`
	IsActive    bool      `gorm:"default:true;column:isActive" json:"isActive"`
	CreatedAt   time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}

func (v *Voucher) BeforeCreate(tx *gorm.DB) (err error) {
	if v.ID == "" {
		v.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Voucher) TableName() string {
	return "Voucher"
}

type FlashSale struct {
	ID            string    `gorm:"primaryKey;column:id" json:"id"`
	ProductID     string    `gorm:"not null;column:productId" json:"productId"`
	Product       Product   `gorm:"foreignKey:ProductID;constraint:OnDelete:CASCADE" json:"product,omitempty"`
	DiscountPrice float64   `gorm:"not null;column:discountPrice" json:"discountPrice"`
	StartTime     time.Time `gorm:"not null;column:startTime" json:"startTime"`
	EndTime       time.Time `gorm:"not null;column:endTime" json:"endTime"`
	IsActive      bool      `gorm:"default:true;column:isActive" json:"isActive"`
	CreatedAt     time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}

func (f *FlashSale) BeforeCreate(tx *gorm.DB) (err error) {
	if f.ID == "" {
		f.ID = utils.GenerateRandomString(12)
	}
	return
}

func (FlashSale) TableName() string {
	return "FlashSale"
}

type Review struct {
	ID        string    `gorm:"primaryKey;column:id" json:"id"`
	UserID    string    `gorm:"not null;column:userId" json:"userId"`
	User      User      `gorm:"foreignKey:UserID" json:"user,omitempty"`
	ProductID string    `gorm:"not null;column:productId" json:"productId"`
	Product   Product   `gorm:"foreignKey:ProductID" json:"product,omitempty"`
	Rating    int       `gorm:"not null;column:rating" json:"rating"`
	Comment   string    `gorm:"type:text;column:comment" json:"comment"`
	IsVisible bool      `gorm:"default:true;column:isVisible" json:"isVisible"`
	CreatedAt time.Time `gorm:"autoCreateTime;column:createdAt" json:"createdAt"`
}

func (r *Review) BeforeCreate(tx *gorm.DB) (err error) {
	if r.ID == "" {
		r.ID = utils.GenerateRandomString(12)
	}
	return
}

func (Review) TableName() string {
	return "Review"
}


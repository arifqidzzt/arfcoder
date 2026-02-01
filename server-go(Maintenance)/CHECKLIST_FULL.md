# Full Migration Checklist

## 1. Core System
- [x] **Auth System**: Register, Login (Password), OTP Verify.
- [x] **Security**: JWT, Rate Limiting, Secure Header, Payload Decryption.
- [x] **Database**: GORM Models mapped to Prisma Schema.

## 2. Product & Order
- [x] **Products**: Get All, Get Detail.
- [x] **Orders**: Create Order (with Voucher), Midtrans Integration (Snap), Webhook Handler.
- [x] **User Orders**: (Partial) `GetMyOrders` implementation needs verification inside `GetAllOrders` logic or separate handler.

## 3. Marketing Features
- [x] **Vouchers**: Create (Admin), Delete (Admin), Check Validity (User).
- [x] **Flash Sales**: Create (Admin), Delete (Admin), Get Active (User).

## 4. User Features
- [x] **Profile**: Get Profile (with Stats), Update Profile.
- [x] **Account Security**: Change Password, Change Phone (OTP Flow).
- [x] **Reviews**: Create Review (Purchase Check), Get Reviews.

## 5. Admin Dashboard
- [x] **Stats**: Dashboard Counters & Chart Data.
- [x] **Management**: Users List, Delete User.
- [x] **Order Mgmt**: List All, Update Status, Update Delivery Info, Timeline.
- [x] **Services**: CRUD Services.
- [x] **Logs**: View Activity Logs.
- [x] **WhatsApp**: Status, Start, Logout Control.

## 6. Services
- [x] **WhatsApp**: `whatsmeow` implementation with `INFO VPS` command.
- [x] **Email**: Resend implementation.

## ⚠️ Known Limitations / Next Steps
1. **Google Login**: Currently stubbed. Needs `google-auth-library` verification.
2. **Socket.IO Chat**: Real-time chat not ported. REST API for history (`chat_handler`) is available.
3. **2FA Setup**: Endpoints for QR generation (`/auth/2fa/setup`) not yet implemented in routes, though logic exists in Node.

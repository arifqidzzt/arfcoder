# Migration Checklist

## Core Features
- [x] Structure Project (Standard Go Layout)
- [x] Configuration (.env loading)
- [x] Database Connection (GORM + Postgres)
- [x] Models (Mapped from Prisma)
- [x] Auth Handler (Register, Login, OTP, JWT)
- [x] Password Hashing (Bcrypt)
- [x] Secure Middleware (Header + Body Decryption)
- [x] Product Handler (List, Get)
- [x] Order Handler (Create, Midtrans)
- [x] WhatsApp Service (Whatsmeow + INFO VPS)
- [x] Email Service (Resend)

## Security Verification
- [ ] **Secure Middleware**: Ensure `x-arf-secure-token` is required and validated.
- [ ] **Payload Decryption**: Ensure POST requests with array payload are decrypted correctly.
- [ ] **Rate Limiting**: Check if limits are active (500/15m API, 60/1h Auth).
- [ ] **CORS**: Verify `Access-Control-Allow-Origin` matches Client URL.

## Pending / To Do
- [ ] **Socket.IO**: Implement Chat feature using `googollee/go-socket.io` or standard Websocket. (Currently omitted to ensure stability, needs separate task).
- [ ] **Full Admin Features**: Add CRUD for Users, Vouchers, FlashSales.
- [ ] **Google Login Verification**: Add `google-auth-library` verification logic.
- [ ] **2FA Setup**: Implement TOTP setup endpoint.

## How to Run
1. Ensure PostgreSQL is running.
2. Configure `.env` (Copy from `.env.example`).
3. Run: `go run cmd/api/main.go`

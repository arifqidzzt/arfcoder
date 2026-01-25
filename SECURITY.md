# ARFCODER SECURITY PROTOCOL V1 (ASP-V1)

Dokumen ini menjelaskan mekanisme keamanan End-to-End Encryption yang diterapkan pada komunikasi antara Frontend (Client) dan Backend (Server).

## 🛡️ Arsitektur Keamanan

Sistem menggunakan 3 lapisan keamanan untuk setiap request sensitif (POST, PUT, PATCH):

1.  **AES-256 Encryption:** Melindungi isi data (payload) agar tidak bisa dibaca manusia/sniffer.
2.  **HMAC-SHA256 Signature:** Memastikan integritas data (anti-tamper).
3.  **Timestamp Validation:** Mencegah Replay Attack (request kadaluarsa dalam 2 menit).

---

## 🔑 Kunci Rahasia (Secret Key)

Kunci ini **SANGAT RAHASIA** dan harus sama persis di Client dan Server.
Disimpan di `.env`:
*   **Server:** `APP_SECRET_KEY`
*   **Client:** `NEXT_PUBLIC_APP_SECRET_KEY`

> **PENTING:** Jika kunci ini bocor, segera ganti di kedua sisi dan restart server.

---

## 📦 Struktur Request Payload

Request `POST/PUT/PATCH` tidak lagi mengirim JSON biasa. Body request diubah menjadi format berikut:

```json
{
  "payload": "U2FsdGVkX1/...",  // String acak hasil enkripsi AES
  "signature": "a1b2c3d4...",    // Hash HMAC untuk validasi
  "timestamp": "1712345678900"   // Waktu kirim (Epoch ms)
}
```

### Cara Kerja Enkripsi (Frontend):
1.  Ambil data asli (JSON).
2.  Encrypt dengan `CryptoJS.AES.encrypt(JSON.stringify(data), SECRET_KEY)`.
3.  Buat Signature: `CryptoJS.HmacSHA256(EncryptedPayload + Timestamp, SECRET_KEY)`.
4.  Kirim objek `{ payload, signature, timestamp }`.

### Cara Kerja Dekripsi (Backend):
1.  Terima request.
2.  Cek Timestamp: `Date.now() - timestamp`. Jika > 120 detik (2 menit), **REJECT**.
3.  Hitung ulang Signature: `HMAC(ReceivedPayload + ReceivedTimestamp, SECRET_KEY)`.
4.  Jika Signature hasil hitungan !== `ReceivedSignature`, **REJECT** (Data diubah hacker).
5.  Decrypt `payload` dengan AES.

---

## 🚪 Custom Header (The Gatekeeper)

Setiap request (termasuk GET) wajib menyertakan header:
`x-arf-secure-token`

Format: `TIMESTAMP.HASH`
*   `HASH` = `SHA256(SECRET_KEY + TIMESTAMP)`

Server akan memvalidasi header ini sebelum memproses request apapun.

---

## 🛠️ Cara Testing API (Postman / cURL)

Anda **TIDAK BISA** lagi menembak API secara langsung dengan JSON biasa.
Jika ingin test manual, Anda harus men-generate payload terenkripsi dulu.

**Script Pre-request (JS):**
```javascript
const crypto = require("crypto-js");
const SECRET = "KUNCI_RAHASIA_ANDA"; // Samakan dengan .env
const data = { email: "test@example.com", password: "123" }; // Data asli

const timestamp = Date.now().toString();
const payload = crypto.AES.encrypt(JSON.stringify(data), SECRET).toString();
const signature = crypto.HmacSHA256(payload + timestamp, SECRET).toString();

console.log({ payload, signature, timestamp });
```
Copy hasil console log tersebut ke Body request Postman.

---

## 🚫 Pengecualian

Route berikut **TIDAK** menggunakan enkripsi ini (Public/Third Party):
*   `/api/midtrans-webhook` (Karena request datang dari server Midtrans yang tidak tahu secret key kita).

---
*Dibuat otomatis oleh ArfCoder AI Assistant - 2026*

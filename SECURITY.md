# ARFCODER SECURITY PROTOCOL V6 (THE BLUEPRINT)

Dokumen ini adalah panduan teknis mendalam tentang arsitektur keamanan *End-to-End Encryption* yang digunakan dalam ekosistem ArfCoder. Sistem ini dirancang untuk mencegah *Replay Attack*, *Man-In-The-Middle*, dan *Bot Automation*.

---

## 🔑 Kunci Utama (Master Key)

Semua proses bergantung pada satu kunci rahasia yang harus identik di kedua sisi (Client & Server).
*   **Variable:** `APP_SECRET_KEY`
*   **Panjang:** Minimal 32 Karakter (String Acak).
*   **Sifat:** Statis (Disimpan di `.env`), tidak dikirim lewat jaringan.

---

## 🌐 1. HEADER VALIDATION (Global Gatekeeper)

Setiap request HTTP (`GET`, `POST`, `PUT`, `DELETE`) **WAJIB** menyertakan header ini. Jika tidak ada atau salah, server langsung menolak (`403 Forbidden`).

**Nama Header:** `x-arf-secure-token`
**Format:** `TIMESTAMP . HASH . ENCRYPTED_NONCE`

### Cara Membuat (Client Side):
1.  **Ambil Waktu:** `TIMESTAMP` = `Date.now()` (Epoch ms).
2.  **Buat Nonce:** `RAW_NONCE` = String acak 16 karakter.
3.  **Enkripsi Nonce:**
    *   `ENCRYPTED_NONCE` = `AES.encrypt(RAW_NONCE + ":" + TIMESTAMP, KEY)`
4.  **Buat Hash:**
    *   `HASH` = `SHA256(KEY + TIMESTAMP + RAW_NONCE)`
5.  **Gabungkan:** `TIMESTAMP` + `.` + `HASH` + `.` + `ENCRYPTED_NONCE`

### Cara Validasi (Server Side):
1.  **Pecah Header:** Pisahkan string berdasarkan titik (`.`).
2.  **Cek Waktu:** `|ServerTime - TIMESTAMP| < 30 detik`. (Jika lebih, **REJECT**).
3.  **Dekripsi Nonce:** Buka `ENCRYPTED_NONCE` dengan `KEY` -> Dapat `RAW_NONCE`.
4.  **Cek Hash:** Hitung ulang `SHA256(...)`. Jika tidak sama dengan `HASH` -> **REJECT**.
5.  **Cek Duplikasi (Anti-Replay):** Cek apakah `RAW_NONCE` sudah ada di Cache Server?
    *   Jika Ada: **REJECT** (Replay Attack).
    *   Jika Tidak: Simpan `RAW_NONCE` ke Cache (Expired 1 menit).

---

## 📦 2. PAYLOAD ENCRYPTION (The Vault)

Khusus request yang membawa data (`POST`, `PUT`, `PATCH`), body request diubah total menjadi **Array Acak**.

### Struktur Data Dalam (Inner Object):
Sebelum dienkripsi, data asli dibungkus bersama metadata keamanan.
```json
{
  "email": "user@test.com",  // Data Asli
  "password": "123",         // Data Asli
  "_res": "1920x1080",       // Resolusi Layar (Fingerprint)
  "_ua": "a1b2c3d4...",      // MD5 Hash User Agent (Fingerprint)
  "_tz": "Asia/Jakarta",     // Timezone (Fingerprint)
  "_j": "Xy78sA...",         // Junk Data Acak (Panjang 10-40 char)
  "_n": "NONCE:TIMESTAMP"    // Nonce Lapis Kedua (Khusus Payload)
}
```

### Proses Pembungkusan (Encryption Flow):
1.  **Algoritma:** AES-256-CBC dengan PKCS7 Padding.
2.  **Mekanisme Salt:** Menggunakan **OpenSSL-style Random Salt**. Setiap ciphertext akan dimulai dengan prefix `Salted__` (8 byte) diikuti oleh 8 byte Salt acak. Hal ini memastikan hasil enkripsi selalu berbeda walaupun data yang dienkripsi sama.
3.  **Layer 1 (Inner):**
    *   `L1` = `AES.encrypt(JSON.stringify(InnerObject), KEY)`
4.  **Layer 2 (Outer):**
    *   `PAYLOAD` = `AES.encrypt(L1, KEY)`
    *   *(Enkripsi dua kali membuat pola ciphertext sangat acak)*
5.  **Signature:**
    *   `SIGNATURE` = `HMAC_SHA256(PAYLOAD + TIMESTAMP, KEY)`

---

## 🎲 3. ARRAY OBFUSCATION (The Shuffle)

Data yang dikirim ke server **BUKAN JSON OBJECT**, melainkan **ARRAY**. Posisi elemen diacak berdasarkan waktu.

**Penentu Pola:** Digit Terakhir dari `TIMESTAMP`.

| Pola | Digit | Susunan Array (Index 0-4) |
| :--- | :--- | :--- |
| **Genap** | `0, 2, 4, 6, 8` | `[ PAYLOAD, SIGNATURE, TIMESTAMP, JUNK_STR, JUNK_STR ]` |
| **Ganjil** | `1, 3, 5, 7, 9` | `[ TIMESTAMP, JUNK_STR, PAYLOAD, JUNK_STR, SIGNATURE ]` |

*Server membaca digit terakhir timestamp, lalu menentukan index mana yang harus diambil.*

---

## 🚫 4. PENGECUALIAN (Public Access)

Endpoint berikut dibebaskan dari Enkripsi Payload (tapi tetap wajib Header Token jika request dari Client):

1.  **POST `/api/midtrans-webhook`**
    *   **Status:** Full Public.
    *   **Alasan:** Server Midtrans mengirim notifikasi pembayaran. Mereka tidak punya kunci kita.
    *   **Keamanan:** Mengandalkan verifikasi Signature Midtrans (Server Key) di dalam logic controller.

2.  **Upload File (`FormData`)**
    *   **Status:** Header Check Only.
    *   **Alasan:** Mengenkripsi file gambar menjadi string base64/hex sangat berat dan lambat.
    *   **Keamanan:** Mengandalkan Header V6 (One-Time Use).

---

## 🧪 5. FORMAT JSON ERROR (Response)

Jika request ditolak, Server akan mengembalikan status HTTP standar:

*   **400 Bad Request:** Format payload salah (bukan array 5 elemen) atau Dekripsi Gagal.
*   **403 Forbidden:** Header Token salah, Expired, atau Nonce sudah terpakai (Replay).
*   **401 Unauthorized:** Token JWT (Login) expired.

---
*Dokumen ini diperbarui otomatis oleh ArfCoder AI - Security Protocol V6*

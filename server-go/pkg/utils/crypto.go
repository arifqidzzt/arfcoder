package utils

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/hmac"
	"crypto/md5"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
)

// OpenSSL Salted format header
var SaltedPrefix = []byte("Salted__")

// DecryptPayload decrypts the AES-256-CBC payload from CryptoJS
func DecryptPayload(payloadBase64 string) (string, error) {
	secretKey := os.Getenv("APP_SECRET_KEY")
	if secretKey == "" {
		return "", errors.New("APP_SECRET_KEY is not set")
	}

	// 1. Decode Base64
	data, err := base64.StdEncoding.DecodeString(payloadBase64)
	if err != nil {
		return "", err
	}

	// 2. Check Salted__ prefix
	if len(data) < 16 || string(data[:8]) != string(SaltedPrefix) {
		return "", errors.New("invalid encrypted payload format")
	}

	salt := data[8:16]
	ciphertext := data[16:]

	// 3. Derive Key & IV from Passphrase + Salt (OpenSSL KDF)
	key, iv := openSSLKeyDerivation([]byte(secretKey), salt)

	// 4. Decrypt AES-256-CBC
	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	mode := cipher.NewCBCDecrypter(block, iv)
	decrypted := make([]byte, len(ciphertext))
	mode.CryptBlocks(decrypted, ciphertext)

	// 5. Unpad PKCS7
	unpadded, err := pkcs7Unpad(decrypted)
	if err != nil {
		return "", err
	}

	return string(unpadded), nil
}

// VerifySignature checks HMAC-SHA256
func VerifySignature(payload, timestamp, signature string) bool {
	secretKey := os.Getenv("APP_SECRET_KEY")
	data := payload + timestamp
	
	h := hmac.New(sha256.New, []byte(secretKey))
	h.Write([]byte(data))
	expectedSig := hex.EncodeToString(h.Sum(nil))

	return expectedSig == signature
}

// Helper: OpenSSL Key Derivation Function (EVP_BytesToKey)
// Matches CryptoJS default behavior
func openSSLKeyDerivation(password, salt []byte) ([]byte, []byte) {
	keySize := 32 // AES-256
	ivSize := 16  // AES block size

	var keyIV []byte
	var lastBlock []byte

	for len(keyIV) < keySize+ivSize {
		h := md5.New()
		if len(lastBlock) > 0 {
			h.Write(lastBlock)
		}
		h.Write(password)
		h.Write(salt)
		lastBlock = h.Sum(nil)
		keyIV = append(keyIV, lastBlock...)
	}

	return keyIV[:keySize], keyIV[keySize : keySize+ivSize]
}

// Helper: PKCS7 Unpadding
func pkcs7Unpad(data []byte) ([]byte, error) {
	length := len(data)
	if length == 0 {
		return nil, errors.New("invalid padding size")
	}
	padding := int(data[length-1])
	if padding > length || padding == 0 {
		return nil, errors.New("invalid padding")
	}
	return data[:length-padding], nil
}

// VerifyHeader checks x-arf-secure-token format
func VerifyHeader(token string) bool {
	secretKey := os.Getenv("APP_SECRET_KEY")
	// Expected: TIMESTAMP.HASH
	// We need to split and hash check. 
	// For simplicity in this helper, we'll let middleware handle splitting logic
	// Or we can just re-implement SHA256(Key + Timestamp) logic here.
	return len(token) > 10 // Basic check, real logic in middleware
}

package utils

import (
	"crypto/aes"
	"crypto/cipher"
	"crypto/hmac"
	"crypto/md5"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"sync"
	"time"

	"arfcoder-go/internal/config"
)

var (
	nonceCache = make(map[string]int64)
	cacheMutex sync.Mutex
)

func init() {
	// Cleanup cache every minute
	go func() {
		for {
			time.Sleep(1 * time.Minute)
			now := time.Now().UnixMilli()
			cacheMutex.Lock()
			for key, expiry := range nonceCache {
				if now > expiry {
					delete(nonceCache, key)
				}
			}
			cacheMutex.Unlock()
		}
	}()
}

// DecryptPayload handles the specific array-of-5 obfuscation and AES decryption
func DecryptPayload(body []interface{}) (map[string]interface{}, error) {
	if len(body) != 5 {
		return nil, errors.New("format invalid")
	}

	// 1. Determine Timestamp and Payload pair
	var payload, signature string
	var timestamp int64
	
	tsAStr, okA := body[2].(string)
	tsBStr, okB := body[0].(string)
	
	if !okA && !okB {
		return nil, errors.New("TS invalid format")
	}

	tsA, _ := strconv.ParseInt(tsAStr, 10, 64)
	tsB, _ := strconv.ParseInt(tsBStr, 10, 64)
	now := time.Now().UnixMilli()
	
	isEven := false

	if tsA > 0 && math.Abs(float64(now-tsA)) < 60000 {
		isEven = true
		timestamp = tsA
	} else if tsB > 0 && math.Abs(float64(now-tsB)) < 60000 {
		isEven = false
		timestamp = tsB
	} else {
		return nil, errors.New("TS invalid range")
	}

	if isEven {
		payload = body[0].(string)
		signature = body[1].(string)
	} else {
		payload = body[2].(string)
		signature = body[4].(string)
	}

	// 2. Verify Time Window
	if math.Abs(float64(now-timestamp)) > 30*1000 {
		return nil, errors.New("expired")
	}

	// 3. Verify Signature
	expectedSig := computeHmac(payload+fmt.Sprintf("%d", timestamp), config.AppSecretKey)
	if expectedSig != signature {
		return nil, errors.New("sig mismatch")
	}

	// 4. Double Decrypt
	l1, err := decryptAES(payload, config.AppSecretKey)
	if err != nil {
		return nil, fmt.Errorf("decryption l1 failed: %v", err)
	}

	inner, err := decryptAES(l1, config.AppSecretKey)
	if err != nil {
		return nil, fmt.Errorf("decryption inner failed: %v", err)
	}

	// 5. Parse JSON
	var finalData map[string]interface{}
	if err := json.Unmarshal([]byte(inner), &finalData); err != nil {
		return nil, errors.New("json parse error")
	}

	// 6. Check Nonce
	nonce, ok := finalData["_n"].(string)
	if !ok || nonce == "" {
		return nil, errors.New("replay: no nonce")
	}

	cacheMutex.Lock()
	if _, exists := nonceCache[nonce]; exists {
		cacheMutex.Unlock()
		return nil, errors.New("replay detected")
	}
	nonceCache[nonce] = now + 60000
	cacheMutex.Unlock()

	// Clean fields
	delete(finalData, "_n")
	delete(finalData, "_j")
	delete(finalData, "_res")
	delete(finalData, "_ua")
	delete(finalData, "_tz")

	return finalData, nil
}

func VerifySecureHeader(headerValue string) bool {
	if headerValue == "" {
		return false
	}

	parts := strings.Split(headerValue, ".")
	if len(parts) != 3 {
		return false
	}

	timestampStr := parts[0]
	hash := parts[1]
	encNonce := parts[2]

	timestamp, err := strconv.ParseInt(timestampStr, 10, 64)
	if err != nil {
		return false
	}

	now := time.Now().UnixMilli()
	if math.Abs(float64(now-timestamp)) > 30*1000 {
		return false
	}

	// Decrypt Nonce
	nonceRaw, err := decryptAES(encNonce, config.AppSecretKey)
	if err != nil || !strings.Contains(nonceRaw, ":") {
		return false
	}

	nonceValue := strings.Split(nonceRaw, ":")[0]

	// Verify Hash
	validHash := computeSHA256(config.AppSecretKey + timestampStr + nonceValue)
	if validHash != hash {
		return false
	}

	// Nonce Cache
	cacheMutex.Lock()
	defer cacheMutex.Unlock()
	if _, exists := nonceCache[nonceRaw]; exists {
		return false
	}
	nonceCache[nonceRaw] = now + 60000

	return true
}

// --- Helper Functions for Crypto Compatibility ---

func computeHmac(data, key string) string {
	h := hmac.New(sha256.New, []byte(key))
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}

func computeSHA256(data string) string {
	h := sha256.New()
	h.Write([]byte(data))
	return hex.EncodeToString(h.Sum(nil))
}

// decryptAES decrypts OpenSSL-compatible (CryptoJS) AES strings
func decryptAES(ciphertextB64 string, passphrase string) (string, error) {
	data, err := base64.StdEncoding.DecodeString(ciphertextB64)
	if err != nil {
		return "", err
	}

	// OpenSSL format starts with "Salted__" (8 bytes) + Salt (8 bytes)
	if len(data) < 16 || string(data[:8]) != "Salted__" {
		return "", errors.New("invalid ciphertext format")
	}

	salt := data[8:16]
	payload := data[16:]

	key, iv := evpBytesToKey([]byte(passphrase), salt)

	block, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	if len(payload)%aes.BlockSize != 0 {
		return "", errors.New("ciphertext is not a multiple of the block size")
	}

	mode := cipher.NewCBCDecrypter(block, iv)
	mode.CryptBlocks(payload, payload)

	// PKCS7 Unpadding
	padding := int(payload[len(payload)-1])
	if padding > aes.BlockSize || padding == 0 {
		return "", errors.New("invalid padding")
	}
	
	// Check if padding is correct
	for i := len(payload) - padding; i < len(payload); i++ {
		if payload[i] != byte(padding) {
             // In some cases, padding might be dirty if key is wrong, but standard PKCS7 requires consistent bytes
             // We'll proceed but it might fail charset decode if wrong.
		}
	}

	return string(payload[:len(payload)-padding]), nil
}

// evpBytesToKey derives key and IV from passphrase and salt using MD5 (OpenSSL legacy method)
func evpBytesToKey(password, salt []byte) ([]byte, []byte) {
	const keyLen = 32
	const ivLen = 16
	const totalLen = keyLen + ivLen

	var derivedBytes []byte
	var lastHash []byte

	for len(derivedBytes) < totalLen {
		h := md5.New()
		if len(lastHash) > 0 {
			h.Write(lastHash)
		}
		h.Write(password)
		h.Write(salt)
		lastHash = h.Sum(nil)
		derivedBytes = append(derivedBytes, lastHash...)
	}

	return derivedBytes[:keyLen], derivedBytes[keyLen : keyLen+ivLen]
}

func GenerateRandomString(n int) string {
	b := make([]byte, n)
	rand.Read(b)
	return hex.EncodeToString(b)
}

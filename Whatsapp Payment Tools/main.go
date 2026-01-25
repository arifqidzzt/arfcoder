package main

import (
	"bytes"
	"context"
	"crypto/md5"
	"crypto/sha512"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
	"sort"
	"strconv"
	"strings"
	"syscall"
	"time"

	"github.com/mdp/qrterminal/v3"
	_ "modernc.org/sqlite"

	"github.com/midtrans/midtrans-go"
	"github.com/midtrans/midtrans-go/snap"

	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/store/sqlstore"
	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"
	waLog "go.mau.fi/whatsmeow/util/log"
	waProto "go.mau.fi/whatsmeow/binary/proto"
)

// ==========================================
// 1. KONFIGURASI
// ==========================================
const (
	// MIDTRANS (Ganti KEY SANDBOX Kamu Disini)
	MidServerKey = "Mid-server-1qn4QIijjudMAU6vJ680ISJf" // CONTOH KEY KAMU
	IsProduction = false 

	// DIGIFLAZZ (WAJIB DIISI)
	DigiUser = "username_digi_kamu" 
	DigiKey  = "apikey_digi_kamu"   
	DigiURL  = "https://api.digiflazz.com/v1/transaction"
	DigiPricelistURL = "https://api.digiflazz.com/v1/price-list"
	
	Margin = 1500 
)

var client *whatsmeow.Client
var db *sql.DB

// --- SESSION STATE (Agar Bot Bisa Tanya Jawab) ---
type UserSession struct {
	Step      int    // 0:Idle, 1:TungguNomor, 2:TungguNominal, 3:Konfirmasi
	Command   string // beli_dana, beli_pulsa
	TempData  map[string]string
}
var sessions = make(map[string]*UserSession) // Key: Nomor HP

// --- DIGIFLAZZ STRUCTS ---
type DigiRequest struct {
	Username   string `json:"username"`
	BuyerSku   string `json:"buyer_sku_code"`
	CustomerNo string `json:"customer_no"`
	RefID      string `json:"ref_id"`
	Sign       string `json:"sign"`
	Cmd        string `json:"cmd,omitempty"` 
}
type DigiResponse struct {
	Data struct {
		Sn      string `json:"sn"`
		Status  string `json:"status"`
		Message string `json:"message"`
		Price   int64  `json:"price"`
		Rc      string `json:"rc"`
	} `json:"data"`
}
type DigiPriceListResp struct {
	Data []struct {
		ProductState string `json:"product_name"`
		Category     string `json:"category"`
		Brand        string `json:"brand"`
		SellerPrice  int64  `json:"price"`
		BuyerSkuCode string `json:"buyer_sku_code"`
		BuyerProductStatus bool `json:"buyer_product_status"`
	} `json:"data"`
}

func main() {
	dbLog := waLog.Stdout("Database", "ERROR", true)

	// Database Setup
	var err error
	db, err = sql.Open("sqlite", "file:bot_data.db?_pragma=journal_mode(WAL)&_pragma=busy_timeout(5000)")
	if err != nil { panic(err) }
	db.SetMaxOpenConns(1)

	// Init Table
	db.Exec(`CREATE TABLE IF NOT EXISTS users (nomor TEXT PRIMARY KEY, saldo INTEGER DEFAULT 0);`)
	db.Exec(`CREATE TABLE IF NOT EXISTS deposits (order_id TEXT PRIMARY KEY, nomor TEXT, amount INTEGER, status TEXT);`)
	db.Exec(`CREATE TABLE IF NOT EXISTS history_trx (ref_id TEXT PRIMARY KEY, nomor TEXT, sku TEXT, tujuan TEXT, harga_jual INTEGER, sn TEXT, status TEXT);`)

	// Midtrans Setup
	midtrans.ServerKey = MidServerKey
	midtrans.Environment = midtrans.Sandbox
	if IsProduction { midtrans.Environment = midtrans.Production }

	// WA Setup
	container, err := sqlstore.New(context.Background(), "sqlite", "file:bot_session.db?_pragma=foreign_keys(1)&_pragma=journal_mode(WAL)&_pragma=busy_timeout(5000)", dbLog)
	if err != nil { panic(err) }
	deviceStore, err := container.GetFirstDevice(context.Background())
	if err != nil { panic(err) }

	client = whatsmeow.NewClient(deviceStore, waLog.Stdout("Client", "INFO", true))
	client.AddEventHandler(eventHandler)

	if client.Store.ID == nil {
		qrChan, _ := client.GetQRChannel(context.Background())
		client.Connect()
		for evt := range qrChan {
			if evt.Event == "code" {
				qrterminal.GenerateHalfBlock(evt.Code, qrterminal.L, os.Stdout)
			}
		}
	} else {
		client.Connect()
		fmt.Println("✅ BOT AKTIF! Mode Tanya Jawab Ready.")
	}

	// Web Server
	go func() {
		http.HandleFunc("/callback", handleMidtransCallback)
		fmt.Println("🌏 Web Server jalan di port 8080")
		log.Fatal(http.ListenAndServe(":8080", nil))
	}()

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)
	<-c
	client.Disconnect()
}

// ==========================================
// LOGIC UTAMA (HANDLER PESAN)
// ==========================================
func eventHandler(evt interface{}) {
	switch v := evt.(type) {
	case *events.Message:
		if v.Info.IsFromMe { return }
		
		pesan := strings.TrimSpace(v.Message.GetConversation())
		if pesan == "" { pesan = strings.TrimSpace(v.Message.GetExtendedTextMessage().GetText()) }
		
		// Ambil Nomor Pengirim (JID Murni)
		pengirimJID := v.Info.Sender.ToNonAD()
		pengirim := pengirimJID.User // 628xxx

		// 1. CEK APAKAH USER SEDANG DALAM SESI TANYA JAWAB?
		if session, exists := sessions[pengirim]; exists {
			handleSessionInput(v, pengirim, pesan, session)
			return
		}

		// 2. COMMAND LIST
		args := strings.Fields(pesan)
		if len(args) == 0 { return }
		cmd := strings.ToLower(args[0])

		if cmd == "/menu" || cmd == "/help" || cmd == "menu" {
			sendMenu(v, pengirim)

		} else if cmd == "/deposit" {
			if len(args) != 2 { 
				reply(v, "❌ Format: */deposit [nominal]*\nContoh: */deposit 50000*")
				return 
			}
			amt, _ := strconv.Atoi(args[1])
			if amt < 10000 { reply(v, "❌ Minimal Rp 10.000"); return }
			handleRequestMidtrans(v, pengirim, int64(amt))

		} else if cmd == "/saldo" || cmd == "/cek" {
			saldo := getSaldo(pengirim)
			reply(v, fmt.Sprintf("💰 Saldo Kamu: *Rp %d*", saldo))

		} else if cmd == "/harga" || cmd == "/list" {
			if len(args) < 2 { reply(v, "❌ Contoh: */harga dana*"); return }
			handleCekHarga(v, args[1])

		} else if cmd == "/beli" || cmd == "/buy" {
			// MODIFIKASI: Jika user cuma ketik "/beli dana", masuk ke mode tanya jawab
			if len(args) == 2 {
				startSession(v, pengirim, args[1]) // Mulai sesi
			} else if len(args) >= 3 {
				// Kalau user ketik lengkap: /beli dana 0812 20000 (Langsung proses)
				handleDirectOrder(v, args, pengirim)
			} else {
				reply(v, "❌ Ketik nama produk.\nContoh: */beli dana* atau */beli pulsa*")
			}
		}
	}
}

// ==========================================
// A. FITUR SESI TANYA JAWAB (INTERAKTIF)
// ==========================================
func startSession(v *events.Message, pengirim, produk string) {
	sessions[pengirim] = &UserSession{
		Step:    1,
		Command: strings.ToUpper(produk),
		TempData: make(map[string]string),
	}
	reply(v, "📱 Masukkan *Nomor Tujuan*:")
}

func handleSessionInput(v *events.Message, pengirim, pesan string, session *UserSession) {
	// Batalkan sesi
	if strings.ToLower(pesan) == "batal" || strings.ToLower(pesan) == "b" {
		delete(sessions, pengirim)
		reply(v, "❌ Transaksi Dibatalkan.")
		return
	}

	switch session.Step {
	case 1: // User kirim Nomor Tujuan
		// Normalisasi nomor
		nomor := pesan
		if strings.HasPrefix(nomor, "08") { nomor = "62" + nomor[1:] }
		
		session.TempData["tujuan"] = nomor
		session.Step = 2
		reply(v, "💰 Masukkan *Nominal* (Contoh: 20000):")

	case 2: // User kirim Nominal
		nominal := pesan
		session.TempData["nominal"] = nominal
		
		// Buat SKU (DANA + 20 -> DANA20)
		nomInt, _ := strconv.Atoi(nominal)
		nomKode := nominal
		if len(nominal) >= 4 { nomKode = strconv.Itoa(nomInt / 1000) }
		
		sku := session.Command + nomKode // DANA20
		session.TempData["sku"] = sku

		// Cek Harga Dulu
		hargaModal, namaProd, err := getHargaProdukDigi(sku)
		if err != nil {
			delete(sessions, pengirim)
			reply(v, "❌ Produk tidak ditemukan/gangguan.\nCek nominal lagi.")
			return
		}
		
		hargaJual := hargaModal + Margin
		session.TempData["harga"] = fmt.Sprintf("%d", hargaJual)
		
		session.Step = 3 // Konfirmasi
		
		msg := fmt.Sprintf(`⚠️ *KONFIRMASI TRANSAKSI*
		
📦 Produk: %s
📱 Tujuan: %s
💰 Harga: *Rp %d*

Ketik *Y* untuk Lanjut.
Ketik *B* untuk Batal.`, namaProd, session.TempData["tujuan"], hargaJual)
		reply(v, msg)

	case 3: // Konfirmasi Y/N
		if strings.ToUpper(pesan) == "Y" || strings.ToUpper(pesan) == "YA" {
			// Eksekusi
			sku := session.TempData["sku"]
			tujuan := session.TempData["tujuan"]
			harga, _ := strconv.ParseInt(session.TempData["harga"], 10, 64)
			
			delete(sessions, pengirim) // Hapus sesi
			processTransaksi(v, pengirim, sku, tujuan, harga)
		} else {
			reply(v, "Ketik *Y* untuk lanjut, *B* untuk batal.")
		}
	}
}

// ==========================================
// B. EKSEKUSI TRANSAKSI
// ==========================================
func handleDirectOrder(v *events.Message, args []string, pengirim string) {
	// Logic lama untuk user yang ketik manual
	// ... (Sama seperti sebelumnya, disederhanakan)
	reply(v, "Gunakan format pendek: */beli dana* lalu ikuti petunjuk.")
}

func processTransaksi(v *events.Message, pengirim, sku, tujuan string, hargaJual int64) {
	reply(v, "⏳ *Memproses...*")

	if getSaldo(pengirim) < hargaJual {
		reply(v, "❌ Saldo tidak cukup.")
		return
	}

	refID := fmt.Sprintf("TRX-%s-%d", pengirim, time.Now().Unix())
	resp, err := callDigiflazz(sku, tujuan, refID)
	
	if err != nil { reply(v, "❌ Gagal koneksi provider."); return }
	if resp.Data.Status == "Gagal" {
		reply(v, fmt.Sprintf("❌ Gagal: %s", resp.Data.Message))
		return
	}

	kurangiSaldo(pengirim, hargaJual)
	db.Exec("INSERT INTO history_trx VALUES(?, ?, ?, ?, ?, ?, ?)", refID, pengirim, sku, tujuan, hargaJual, resp.Data.Sn, "SUKSES")

	reply(v, fmt.Sprintf(`✅ *SUKSES*
SN: %s
Sisa Saldo: Rp %d`, resp.Data.Sn, getSaldo(pengirim)))
}

// ==========================================
// C. DEPOSIT & NOTIFIKASI (FIXED)
// ==========================================
func handleRequestMidtrans(v *events.Message, pengirim string, nominal int64) {
	reply(v, "⏳ _Membuat Link..._")
	orderID := fmt.Sprintf("DEP-%s-%d", pengirim, time.Now().Unix())
	
	req := &snap.Request{
		TransactionDetails: midtrans.TransactionDetails{OrderID: orderID, GrossAmt: nominal},
		CustomerDetail: &midtrans.CustomerDetails{FName: "User", Phone: pengirim},
		EnabledPayments: snap.AllSnapPaymentType,
	}
	
	snapResp, err := snap.CreateTransaction(req)
	if err != nil { reply(v, "❌ Error: "+err.Error()); return }

	db.Exec("INSERT INTO deposits(order_id, nomor, amount, status) VALUES(?, ?, ?, ?)", orderID, pengirim, nominal, "pending")

	// FORMAT TOMBOL CARD (Preview Link)
	msg := fmt.Sprintf(`💳 *TAGIHAN DEPOSIT*

Nominal: *Rp %d*
Ref: %s

👇 *KLIK DISINI UNTUK BAYAR* 👇
%s`, nominal, orderID, snapResp.RedirectURL)

	reply(v, msg)
}

func handleMidtransCallback(w http.ResponseWriter, r *http.Request) {
	body, _ := ioutil.ReadAll(r.Body)
	var notif map[string]interface{}
	json.Unmarshal(body, &notif)

	orderID, _ := notif["order_id"].(string)
	
	// HANDLE TEST NOTIF MIDTRANS
	if strings.Contains(orderID, "test") {
		w.Header().Set("Content-Type", "application/json"); w.Write([]byte(`{"status":"OK"}`)); return
	}

	trxStatus, _ := notif["transaction_status"].(string)
	statusCode, _ := notif["status_code"].(string)
	grossAmt, _ := notif["gross_amount"].(string)
	signatureKey, _ := notif["signature_key"].(string)

	input := orderID + statusCode + grossAmt + MidServerKey
	hasher := sha512.New()
	hasher.Write([]byte(input))
	if signatureKey != hex.EncodeToString(hasher.Sum(nil)) {
		http.Error(w, "Invalid Sig", 403); return
	}

	if trxStatus == "settlement" || trxStatus == "capture" {
		processSuccessDeposit(orderID)
	} else if trxStatus == "deny" || trxStatus == "expire" {
		db.Exec("UPDATE deposits SET status = 'failed' WHERE order_id = ?", orderID)
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write([]byte(`{"status":"OK"}`))
}

func processSuccessDeposit(orderID string) {
	var statusDB, nomorUser string
	var amount int64

	err := db.QueryRow("SELECT status, nomor, amount FROM deposits WHERE order_id = ?", orderID).Scan(&statusDB, &nomorUser, &amount)
	
	if err == nil && statusDB == "pending" {
		tambahSaldo(nomorUser, amount)
		db.Exec("UPDATE deposits SET status = 'success' WHERE order_id = ?", orderID)
		
		fmt.Println("✅ DEPOSIT SUKSES:", nomorUser, "Rp", amount)
		
		// NOTIFIKASI DEBUG
		err := kirimNotifikasiAman(nomorUser, amount)
		if err != nil {
			fmt.Println("❌ Gagal Kirim Notif WA:", err)
		}
	}
}

func kirimNotifikasiAman(nomor string, amount int64) error {
	// 1. Bersihkan Nomor
	nomor = strings.ReplaceAll(nomor, "+", "")
	if !strings.HasSuffix(nomor, "@s.whatsapp.net") {
		nomor = nomor + "@s.whatsapp.net"
	}
	
	// 2. Parse JID
	jid, err := types.ParseJID(nomor)
	if err != nil { return err }

	// 3. Pesan
	msg := fmt.Sprintf(`✅ *DEPOSIT BERHASIL!*

Dana Masuk: *Rp %d*
Total Saldo: *Rp %d*

Terima kasih!`, amount, getSaldo(strings.Split(nomor, "@")[0]))

	// 4. Kirim (Penting: Context Background)
	_, err = client.SendMessage(context.Background(), jid, &waProto.Message{
		Conversation: strPtr(msg),
	})
	return err
}

// ==========================================
// HELPER API (SIGNATURE FIX)
// ==========================================
func callDigiflazz(sku, customerNo, refID string) (*DigiResponse, error) {
	signStr := DigiUser + DigiKey + refID
	hasher := md5.New()
	hasher.Write([]byte(signStr))
	sign := fmt.Sprintf("%x", hasher.Sum(nil))

	payload := DigiRequest{Username: DigiUser, BuyerSku: sku, CustomerNo: customerNo, RefID: refID, Sign: sign}
	jsonVal, _ := json.Marshal(payload)
	resp, err := http.Post(DigiURL, "application/json", bytes.NewBuffer(jsonVal))
	if err != nil { return nil, err }
	defer resp.Body.Close()

	bodyBytes, _ := ioutil.ReadAll(resp.Body)
	var data DigiResponse
	json.Unmarshal(bodyBytes, &data)
	return &data, nil
}

func getDigiPricelist() ([]struct {
	ProductState string `json:"product_name"`
	Category     string `json:"category"`
	Brand        string `json:"brand"`
	SellerPrice  int64  `json:"price"`
	BuyerSkuCode string `json:"buyer_sku_code"`
	BuyerProductStatus bool `json:"buyer_product_status"`
}, error) {
	// FIX SIGNATURE PRICELIST: md5(username + apikey + "pricelist")
	signStr := DigiUser + DigiKey + "pricelist" 
	hasher := md5.New()
	hasher.Write([]byte(signStr))
	
	payload := DigiRequest{Username: DigiUser, Sign: fmt.Sprintf("%x", hasher.Sum(nil)), Cmd: "prepaid"}
	jsonVal, _ := json.Marshal(payload)
	
	resp, err := http.Post(DigiPricelistURL, "application/json", bytes.NewBuffer(jsonVal))
	if err != nil { return nil, err }
	defer resp.Body.Close()

	bodyBytes, _ := ioutil.ReadAll(resp.Body)
	var data DigiPriceListResp
	json.Unmarshal(bodyBytes, &data)
	return data.Data, nil
}

func getHargaProdukDigi(sku string) (int64, string, error) {
	list, err := getDigiPricelist()
	if err != nil { return 0, "", err }
	for _, p := range list {
		if strings.EqualFold(p.BuyerSkuCode, sku) {
			return p.SellerPrice, p.ProductState, nil
		}
	}
	return 0, "", fmt.Errorf("not found")
}

func handleCekHarga(v *events.Message, filter string) {
	reply(v, "🔍 _Mengambil data..._")
	list, err := getDigiPricelist()
	if err != nil { reply(v, "❌ Gagal ambil data."); return }

	// Urutkan Harga
	sort.Slice(list, func(i, j int) bool { return list[i].SellerPrice < list[j].SellerPrice })

	var res []string
	filter = strings.ToUpper(filter)
	c := 0
	for _, p := range list {
		if (strings.Contains(strings.ToUpper(p.Brand), filter) || strings.Contains(strings.ToUpper(p.Category), filter)) && p.BuyerProductStatus {
			harga := p.SellerPrice + Margin
			res = append(res, fmt.Sprintf("• %s: *Rp %d*", p.BuyerSkuCode, harga))
			c++
		}
		if c >= 15 { break }
	}
	if len(res) == 0 { reply(v, "❌ Produk tidak ditemukan.") } else {
		reply(v, fmt.Sprintf("📋 *HARGA %s*\n\n%s", filter, strings.Join(res, "\n")))
	}
}

// Helper DB
func getSaldo(nomor string) int64 {
	var s int64
	db.QueryRow("SELECT saldo FROM users WHERE nomor = ?", nomor).Scan(&s)
	return s
}
func tambahSaldo(nomor string, jumlah int64) {
	db.Exec(`INSERT INTO users(nomor, saldo) VALUES(?, ?) ON CONFLICT(nomor) DO UPDATE SET saldo = saldo + ?`, nomor, jumlah, jumlah)
}
func kurangiSaldo(nomor string, jumlah int64) {
	db.Exec("UPDATE users SET saldo = saldo - ? WHERE nomor = ?", jumlah, nomor)
}
func sendMenu(v *events.Message, pengirim string) {
	reply(v, `🤖 *MENU BOT*
1. */deposit* - Isi Saldo
2. */beli dana* - Transaksi
3. */harga dana* - Cek Harga
4. */saldo* - Cek Saldo`)
}
func reply(v *events.Message, text string) {
	client.SendMessage(context.Background(), v.Info.Chat, &waProto.Message{Conversation: strPtr(text)})
}
func strPtr(s string) *string { return &s }
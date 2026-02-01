package whatsapp

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"context"
	"fmt"
	"os/exec"
	"runtime"
	"strings"
	"sync"
	"time"

	_ "github.com/lib/pq"
	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/proto/waE2E"
	"go.mau.fi/whatsmeow/store/sqlstore"
	"go.mau.fi/whatsmeow/types"
	"go.mau.fi/whatsmeow/types/events"
	waLog "go.mau.fi/whatsmeow/util/log"
	"google.golang.org/protobuf/proto"
)

var (
	Client    *whatsmeow.Client
	mu        sync.Mutex
	currentQR string
)

func Connect() error {
	dbLog := waLog.Stdout("Database", "ERROR", true)
	// FIX: Add context
	store, err := sqlstore.New(context.Background(), "postgres", config.DatabaseURL, dbLog)
	if err != nil {
		return fmt.Errorf("failed to connect to WA store: %v", err)
	}

	// FIX: Add context
	device, err := store.GetFirstDevice(context.Background())
	if err != nil {
		return fmt.Errorf("failed to get device: %v", err)
	}

	clientLog := waLog.Stdout("Client", "INFO", true)
	Client = whatsmeow.NewClient(device, clientLog)
	Client.AddEventHandler(eventHandler)

	if Client.Store.ID == nil {
		qrChan, _ := Client.GetQRChannel(context.Background())
		err = Client.Connect()
		if err != nil { return err }
		go func() {
			for evt := range qrChan {
				if evt.Event == "code" {
					mu.Lock()
					currentQR = evt.Code
					mu.Unlock()
					fmt.Println("QR Code updated")
				}
			}
		}()
	} else {
		err = Client.Connect()
		if err != nil { return err }
	}

	return nil
}

func GetQR() string {
	mu.Lock()
	defer mu.Unlock()
	return currentQR
}

func IsConnected() bool {
	if Client == nil {
		return false
	}
	return Client.IsConnected()
}

func IsLoggedIn() bool {
	if Client == nil || Client.Store == nil {
		return false
	}
	return Client.Store.ID != nil
}

func Logout() {
	if Client != nil {
		// FIX: Add context
		Client.Logout(context.Background())
		// Force delete to ensure next Connect generates QR
		if Client.Store != nil {
			Client.Store.Delete(context.Background())
		}
		mu.Lock()
		currentQR = ""
		mu.Unlock()
	}
}

func SendMessage(phone string, text string) error {
	mu.Lock()
	defer mu.Unlock()
	
	if Client == nil || !Client.IsConnected() {
		return fmt.Errorf("WA Client disconnected")
	}

	phone = strings.ReplaceAll(phone, "+", "")
	phone = strings.ReplaceAll(phone, "-", "")
	phone = strings.ReplaceAll(phone, " ", "")
	if strings.HasPrefix(phone, "0") {
		phone = "62" + phone[1:]
	}
	if !strings.HasSuffix(phone, "@s.whatsapp.net") {
		phone += "@s.whatsapp.net"
	}

	jid, err := types.ParseJID(phone)
	if err != nil { return err }

	msg := &waE2E.Message{ Conversation: proto.String(text) }
	_, err = Client.SendMessage(context.Background(), jid, msg)
	return err
}

func eventHandler(evt interface{}) {
	switch v := evt.(type) {
	case *events.Message:
		handleMessage(v)
	case *events.Connected:
		mu.Lock()
		currentQR = ""
		mu.Unlock()
		fmt.Println("WhatsApp Connected!")
	}
}

func handleMessage(evt *events.Message) {
	if evt.Info.IsFromMe { return }

	text := ""
	if evt.Message.Conversation != nil {
		text = *evt.Message.Conversation
	} else if evt.Message.ExtendedTextMessage != nil {
		text = *evt.Message.ExtendedTextMessage.Text
	}
	
	text = strings.TrimSpace(text)
	if text == "" { return }

	senderJID := evt.Info.Sender
	senderPhone := strings.Split(senderJID.User, "@")[0]

	var user models.User
	localPhone := "0" + senderPhone[2:]
	
	err := database.DB.Where("\"phoneNumber\" = ? OR \"phoneNumber\" = ? OR \"phoneNumber\" = ?", 
		senderPhone, localPhone, "+"+senderPhone).First(&user).Error

	isAdmin := err == nil && (user.Role == models.RoleAdmin || user.Role == models.RoleSuperAdmin)

	cmd := strings.ToUpper(text)

	if cmd == "CEK STATUS" {
		status := "User Biasa"
		if isAdmin { status = "Admin" }
		reply(evt, fmt.Sprintf("Halo %s\nStatus Anda: %s\nID: %s", user.Name, status, user.ID))
		return
	}

	if cmd == "INFO VPS" {
		if !isAdmin {
			reply(evt, fmt.Sprintf("⛔ Akses Ditolak. Nomor %s tidak dikenal/bukan admin.", senderPhone))
			return
		}
		reply(evt, "⏳ Mengumpulkan data server... (Estimasi 5-10 detik)")

		// 1. Disk
		diskOut, _ := exec.Command("sh", "-c", "df -h / | tail -1 | awk '{print $3 \" / \" $2 \" (\" $5 \")\"}'").Output()
		disk := strings.TrimSpace(string(diskOut))
		if disk == "" { disk = "N/A" }

		// 2. OS Distro
		osOut, _ := exec.Command("sh", "-c", "grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '\"'").Output()
		distro := strings.TrimSpace(string(osOut))
		if distro == "" { distro = runtime.GOOS }

		// 3. IP Info
		ipOut, _ := exec.Command("curl", "-s", "ipinfo.io/json").Output()
		ipJson := string(ipOut)
		ip := getJsonValue(ipJson, "ip")
		city := getJsonValue(ipJson, "city")
		country := getJsonValue(ipJson, "country")
		org := getJsonValue(ipJson, "org")

		// 4. CPU
		cpuOut, _ := exec.Command("sh", "-c", "grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2").Output()
		cpuModel := strings.TrimSpace(string(cpuOut))
		if cpuModel == "" { cpuModel = "Unknown CPU" }
		
		// 5. RAM
		memOut, _ := exec.Command("free", "-h").Output()
		memLines := strings.Split(string(memOut), "\n")
		ram := "N/A"
		if len(memLines) > 1 {
			fields := strings.Fields(memLines[1])
			if len(fields) >= 4 {
				ram = fmt.Sprintf("%s Free / %s Total", fields[3], fields[1])
			}
		}

		// 6. Uptime
		upOut, _ := exec.Command("uptime", "-p").Output()
		uptime := strings.TrimSpace(string(upOut))

		// 7. Speedtest
		speedOut, _ := exec.Command("speedtest-cli", "--simple").Output()
		speedStr := string(speedOut)
		dl := "N/A"
		ul := "N/A"
		if strings.Contains(speedStr, "Download:") {
			parts := strings.Split(speedStr, "\n")
			for _, p := range parts {
				if strings.HasPrefix(p, "Download:") { dl = strings.TrimPrefix(p, "Download: ") }
				if strings.HasPrefix(p, "Upload:") { ul = strings.TrimPrefix(p, "Upload: ") }
			}
		}

		replyMsg := fmt.Sprintf(`
🚀 *ARFCODER SERVER STATUS*
---------------------------
💻 *SISTEM OPERASI*
• Distro: %s
• Go Ver: %s
• Uptime: %s

🌍 *JARINGAN & LOKASI*
• IP: %s
• Lokasi: %s, %s
• ISP: %s
• Speed (DL): %s
• Speed (UL): %s

🧠 *RESOURCE*
• CPU: %s (%d Core)
• RAM: %s
• Disk: %s

---------------------------
Bot Active | %s
`, 
			distro, 
			runtime.Version(),
			uptime,
			ip, city, country, org,
			dl, ul,
			cpuModel, runtime.NumCPU(),
			ram, disk,
			time.Now().Format("02 Jan 2006 15:04"),
		)

		reply(evt, strings.TrimSpace(replyMsg))
		return
	}
	
	if cmd == "LIST ORDER" {
		if !isAdmin { return }
		var orders []models.Order
		database.DB.Limit(5).Order("\"createdAt\" desc").Preload("User").Find(&orders)
		
		resp := "📦 5 Pesanan Terakhir:\n"
		for _, o := range orders {
			resp += fmt.Sprintf("- %s: Rp %.0f (%s)\n", o.InvoiceNumber, o.TotalAmount, o.Status)
		}
		reply(evt, resp)
		return
	}
}

func reply(evt *events.Message, text string) {
	msg := &waE2E.Message{ Conversation: proto.String(text) }
	Client.SendMessage(context.Background(), evt.Info.Sender, msg)
}

func getJsonValue(jsonStr, key string) string {
	// Simple lookup: "key": "value"
	keyPattern := fmt.Sprintf("\"%s\": \"", key)
	idx := strings.Index(jsonStr, keyPattern)
	if idx == -1 { return "?" }
	
	start := idx + len(keyPattern)
	end := strings.Index(jsonStr[start:], "\"")
	if end == -1 { return "?" }
	
	return jsonStr[start : start+end]
}

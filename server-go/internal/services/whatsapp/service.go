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

func Logout() {
	if Client != nil {
		// FIX: Add context
		Client.Logout(context.Background())
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

	if cmd == "INFO VPS" {
		if !isAdmin {
			reply(evt, fmt.Sprintf("⛔ Akses Ditolak. Nomor %s tidak dikenal/bukan admin.", senderPhone))
			return
		}
		reply(evt, "⏳ Mengumpulkan data server...")
		
		// Run speedtest cli if available
		out, _ := exec.Command("speedtest-cli", "--simple").Output()
		speed := string(out)
		if speed == "" { speed = "Speedtest CLI not installed or failed" }

		reply(evt, fmt.Sprintf("%s\n\nSpeed:\n%s", getServerStats(), speed))
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

func getServerStats() string {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return fmt.Sprintf("OS: %s | Go: %s | Alloc: %v MB", runtime.GOOS, runtime.Version(), m.Alloc/1024/1024)
}

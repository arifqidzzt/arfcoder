package whatsapp

import (
	"arfcoder-go/internal/config"
	"arfcoder-go/internal/database"
	"arfcoder-go/internal/models"
	"context"
	"fmt"
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
	
	// Fix: Add context.Background() as per compiler requirement
	store, err := sqlstore.New(context.Background(), "postgres", config.DatabaseURL, dbLog)
	if err != nil {
		return fmt.Errorf("failed to connect to WA store: %v", err)
	}

	// Fix: Add context.Background()
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
		if err != nil {
			return err
		}
		go func() {
			for evt := range qrChan {
				if evt.Event == "code" {
					mu.Lock()
					currentQR = evt.Code
					mu.Unlock()
					fmt.Println("QR Code updated (Available via API)")
				} else {
					fmt.Println("Login event:", evt.Event)
				}
			}
		}()
	} else {
		err = Client.Connect()
		if err != nil {
			return err
		}
	}

	return nil
}

func GetQR() string {
	mu.Lock()
	defer mu.Unlock()
	return currentQR
}

func Logout() {
	if Client != nil {
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
	if err != nil {
		return err
	}

	// Fix: Use waE2E.Message
	msg := &waE2E.Message{
		Conversation: proto.String(text),
	}

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
	if evt.Info.IsFromMe {
		return 
	}

	text := ""
	if evt.Message.Conversation != nil {
		text = *evt.Message.Conversation
	} else if evt.Message.ExtendedTextMessage != nil {
		text = *evt.Message.ExtendedTextMessage.Text
	}
	
	text = strings.TrimSpace(text)
	if text == "" {
		return
	}

	senderJID := evt.Info.Sender
	senderPhone := strings.Split(senderJID.User, "@")[0]

	var user models.User
	localPhone := "0" + senderPhone[2:]
	
	err := database.DB.Where("phone_number = ? OR phone_number = ? OR phone_number = ?", 
		senderPhone, localPhone, "+"+senderPhone).First(&user).Error

	isAdmin := err == nil && (user.Role == models.RoleAdmin || user.Role == models.RoleSuperAdmin)

	cmd := strings.ToUpper(text)

	if cmd == "INFO VPS" {
		if !isAdmin {
			reply(evt, "⛔ Akses Ditolak. Anda bukan Admin.")
			return
		}
		reply(evt, "⏳ Mengumpulkan data server...")
		reply(evt, getServerStats())
		return
	}
	
	if cmd == "LIST ORDER" {
		if !isAdmin { return }
		var orders []models.Order
		database.DB.Limit(5).Order("created_at desc").Find(&orders)
		reply(evt, fmt.Sprintf("📦 5 Pesanan Terakhir:\n%d found (Stub)", len(orders)))
		return
	}
}

func reply(evt *events.Message, text string) {
	// Fix: Use waE2E.Message
	msg := &waE2E.Message{
		Conversation: proto.String(text),
	}
	Client.SendMessage(context.Background(), evt.Info.Sender, msg)
}

func getServerStats() string {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return fmt.Sprintf("OS: %s | Go: %s | Alloc: %v MB", runtime.GOOS, runtime.Version(), m.Alloc/1024/1024)
}

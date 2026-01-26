package services

import (
	"context"
	"fmt"
	"log"
	"sync"

	"github.com/mattn/go-sqlite3"
	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/store/sqlstore"
	waLog "go.mau.fi/whatsmeow/util/log"
	"go.mau.fi/whatsmeow/types"
	waProto "go.mau.fi/whatsmeow/binary/proto" // Correct import for Message struct
	"google.golang.org/protobuf/proto"
)

var (
	WAClient *whatsmeow.Client
	waLock   sync.Mutex
)

// InitWhatsApp initializes the WhatsApp client
func InitWhatsApp() {
	// Register sqlite3 driver explicitly to avoid compiler optimization removing it
	_ = sqlite3.SQLITE_DELETE

	dbLog := waLog.Stdout("Database", "DEBUG", true)
	
	// Create/Connect to SQLite store for session (Need Context in newer versions)
	container, err := sqlstore.New(context.Background(), "sqlite3", "file:wa_session.db?_foreign_keys=on", dbLog)
	if err != nil {
		log.Fatal("Failed to connect to WA session DB:", err)
	}

	// Get first device (Need Context)
	deviceStore, err := container.GetFirstDevice(context.Background())
	if err != nil {
		log.Fatal("Failed to get device store:", err)
	}

	clientLog := waLog.Stdout("Client", "INFO", true)
	WAClient = whatsmeow.NewClient(deviceStore, clientLog)

	if WAClient.Store.ID == nil {
		log.Println("WA: No session found. Waiting for QR Scan trigger.")
	} else {
		err = WAClient.Connect()
		if err != nil {
			log.Println("WA: Failed to connect:", err)
		} else {
			log.Println("WA: Connected successfully!")
		}
	}
}

// GenerateQR returns a channel to stream QR codes
func GenerateQR() (<-chan string, error) {
	waLock.Lock()
	defer waLock.Unlock()

	if WAClient.IsConnected() {
		return nil, fmt.Errorf("already connected")
	}

	if WAClient.Store.ID == nil {
		qrChan, _ := WAClient.GetQRChannel(context.Background())
		err := WAClient.Connect()
		if err != nil {
			return nil, err
		}
		
		strChan := make(chan string)
		go func() {
			defer close(strChan)
			for evt := range qrChan {
				if evt.Event == "code" {
					strChan <- evt.Code
				} else {
					return 
				}
			}
		}()
		return strChan, nil
	}
	
	err := WAClient.Connect()
	return nil, err
}

func SendMessage(phone string, message string) error {
	if WAClient == nil || !WAClient.IsConnected() {
		return fmt.Errorf("WA client not connected")
	}

	jid, err := types.ParseJID(phone + "@s.whatsapp.net")
	if err != nil {
		return err
	}

	// Correct struct usage: waProto.Message
	_, err = WAClient.SendMessage(context.Background(), jid, &waProto.Message{
		Conversation: proto.String(message),
	})
	return err
}

func LogoutWhatsApp() error {
	if WAClient != nil {
		// Need context for Logout in newer versions
		WAClient.Logout(context.Background())
		InitWhatsApp() 
	}
	return nil
}

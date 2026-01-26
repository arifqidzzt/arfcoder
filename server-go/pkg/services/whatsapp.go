package services

import (
	"context"
	"fmt"
	"log"
	"os"
	"sync"

	"github.com/mattn/go-sqlite3"
	"go.mau.fi/whatsmeow"
	"go.mau.fi/whatsmeow/store/sqlstore"
	waLog "go.mau.fi/whatsmeow/util/log"
	"go.mau.fi/whatsmeow/types"
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
	
	// Create/Connect to SQLite store for session
	container, err := sqlstore.New("sqlite3", "file:wa_session.db?_foreign_keys=on", dbLog)
	if err != nil {
		log.Fatal("Failed to connect to WA session DB:", err)
	}

	// Get first device
	deviceStore, err := container.GetFirstDevice()
	if err != nil {
		log.Fatal("Failed to get device store:", err)
	}

	clientLog := waLog.Stdout("Client", "INFO", true)
	WAClient = whatsmeow.NewClient(deviceStore, clientLog)

	// Handler for incoming events (optional, maybe for auto-reply later)
	// WAClient.AddEventHandler(eventHandler)

	if WAClient.Store.ID == nil {
		// No session, need to login via handler later
		log.Println("WA: No session found. Waiting for QR Scan trigger.")
	} else {
		// Already logged in, connect
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
		
		// Wrap in string channel for simpler consumption
		strChan := make(chan string)
		go func() {
			defer close(strChan)
			for evt := range qrChan {
				if evt.Event == "code" {
					strChan <- evt.Code
				} else {
					// Timeout or success
					return 
				}
			}
		}()
		return strChan, nil
	}
	
	// Reconnect if session exists but disconnected
	err := WAClient.Connect()
	return nil, err
}

func SendMessage(phone string, message string) error {
	if WAClient == nil || !WAClient.IsConnected() {
		return fmt.Errorf("WA client not connected")
	}

	// Format: 628xxx -> 628xxx@s.whatsapp.net
	jid, err := types.ParseJID(phone + "@s.whatsapp.net")
	if err != nil {
		return err
	}

	_, err = WAClient.SendMessage(context.Background(), jid, &whatsmeow.Message{
		Conversation: proto.String(message),
	})
	return err
}

func LogoutWhatsApp() error {
	if WAClient != nil {
		WAClient.Logout()
		// Re-init to clear memory
		InitWhatsApp() 
	}
	return nil
}

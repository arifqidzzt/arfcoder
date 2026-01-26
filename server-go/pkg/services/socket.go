package services

import (
	"log"

	socketio "github.com/googollee/go-socket.io"
)

var Server *socketio.Server

func InitSocket() *socketio.Server {
	server := socketio.NewServer(nil)

	server.OnConnect("/", func(s socketio.Conn) error {
		s.SetContext("")
		log.Println("connected:", s.ID())
		return nil
	})

	server.OnEvent("/", "join_admin", func(s socketio.Conn, msg string) {
		s.Join("admin_room")
	})

	server.OnEvent("/", "sendMessage", func(s socketio.Conn, msg map[string]interface{}) {
		// Logika simpan pesan ke DB bisa dipanggil di sini via Handler
		// Untuk sekarang kita broadcast saja
		// server.BroadcastToRoom("/", "admin_room", "receiveMessage", msg)
		server.BroadcastToAll("receiveMessage", msg)
	})

	server.OnError("/", func(s socketio.Conn, e error) {
		log.Println("meet error:", e)
	})

	server.OnDisconnect("/", func(s socketio.Conn, reason string) {
		log.Println("closed", reason)
	})

	go server.Serve()
	Server = server
	return server
}

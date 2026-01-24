'use client';

import { useEffect, useState, useCallback } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import axios from 'axios';
import { MessageSquare, User, Send, Inbox } from 'lucide-react';
import { io, Socket } from 'socket.io-client';

export default function AdminChatPage() {
  const { token, user } = useAuthStore();
  const [conversations, setConversations] = useState<any[]>([]);
  const [activeChat, setActiveChat] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState('');
  const [socket, setSocket] = useState<Socket | null>(null);
  const [isConnected, setIsConnected] = useState(false);

  // 1. Inisialisasi Socket Global
  useEffect(() => {
    const s = io(process.env.NEXT_PUBLIC_SOCKET_URL || '');
    setSocket(s);
    
    s.on('connect', () => setIsConnected(true));
    s.on('disconnect', () => setIsConnected(false));

    socket.on('receiveMessage', (msg) => {
      // Hanya masukkan ke layar jika pesan milik user yang sedang dibuka
      // atau pesan dari admin sendiri yang ditujukan ke user tersebut
      setMessages((prev) => {
        const isFromActiveUser = msg.senderId === activeChat?.id;
        const isFromAdminToActiveUser = msg.isAdmin && msg.targetUserId === activeChat?.id;
        
        if (activeChat && (isFromActiveUser || isFromAdminToActiveUser)) {
          return [...prev, msg];
        }
        return prev;
      });
      fetchConversations();
    });

    // Cleanup function yang sangat penting!
    return () => { 
      socket.off('receiveMessage');
      socket.off('connect');
      socket.off('disconnect');
      socket.disconnect(); 
    };
  }, [activeChat?.id]); // Re-subscribe when activeChat changes

  const fetchConversations = async () => {
    try {
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/users`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setConversations(res.data);
    } catch (err) { console.error(err); }
  };

  useEffect(() => {
    fetchConversations();
  }, []);

  // 2. Fungsi Load Chat (Wajib dibungkus useCallback agar stabil)
  const loadChat = useCallback(async (targetUser: any) => {
    if (!targetUser) return;
    setActiveChat(targetUser);
    setMessages([]); // Hapus pesan lama seketika!
    
    try {
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/chat/${targetUser.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setMessages(res.data);
    } catch (err) {
      console.error("Gagal load history:", err);
    }
  }, [token]);

  const handleSend = () => {
    if (!input || !activeChat || !socket) return;
    
    const msgData = {
      content: input,
      senderId: user?.id,
      isAdmin: true,
      targetUserId: activeChat.id
    };

    socket.emit('sendMessage', msgData);
    setInput('');
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <main className="flex-grow flex mt-16 overflow-hidden max-h-[calc(100vh-64px)]">
        {/* Sidebar */}
        <div className="w-80 bg-white border-r border-gray-200 flex flex-col">
          <div className="p-4 border-b">
            <h2 className="font-bold flex items-center gap-2">
              <Inbox size={18}/> Pesan Masuk 
              <span className={`w-2 h-2 rounded-full ${isConnected ? 'bg-green-500' : 'bg-red-500'}`}></span>
            </h2>
          </div>
          <div className="flex-1 overflow-y-auto">
            {conversations.map(u => (
              <div key={u.id} onClick={() => loadChat(u)} className={`p-4 flex items-center gap-3 cursor-pointer border-b border-gray-50 hover:bg-gray-50 ${activeChat?.id === u.id ? 'bg-black text-white' : ''}`}>
                <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold ${activeChat?.id === u.id ? 'bg-white text-black' : 'bg-gray-200 text-gray-500'}`}>
                  {u.name.substring(0, 2).toUpperCase()}
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold truncate">{u.name}</p>
                  <p className={`text-xs truncate ${activeChat?.id === u.id ? 'text-gray-300' : 'text-gray-400'}`}>{u.email}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Chat Area - Menggunakan KEY agar dipaksa render ulang saat ganti user */}
        <div className="flex-1 flex flex-col bg-white" key={activeChat?.id || 'empty'}>
          {activeChat ? (
            <>
              <div className="p-4 border-b border-gray-100 flex items-center justify-between bg-white sticky top-0">
                <h3 className="font-bold">{activeChat.name}</h3>
                <span className="text-[10px] bg-gray-100 px-2 py-1 rounded font-bold uppercase tracking-widest">{activeChat.role}</span>
              </div>
              
              <div className="flex-1 p-6 overflow-y-auto space-y-4 bg-gray-50">
                {messages.length === 0 && <p className="text-center text-gray-400 text-sm mt-10">Belum ada pesan.</p>}
                {messages.map((m, i) => (
                  <div key={i} className={`flex ${m.isAdmin ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[75%] p-4 rounded-2xl text-sm ${m.isAdmin ? 'bg-black text-white rounded-tr-none' : 'bg-white border shadow-sm rounded-tl-none text-black'}`}>
                      {m.content}
                    </div>
                  </div>
                ))}
              </div>

              <div className="p-4 border-t flex gap-2">
                <input 
                  value={input} 
                  onChange={e => setInput(e.target.value)} 
                  onKeyPress={e => e.key === 'Enter' && handleSend()} 
                  className="flex-1 p-4 bg-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-black/10" 
                  placeholder="Ketik pesan balasan..." 
                />
                <button onClick={handleSend} className="p-4 bg-black text-white rounded-2xl hover:scale-105 transition-transform active:scale-95">
                  <Send size={20}/>
                </button>
              </div>
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-gray-300">
              <MessageSquare size={64} className="opacity-10 mb-4"/>
              <p className="font-medium">Pilih percakapan untuk membalas</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

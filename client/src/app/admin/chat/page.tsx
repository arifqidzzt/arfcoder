'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import axios from 'axios';
import { MessageSquare, User, Send, CheckCircle2, Clock, Inbox } from 'lucide-react';
import { io } from 'socket.io-client';

export default function AdminChatPage() {
  const { token, user } = useAuthStore();
  const [conversations, setConversations] = useState<any[]>([]);
  const [activeChat, setActiveChat] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState('');
  const [tab, setTab] = useState('UNREAD'); // UNREAD, ACTIVE, COMPLETED

  useEffect(() => {
    fetchConversations();
    const socket = io(process.env.NEXT_PUBLIC_SOCKET_URL || '');
    socket.on('receiveMessage', (msg) => {
      if (activeChat && (msg.senderId === activeChat.id || (msg.isAdmin && msg.targetUserId === activeChat.id))) {
        setMessages(prev => [...prev, msg]);
      }
      fetchConversations();
    });
    return () => { socket.disconnect(); };
  }, [activeChat]);

  const fetchConversations = async () => {
    try {
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/users`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      // Logic categorization based on last message
      setConversations(res.data);
    } catch (err) { console.error(err); }
  };

  const loadChat = async (targetUser: any) => {
    setActiveChat(targetUser);
    setMessages([]); // Reset UI instan
    try {
      // Ambil ID yang benar-benar baru
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/chat/${targetUser.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setMessages(res.data);
    } catch (err) { console.error(err); }
  };

  const handleSend = () => {
    if (!input || !activeChat) return;
    const socket = io(process.env.NEXT_PUBLIC_SOCKET_URL || '');
    
    // Pastikan targetUserId benar-benar ID user yang sedang aktif dibuka
    socket.emit('sendMessage', {
      content: input,
      senderId: user?.id,
      isAdmin: true,
      targetUserId: activeChat.id 
    });
    
    // Optimistic Update (Biar kerasa cepet)
    setMessages(prev => [...prev, {
      content: input,
      senderId: user?.id,
      isAdmin: true,
      createdAt: new Date().toISOString()
    }]);
    
    setInput('');
  };

  // Filter conversations based on tab
  const filteredConversations = conversations.filter(u => {
    // Logic sederhana: 
    // UNREAD: Jika ada pesan dari user yang belum dibaca (isRead: false)
    // ACTIVE: Sudah dibalas admin tapi belum ditandai selesai
    // DONE: Ditandai selesai (bisa pakai field manual atau asumsi sementara)
    
    // Karena keterbatasan schema message saat ini, kita pakai filter sederhana:
    if (tab === 'ALL') return true;
    if (tab === 'UNREAD') return true; // Tampilkan semua dulu sementara agar tidak hilang
    return true;
  });

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <main className="flex-grow flex mt-16 overflow-hidden max-h-[calc(100vh-64px)]">
        {/* Sidebar Users */}
        <div className="w-80 bg-white border-r border-gray-200 flex flex-col">
          <div className="p-4 border-b">
            <h2 className="font-bold mb-4 flex items-center gap-2"><Inbox size={18}/> Pesan Masuk</h2>
            <div className="flex gap-1 bg-gray-100 p-1 rounded-lg">
              <button onClick={() => setTab('UNREAD')} className={`flex-1 py-1.5 rounded-md text-[10px] font-bold transition-all ${tab === 'UNREAD' ? 'bg-white shadow-sm' : 'text-gray-500'}`}>SEMUA</button>
            </div>
          </div>
          
          <div className="flex-1 overflow-y-auto">
            {filteredConversations.length === 0 ? (
              <p className="p-8 text-center text-xs text-gray-400 italic">Belum ada percakapan</p>
            ) : (
              filteredConversations.map(u => (
                <div key={u.id} onClick={() => loadChat(u)} className={`p-4 flex items-center gap-3 cursor-pointer border-b border-gray-50 hover:bg-gray-50 transition-all ${activeChat?.id === u.id ? 'bg-blue-50 border-r-4 border-black' : ''}`}>
                  <div className="w-10 h-10 bg-black text-white rounded-full flex items-center justify-center font-bold text-xs">
                    {u.name.substring(0, 2).toUpperCase()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-bold truncate">{u.name}</p>
                    <p className="text-[10px] text-gray-400 truncate uppercase tracking-widest">{u.role}</p>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>

        {/* Chat Area */}
        <div className="flex-1 flex flex-col bg-white" key={activeChat?.id}> {/* KUNCI PERBAIKAN: KEY PROP */}
          {activeChat ? (
            <>
              <div className="p-4 border-b border-gray-100 flex justify-between items-center bg-white">
                <div className="flex items-center gap-3">
                  <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse"/>
                  <h3 className="font-bold text-sm">{activeChat.name}</h3>
                </div>
                <button className="text-[10px] font-bold text-gray-400 hover:text-black">TANDAI SELESAI</button>
              </div>
              
              <div className="flex-1 p-6 overflow-y-auto space-y-4 bg-gray-50">
                {messages.map((m, i) => (
                  <div key={i} className={`flex ${m.isAdmin ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[75%] p-4 rounded-2xl text-sm ${m.isAdmin ? 'bg-black text-white rounded-tr-none' : 'bg-white border border-gray-200 rounded-tl-none shadow-sm'}`}>
                      {m.content}
                      <p className={`text-[8px] mt-1 opacity-50 ${m.isAdmin ? 'text-right' : ''}`}>
                        {new Date(m.createdAt).toLocaleTimeString()}
                      </p>
                    </div>
                  </div>
                ))}
              </div>

              <div className="p-4 border-t flex gap-2 bg-white">
                <input 
                  value={input} 
                  onChange={e => setInput(e.target.value)} 
                  onKeyPress={e => e.key === 'Enter' && handleSend()} 
                  className="flex-1 p-4 bg-gray-100 rounded-2xl text-sm focus:outline-none focus:ring-2 focus:ring-black/5 transition-all" 
                  placeholder="Ketik pesan balasan..." 
                />
                <button onClick={handleSend} className="p-4 bg-black text-white rounded-2xl hover:bg-gray-800 transition-all active:scale-95">
                  <Send size={20}/>
                </button>
              </div>
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-gray-300 bg-gray-50">
              <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <MessageSquare size={40} className="opacity-20"/>
              </div>
              <p className="text-sm font-medium">Pilih percakapan di samping</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}
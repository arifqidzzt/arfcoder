'use client';

import { useEffect, useState } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import axios from 'axios';
import { MessageSquare, User, Send, CheckCircle2, Clock } from 'lucide-react';
import { io } from 'socket.io-client';

export default function AdminChatPage() {
  const { token, user } = useAuthStore();
  const [conversations, setConversations] = useState<any[]>([]);
  const [activeChat, setActiveChat] = useState<any>(null);
  const [messages, setMessages] = useState<any[]>([]);
  const [input, setInput] = useState('');
  const [tab, setTab] = useState('UNREAD'); // UNREAD, ALL, COMPLETED

  useEffect(() => {
    fetchConversations();
    const socket = io(process.env.NEXT_PUBLIC_SOCKET_URL || '');
    socket.on('receiveMessage', (msg) => {
      if (activeChat && msg.senderId === activeChat.id) {
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
      // Filter users who have messages
      setConversations(res.data);
    } catch (err) { console.error(err); }
  };

  const loadChat = async (targetUser: any) => {
    setActiveChat(targetUser);
    try {
      const res = await axios.get(`${process.env.NEXT_PUBLIC_API_URL}/admin/chat/${targetUser.id}`, {
        headers: { Authorization: `Bearer ${token}` }
      });
      setMessages(res.data);
    } catch (err) { console.error(err); }
  };

  const handleSend = () => {
    if (!input || !activeChat) return;
    const socket = io(process.env.NEXT_PUBLIC_SOCKET_URL || '');
    socket.emit('sendMessage', {
      content: input,
      senderId: user?.id,
      isAdmin: true,
      targetUserId: activeChat.id
    });
    setInput('');
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <main className="flex-grow flex mt-16 overflow-hidden">
        {/* Sidebar Users */}
        <div className="w-80 bg-white border-r border-gray-200 flex flex-col">
          <div className="p-4 border-b flex gap-2 overflow-x-auto">
            <button onClick={() => setTab('UNREAD')} className={`px-3 py-1 rounded-full text-xs font-bold ${tab === 'UNREAD' ? 'bg-black text-white' : 'bg-gray-100'}`}>Belum Proses</button>
            <button onClick={() => setTab('ALL')} className={`px-3 py-1 rounded-full text-xs font-bold ${tab === 'ALL' ? 'bg-black text-white' : 'bg-gray-100'}`}>Semua</button>
          </div>
          <div className="flex-1 overflow-y-auto">
            {conversations.map(u => (
              <div key={u.id} onClick={() => loadChat(u)} className={`p-4 flex items-center gap-3 cursor-pointer hover:bg-gray-50 ${activeChat?.id === u.id ? 'bg-blue-50 border-r-4 border-black' : ''}`}>
                <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center text-gray-500"><User size={20}/></div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-bold truncate">{u.name}</p>
                  <p className="text-xs text-gray-400 truncate">{u.email}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Chat Area */}
        <div className="flex-1 flex flex-col bg-white">
          {activeChat ? (
            <>
              <div className="p-4 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                <h3 className="font-bold">{activeChat.name}</h3>
                <span className="text-xs text-gray-400">Online</span>
              </div>
              <div className="flex-1 p-6 overflow-y-auto space-y-4 bg-gray-50">
                {messages.map((m, i) => (
                  <div key={i} className={`flex ${m.isAdmin ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[70%] p-3 rounded-2xl text-sm ${m.isAdmin ? 'bg-black text-white rounded-tr-none' : 'bg-white border rounded-tl-none shadow-sm'}`}>
                      {m.content}
                    </div>
                  </div>
                ))}
              </div>
              <div className="p-4 border-t flex gap-2">
                <input value={input} onChange={e => setInput(e.target.value)} onKeyPress={e => e.key === 'Enter' && handleSend()} className="flex-1 p-3 bg-gray-100 rounded-xl focus:outline-none" placeholder="Tulis balasan..." />
                <button onClick={handleSend} className="p-3 bg-black text-white rounded-xl"><Send size={20}/></button>
              </div>
            </>
          ) : (
            <div className="flex-1 flex flex-col items-center justify-center text-gray-400">
              <MessageSquare size={64} className="mb-4 opacity-20"/>
              <p>Pilih pesan untuk mulai membalas</p>
            </div>
          )}
        </div>
      </main>
    </div>
  );
}

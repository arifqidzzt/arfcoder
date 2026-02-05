'use client';

import { useState, useEffect, useRef } from 'react';
import { useAuthStore } from '@/store/useAuthStore';
import Navbar from '@/components/Navbar';
import api from '@/lib/api';
import { Send, User } from 'lucide-react';

interface Message {
  id?: string;
  content: string;
  senderId: string;
  isAdmin: boolean;
  createdAt?: string;
}

interface ChatUser {
  id: string;
  name: string;
  email: string;
  lastMessage?: string;
}

export default function AdminChatPage() {
  const { token, user } = useAuthStore();
  const [selectedUser, setSelectedUser] = useState<string | null>(null);
  const [users, setUsers] = useState<ChatUser[]>([]);
  const [messages, setMessages] = useState<Message[]>([]);
  const [input, setInput] = useState('');
  const scrollRef = useRef<HTMLDivElement>(null);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  // Fetch Users List (You might need an endpoint for "Users who chatted" or just all users)
  // For now, let's assume we can fetch all users or reuse /admin/users
  // Ideally, we need a "getChatUsers" endpoint.
  // I'll stick to fetching all users for now or maybe just hardcode if the UI expects a list.
  // Actually, let's fetch /admin/users.
  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      const res = await api.get('/admin/users');
      setUsers(res.data);
    } catch (err) { console.error(err); }
  };

  const fetchMessages = async () => {
    if (!selectedUser) return;
    try {
      const res = await api.get(`/admin/chat/${selectedUser}`);
      setMessages(res.data);
    } catch (err) { console.error(err); }
  };

  useEffect(() => {
    if (selectedUser) {
      fetchMessages();
      intervalRef.current = setInterval(fetchMessages, 5000);
    } else {
      setMessages([]);
      if (intervalRef.current) clearInterval(intervalRef.current);
    }
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [selectedUser]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input || !selectedUser || !user) return;

    try {
      const payload = {
        content: input,
        senderId: user.id,
        isAdmin: true,
        targetUserId: selectedUser
      };
      
      // Optimistic
      setMessages(prev => [...prev, { ...payload, createdAt: new Date().toISOString() }]);
      setInput('');

      await api.post('/user/chat/send', payload); // Reusing the generic send endpoint
      fetchMessages();
    } catch (err) { console.error(err); }
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col">
      <Navbar />
      <div className="flex-1 max-w-7xl mx-auto w-full p-4 grid grid-cols-1 md:grid-cols-4 gap-6 pt-24">
        
        {/* Users List */}
        <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden flex flex-col h-[600px]">
          <div className="p-4 border-b border-gray-100 font-bold">Daftar Pengguna</div>
          <div className="flex-1 overflow-y-auto">
            {users.map(u => (
              <div 
                key={u.id} 
                onClick={() => setSelectedUser(u.id)}
                className={`p-4 border-b border-gray-50 cursor-pointer hover:bg-gray-50 ${selectedUser === u.id ? 'bg-blue-50' : ''}`}
              >
                <div className="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center">
                  <User size={20} className="text-gray-500" />
                </div>
                <div>
                  <div className="font-bold text-sm">{u.name}</div>
                  <div className="text-xs text-gray-400">{u.email}</div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Chat Area */}
        <div className="md:col-span-3 bg-white rounded-2xl shadow-sm border border-gray-100 flex flex-col h-[600px]">
          {selectedUser ? (
            <>
              <div className="p-4 border-b border-gray-100 font-bold flex items-center gap-2">
                <span className="w-2 h-2 bg-green-500 rounded-full"></span>
                Chat dengan User
              </div>
              
              <div ref={scrollRef} className="flex-1 p-4 overflow-y-auto space-y-4 bg-gray-50/50">
                {messages.length === 0 && <p className="text-center text-gray-400 mt-20">Belum ada pesan</p>}
                {messages.map((msg, i) => (
                  <div key={i} className={`flex ${msg.isAdmin ? 'justify-end' : 'justify-start'}`}>
                     <div className={`max-w-[70%] p-3 rounded-xl text-sm ${msg.isAdmin ? 'bg-black text-white' : 'bg-white border border-gray-200'}`}>
                       {msg.content}
                     </div>
                  </div>
                ))}
              </div>

              <form onSubmit={handleSend} className="p-4 border-t border-gray-100 flex gap-2">
                <input 
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  className="flex-1 bg-gray-50 border border-gray-200 rounded-xl px-4 py-2 focus:outline-none focus:ring-2 focus:ring-black/5"
                  placeholder="Ketik balasan..."
                />
                <button type="submit" className="bg-black text-white p-2 rounded-xl hover:bg-gray-800">
                  <Send size={20} />
                </button>
              </form>
            </>
          ) : (
             <div className="flex-1 flex items-center justify-center text-gray-400">
               Pilih pengguna untuk memulai chat
             </div>
          )}
        </div>

      </div>
    </div>
  );
}
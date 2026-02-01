'use client';

import { useState, useEffect, useRef } from 'react';
import { MessageCircle, X, Send } from 'lucide-react';
import { useAuthStore } from '@/store/useAuthStore';
import api from '@/lib/api';

interface Message {
  id?: string;
  content: string;
  senderId: string;
  isAdmin: boolean;
  sender?: { name: string };
  createdAt?: string;
}

export default function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const { user } = useAuthStore();
  const scrollRef = useRef<HTMLDivElement>(null);
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const fetchMessages = async () => {
    if (!user) return;
    try {
      // User fetches their own chat
      const res = await api.get('/user/chat/history/me');
      setMessages(res.data);
    } catch (error) { console.error('Chat error', error); }
  };

  useEffect(() => {
    if (isOpen && user) {
      fetchMessages();
      intervalRef.current = setInterval(fetchMessages, 5000);
    } else {
      if (intervalRef.current) clearInterval(intervalRef.current);
    }
    return () => { if (intervalRef.current) clearInterval(intervalRef.current); };
  }, [isOpen, user]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message || !user) return;

    try {
      const payload = {
        content: message,
        senderId: user.id,
        isAdmin: false, 
        targetUserId: '',
      };
      
      // Optimistic update
      setMessages(prev => [...prev, { ...payload, createdAt: new Date().toISOString() }]);
      setMessage('');

      await api.post('/user/chat/send', payload);
      fetchMessages(); // Sync
    } catch (error) {
      console.error('Send error', error);
    }
  };

  if (!user) return null; // Hide if not logged in

  return (
    <div className="fixed bottom-8 right-8 z-50">
      {!isOpen ? (
        <button 
          onClick={() => setIsOpen(true)}
          className="bg-black text-white p-4 rounded-full shadow-2xl hover:scale-110 transition-transform"
        >
          <MessageCircle size={24} />
        </button>
      ) : (
        <div className="bg-white w-80 h-[450px] shadow-2xl border border-gray-100 flex flex-col rounded-2xl overflow-hidden">
          <div className="p-4 bg-black text-white flex justify-between items-center">
            <span className="font-bold text-sm tracking-tighter">ARF CHAT</span>
            <button onClick={() => setIsOpen(false)}><X size={18} /></button>
          </div>
          
          <div ref={scrollRef} className="flex-grow p-4 overflow-y-auto space-y-4 text-sm bg-gray-50">
            {messages.length === 0 && (
              <p className="text-center text-gray-400 mt-10">Halo! Ada yang bisa kami bantu?</p>
            )}
            {messages.map((msg, i) => (
              <div key={i} className={`flex ${msg.senderId === user?.id ? 'justify-end' : 'justify-start'}`}>
                <div className={`max-w-[80%] p-3 rounded-xl ${msg.senderId === user?.id ? 'bg-black text-white' : 'bg-white border border-gray-200'}`}>
                  {msg.content}
                </div>
              </div>
            ))}
          </div>

          <form onSubmit={handleSendMessage} className="p-4 border-t border-gray-100 flex space-x-2 bg-white">
            <input 
              type="text" 
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Ketik pesan..." 
              className="flex-grow text-sm focus:outline-none"
            />
            <button className="text-black hover:bg-gray-100 p-2 rounded-full transition-colors"><Send size={18} /></button>
          </form>
        </div>
      )}
    </div>
  );
}

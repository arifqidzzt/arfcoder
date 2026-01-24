'use client';

import { useState, useEffect, useRef } from 'react';
import { MessageCircle, X, Send } from 'lucide-react';
import { io, Socket } from 'socket.io-client';
import { useAuthStore } from '@/store/useAuthStore';

interface Message {
  id?: string;
  content: string;
  senderId: string;
  isAdmin: boolean;
  sender?: { name: string };
}

export default function ChatWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const { user } = useAuthStore();
  const socketRef = useRef<Socket | null>(null);
  const scrollRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen && !socketRef.current) {
      socketRef.current = io(process.env.NEXT_PUBLIC_SOCKET_URL || 'http://localhost:5000');
      
      socketRef.current.on('receiveMessage', (data: Message) => {
        setMessages((prev) => [...prev, data]);
      });
    }

    return () => {
      if (socketRef.current) {
        socketRef.current.disconnect();
        socketRef.current = null;
      }
    };
  }, [isOpen]);

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSendMessage = (e: React.FormEvent) => {
    e.preventDefault();
    if (!message || !user || !socketRef.current) return;

    const msgData = {
      content: message,
      senderId: user.id,
      isAdmin: user.role === 'ADMIN' || user.role === 'SUPER_ADMIN',
    };

    socketRef.current.emit('sendMessage', msgData);
    setMessage('');
  };

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
        <div className="bg-white w-80 h-[450px] shadow-2xl border border-gray-100 flex flex-col">
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
                <div className={`max-w-[80%] p-3 ${msg.senderId === user?.id ? 'bg-black text-white' : 'bg-white border border-gray-200'}`}>
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
            <button className="text-black"><Send size={18} /></button>
          </form>
        </div>
      )}
    </div>
  );
}

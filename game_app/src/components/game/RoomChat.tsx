"use client";

import { useState, useEffect, useRef } from "react";
import { ref, onValue, push, serverTimestamp, query, limitToLast } from "firebase/database";
import { rtdb } from "@/firebase/client";
import { User } from "firebase/auth";

interface RoomChatProps {
  roomId: string;
  user: User | null;
  onNewMessage?: () => void;
}

interface ChatMessage {
  id: string;
  text: string;
  uid: string;
  timestamp: number;
}

export function RoomChat({ roomId, user, onNewMessage }: RoomChatProps) {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputText, setInputText] = useState("");
  const [isSending, setIsSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const lastSentTime = useRef<number>(0);

  useEffect(() => {
    if (!roomId) return;
    const chatRef = query(ref(rtdb, `rooms/${roomId}/chat`), limitToLast(50));
    const unsubscribe = onValue(chatRef, (snapshot) => {
      if (snapshot.exists()) {
        const data = snapshot.val();
        const msgList = Object.keys(data).map((key) => ({
          id: key,
          ...data[key],
        })).sort((a, b) => (a.timestamp || 0) - (b.timestamp || 0));
        
        setMessages(prev => {
          if (prev.length > 0) {
            const prevLastTime = prev[prev.length - 1].timestamp;
            const newLastMsg = msgList[msgList.length - 1];
            if (newLastMsg && newLastMsg.timestamp > prevLastTime && newLastMsg.uid !== user?.uid && onNewMessage) {
              onNewMessage();
            }
          }
          return msgList;
        });
      } else {
        setMessages([]);
      }
    });

    return () => unsubscribe();
  }, [roomId, user, onNewMessage]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim() || !user || !roomId || isSending) return;
    if (inputText.length > 200) return;

    // Rate limiting: 1 message per second
    const now = Date.now();
    if (now - lastSentTime.current < 1000) {
      return;
    }

    setIsSending(true);
    const chatRef = ref(rtdb, `rooms/${roomId}/chat`);
    try {
      await push(chatRef, {
        text: inputText.trim(),
        uid: user.uid,
        timestamp: serverTimestamp(),
      });
      setInputText("");
      lastSentTime.current = Date.now();
    } catch (error) {
      console.error("Failed to send message", error);
    } finally {
      setIsSending(false);
    }
  };

  return (
    <div className="flex flex-col h-64 sm:h-80 w-full max-w-md mx-auto bg-card rounded-2xl border border-white/10 shadow-lg overflow-hidden">
      <div className="bg-secondary/50 px-4 py-2 border-b border-white/5 text-sm font-medium">
        شات الغرفة
      </div>
      
      <div className="flex-1 overflow-y-auto p-4 flex flex-col gap-3">
        {messages.map((msg) => {
          const isMe = msg.uid === user?.uid;
          return (
            <div
              key={msg.id}
              className={`max-w-[80%] px-3 py-2 rounded-2xl text-sm ${
                isMe
                  ? "bg-primary text-primary-foreground self-end rounded-br-sm"
                  : "bg-white/10 text-foreground self-start rounded-bl-sm"
              }`}
            >
              {msg.text}
            </div>
          );
        })}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={sendMessage} className="p-3 bg-secondary/20 border-t border-white/5 flex gap-2">
        <input
          type="text"
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="اكتب رسالتك..."
          maxLength={200}
          className="flex-1 bg-background/50 border border-white/10 rounded-full px-4 py-2 text-sm focus:outline-none focus:border-primary/50 transition-colors"
        />
        <button
          type="submit"
          disabled={!inputText.trim() || isSending}
          className="bg-primary text-primary-foreground px-4 py-2 rounded-full text-sm font-medium hover:bg-primary/90 transition-colors disabled:opacity-50"
        >
          {isSending ? "..." : "إرسال"}
        </button>
      </form>
    </div>
  );
}

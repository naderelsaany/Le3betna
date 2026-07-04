"use client";

import { useState, useEffect, useRef } from "react";
import { collection, query, orderBy, limit, onSnapshot, addDoc, serverTimestamp } from "firebase/firestore";
import { firestore } from "@/firebase/client";
import { User } from "firebase/auth";

export interface FriendData {
  id: string;
  displayName: string;
  photoURL: string;
}

interface PrivateChatProps {
  user: User | null;
  friend: FriendData | null;
}

interface ChatMessage {
  id: string;
  text: string;
  uid: string;
  createdAt: any;
}

export function PrivateChat({ user, friend }: PrivateChatProps) {
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [inputText, setInputText] = useState("");
  const [isSending, setIsSending] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const lastSentTime = useRef<number>(0);

  useEffect(() => {
    if (!user || !friend) return;

    // Generate a unique ID for this pair of users
    const chatId = [user.uid, friend.id].sort().join("_");
    
    const q = query(
      collection(firestore, `private_chats/${chatId}/messages`),
      orderBy("createdAt", "desc"),
      limit(50)
    );
    
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const msgList: ChatMessage[] = [];
      snapshot.forEach((doc) => {
        msgList.push({ id: doc.id, ...doc.data() } as ChatMessage);
      });
      setMessages(msgList.reverse());
    });

    return () => unsubscribe();
  }, [user, friend]);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const sendMessage = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!inputText.trim() || !user || !friend || isSending) return;
    if (inputText.length > 200) return;

    // Rate limiting: 1 message per second
    const now = Date.now();
    if (now - lastSentTime.current < 1000) {
      return;
    }

    setIsSending(true);
    const chatId = [user.uid, friend.id].sort().join("_");
    
    try {
      await addDoc(collection(firestore, `private_chats/${chatId}/messages`), {
        text: inputText.trim(),
        uid: user.uid,
        createdAt: serverTimestamp(),
      });
      setInputText("");
      lastSentTime.current = Date.now();
    } catch (err) {
      console.error("Error sending private message", err);
    } finally {
      setIsSending(false);
    }
  };

  if (!friend) {
    return (
      <div className="flex flex-col h-full w-full bg-card/50 rounded-2xl items-center justify-center text-muted-foreground">
        <span className="text-4xl mb-4">💬</span>
        <p>اختر صديقاً من القائمة لبدء المحادثة الخاصة.</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col h-full w-full bg-card/50 rounded-2xl overflow-hidden">
      {/* Header */}
      <div className="bg-secondary/50 px-4 py-3 border-b border-white/5 flex items-center gap-3">
        {friend.photoURL ? (
           <img src={friend.photoURL} alt={friend.displayName} className="w-8 h-8 rounded-full border border-white/10" />
        ) : (
           <div className="w-8 h-8 rounded-full bg-white/10" />
        )}
        <span className="font-bold text-sm">{friend.displayName}</span>
      </div>

      {/* Messages */}
      <div className="flex-1 overflow-y-auto p-4 flex flex-col gap-3">
        {messages.length === 0 && (
          <div className="text-center text-muted-foreground text-sm mt-4">
            لا توجد رسائل بينك وبين {friend.displayName} بعد. ابدأ المحادثة!
          </div>
        )}
        {messages.map((msg) => {
          const isMe = msg.uid === user?.uid;
          return (
            <div
              key={msg.id}
              className={`max-w-[85%] px-4 py-2 rounded-2xl text-sm ${
                isMe
                  ? "bg-primary text-primary-foreground self-end rounded-br-sm shadow-[0_4px_10px_rgba(94,106,210,0.3)]"
                  : "bg-white/10 text-foreground self-start rounded-bl-sm"
              }`}
            >
              {msg.text}
            </div>
          );
        })}
        <div ref={messagesEndRef} />
      </div>

      {/* Input Form */}
      <form onSubmit={sendMessage} className="p-3 bg-secondary/20 border-t border-white/5 flex gap-2">
        <input
          type="text"
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder={`اكتب رسالة إلى ${friend.displayName}...`}
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

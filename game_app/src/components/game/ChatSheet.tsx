"use client";

import { motion, AnimatePresence } from "framer-motion";
import { RoomChat } from "./RoomChat";
import { User } from "firebase/auth";

interface ChatSheetProps {
  isOpen: boolean;
  onClose: () => void;
  roomId: string;
  user: User | null;
}

export function ChatSheet({ isOpen, onClose, roomId, user }: ChatSheetProps) {
  return (
    <AnimatePresence>
      {isOpen && (
        <>
          {/* Backdrop */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            className="fixed inset-0 z-40 bg-black/60 backdrop-blur-sm"
            onClick={onClose}
          />
          
          {/* Sheet */}
          <motion.div
            initial={{ y: "100%" }}
            animate={{ y: 0 }}
            exit={{ y: "100%" }}
            transition={{ type: "spring", damping: 30, stiffness: 300 }}
            className="fixed bottom-0 left-0 right-0 z-50 h-[70dvh] sm:h-[60dvh] bg-background border-t border-white/10 rounded-t-3xl shadow-[0_-10px_40px_rgba(0,0,0,0.5)] safe-bottom flex flex-col overflow-hidden"
          >
            {/* Drag Handle */}
            <div 
              className="flex justify-center pt-3 pb-2 cursor-pointer touch-manipulation"
              onClick={onClose}
            >
              <div className="w-12 h-1.5 rounded-full bg-white/20 hover:bg-white/30 transition-colors" />
            </div>
            
            {/* Title / Close */}
            <div className="px-4 pb-2 flex justify-between items-center border-b border-white/5">
              <span className="font-bold text-lg text-primary">شات الغرفة</span>
              <button 
                onClick={onClose}
                className="text-white/50 hover:text-white p-1 rounded-full bg-white/5 touch-manipulation"
              >
                <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M18 6 6 18"/><path d="m6 6 12 12"/>
                </svg>
              </button>
            </div>

            {/* Chat Content */}
            <div className="flex-1 overflow-hidden [&>div]:h-full [&>div]:max-w-full [&>div]:rounded-none">
              <RoomChat roomId={roomId} user={user} />
            </div>
          </motion.div>
        </>
      )}
    </AnimatePresence>
  );
}

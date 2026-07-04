"use client";

import { Suspense } from "react";

import { useState, useEffect, useCallback, useRef } from "react";
import { useAuth } from "@/hooks/useAuth";
import { useGameRoom } from "@/hooks/useGameRoom";
import { Connect4Game } from "@/components/game/Connect4Game";
import { LudoGame } from "@/components/game/LudoGame";
import { DominoGame } from "@/components/game/DominoGame";
import { RoomChat } from "@/components/game/RoomChat";
import { ChatSheet } from "@/components/game/ChatSheet";
import { useSearchParams, useRouter } from "next/navigation";
import { soundEngine } from "@/lib/SoundEngine";

function PlayContent() {
  const { user, loading: authLoading } = useAuth();
  const searchParams = useSearchParams();
  const router = useRouter();
  
  const initialRoom = searchParams.get("room");
  const [roomCodeInput, setRoomCodeInput] = useState("");
  const [activeRoomId, setActiveRoomId] = useState<string | null>(initialRoom);
  const [isChatOpen, setIsChatOpen] = useState(false);
  const [hasUnread, setHasUnread] = useState(false);
  const [dominoPlayers, setDominoPlayers] = useState<2 | 4>(2);
  const [dominoTarget, setDominoTarget] = useState<number>(101);
  const isChatOpenRef = useRef(isChatOpen);

  useEffect(() => {
    isChatOpenRef.current = isChatOpen;
  }, [isChatOpen]);

  const { room, loading: roomLoading, error, createRoom, joinRoom, leaveRoom } = useGameRoom(
    user,
    activeRoomId
  );

  const handleNewMessage = useCallback(() => {
    // Desktop RoomChat is always mounted. If mobile chat is closed, show badge.
    if (typeof window !== "undefined" && window.innerWidth < 1024 && !isChatOpenRef.current) {
      setHasUnread(true);
      soundEngine.playPop();
    }
  }, []);

  // Auto-join if room param is present
  useEffect(() => {
    if (initialRoom && user && !room && !roomLoading) {
      joinRoom(initialRoom);
    }
  }, [initialRoom, user]);

  const handleCreateConnect4 = async () => {
    const initialBoard = Array(6).fill(null).map(() => Array(7).fill(0));
    const initialGameState = {
      board: initialBoard,
      turn: 1,
      winner: null,
      version: 1
    };
    const code = await createRoom("connect4", 2, initialGameState);
    if (code) {
      setActiveRoomId(code);
      router.replace(`/play?room=${code}`, { scroll: false });
    }
  };

  const handleCreateLudo = async () => {
    const initialGameState = {
      turnOrder: [],
      currentTurnIndex: 0,
      dice: { value: null, rolledBy: null, rolledAt: null },
      pieces: {},
      winner: null,
      consecutiveSixes: 0,
      version: 1
    };
    // For testing, we set maxPlayers to 2 so it starts easily.
    const code = await createRoom("ludo", 2, initialGameState);
    if (code) {
      setActiveRoomId(code);
      router.replace(`/play?room=${code}`, { scroll: false });
    }
  };

  const handleCreateDomino = async () => {
    // Initial state will be initialized fully when players join, 
    // but we can set the structural requirements here.
    const initialGameState = {
      turnOrder: [],
      currentTurnIndex: 0,
      hands: {},
      chain: { pieces: [], leftEnd: null, rightEnd: null },
      consecutivePasses: 0,
      scores: {},
      targetScore: dominoTarget,
      roundWinner: null,
      gameWinner: null,
      version: 1,
      needsInitialization: false,
    };
    
    const code = await createRoom("domino", dominoPlayers, initialGameState, dominoTarget);
    if (code) {
      setActiveRoomId(code);
      router.replace(`/play?room=${code}`, { scroll: false });
    }
  };

  const handleJoinRoom = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!roomCodeInput.trim()) return;
    const success = await joinRoom(roomCodeInput.trim());
    if (success) {
      setActiveRoomId(roomCodeInput.trim());
      router.replace(`/play?room=${roomCodeInput.trim()}`, { scroll: false });
    }
  };

  const handleLeaveRoom = async () => {
    if (leaveRoom) {
      await leaveRoom();
    }
    setActiveRoomId(null);
    router.replace('/play', { scroll: false });
  };

  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-white/5 animate-pulse" />
          <div className="w-40 h-5 bg-white/5 rounded-full animate-pulse" />
          <div className="w-24 h-3 bg-white/5 rounded-full animate-pulse" />
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col items-center py-6 px-4">
      <div className="w-full max-w-4xl flex justify-between items-center mb-8">
        <button 
          onClick={() => router.push("/")}
          className="bg-white/5 hover:bg-white/10 text-white px-4 py-2 rounded-full border border-white/10 text-sm font-medium transition-colors flex items-center gap-2"
        >
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
             <path d="m15 18-6-6 6-6"/>
          </svg>
          العودة للرئيسية
        </button>
        <h1 className="text-3xl sm:text-4xl font-bold text-primary tracking-tight text-center">
          لعبتنا <span className="text-white/20">|</span> {activeRoomId && room?.gameType === "ludo" ? "لودو (Ludo)" : activeRoomId && room?.gameType === "domino" ? "دومينو" : "4 في صف"}
        </h1>
        <div className="w-24 sm:w-32 hidden sm:block"></div>
      </div>

      {error && (
        <div className="bg-destructive/20 text-destructive border border-destructive/50 px-4 py-3 rounded-xl mb-6 w-full max-w-md text-center">
          {error}
        </div>
      )}

      {/* Lobby State */}
      {!activeRoomId && (
        <div className="bg-card border border-white/5 shadow-2xl rounded-3xl p-8 w-full max-w-md flex flex-col gap-6 items-center">
          <div className="flex flex-col gap-3 w-full">
            {(!searchParams.get("game") || searchParams.get("game") === "connect4") && (
              <button
                onClick={handleCreateConnect4}
                disabled={roomLoading}
                className="w-full bg-blue-600 text-white font-bold text-lg py-4 rounded-xl shadow-[0_0_20px_rgba(37,99,235,0.4)] hover:shadow-[0_0_30px_rgba(37,99,235,0.6)] hover:bg-blue-500 transition-all disabled:opacity-50"
              >
                {roomLoading ? "جاري الإنشاء..." : "إنشاء غرفة (Connect 4)"}
              </button>
            )}
            
            {(!searchParams.get("game") || searchParams.get("game") === "ludo") && (
              <button
                onClick={handleCreateLudo}
                disabled={roomLoading}
                className="w-full bg-red-600 text-white font-bold text-lg py-4 rounded-xl shadow-[0_0_20px_rgba(220,38,38,0.4)] hover:shadow-[0_0_30px_rgba(220,38,38,0.6)] hover:bg-red-500 transition-all disabled:opacity-50"
              >
                {roomLoading ? "جاري الإنشاء..." : "إنشاء غرفة (Ludo) 🎲"}
              </button>
            )}

            {(!searchParams.get("game") || searchParams.get("game") === "domino") && (
              <div className="w-full bg-secondary/30 rounded-xl p-4 border border-white/5 flex flex-col gap-4">
                <div className="flex justify-between items-center text-sm">
                  <span>عدد اللاعبين:</span>
                  <div className="flex gap-2">
                    <button onClick={() => setDominoPlayers(2)} className={`px-3 py-1 rounded-md transition-colors ${dominoPlayers === 2 ? 'bg-primary text-white' : 'bg-white/10 hover:bg-white/20'}`}>2</button>
                    <button onClick={() => setDominoPlayers(4)} className={`px-3 py-1 rounded-md transition-colors ${dominoPlayers === 4 ? 'bg-primary text-white' : 'bg-white/10 hover:bg-white/20'}`}>4 (شراكة)</button>
                  </div>
                </div>
                <div className="flex justify-between items-center text-sm">
                  <span>الهدف:</span>
                  <div className="flex gap-2">
                    <button onClick={() => setDominoTarget(101)} className={`px-3 py-1 rounded-md transition-colors ${dominoTarget === 101 ? 'bg-primary text-white' : 'bg-white/10 hover:bg-white/20'}`}>101</button>
                    <button onClick={() => setDominoTarget(151)} className={`px-3 py-1 rounded-md transition-colors ${dominoTarget === 151 ? 'bg-primary text-white' : 'bg-white/10 hover:bg-white/20'}`}>151</button>
                  </div>
                </div>
                <button
                  onClick={handleCreateDomino}
                  disabled={roomLoading}
                  className="w-full bg-green-600 text-white font-bold text-lg py-3 rounded-xl shadow-[0_0_20px_rgba(22,163,74,0.4)] hover:shadow-[0_0_30px_rgba(22,163,74,0.6)] hover:bg-green-500 transition-all disabled:opacity-50 mt-2"
                >
                  {roomLoading ? "جاري الإنشاء..." : "إنشاء غرفة (دومينو)"}
                </button>
              </div>
            )}
          </div>

          <div className="flex items-center w-full gap-4">
            <div className="h-[1px] bg-white/10 flex-1" />
            <span className="text-muted-foreground text-sm font-medium">أو</span>
            <div className="h-[1px] bg-white/10 flex-1" />
          </div>

          <form onSubmit={handleJoinRoom} className="w-full flex flex-col gap-3">
            <input
              type="text"
              placeholder="أدخل كود الغرفة (4 أرقام)"
              value={roomCodeInput}
              onChange={(e) => setRoomCodeInput(e.target.value)}
              className="w-full bg-background/50 border border-white/10 rounded-xl px-4 py-3 text-center text-lg tracking-widest focus:outline-none focus:border-primary/50 transition-colors"
              maxLength={4}
            />
            <button
              type="submit"
              disabled={roomLoading || roomCodeInput.length !== 4}
              className="w-full bg-white/10 text-white font-bold text-lg py-3 rounded-xl hover:bg-white/20 transition-all disabled:opacity-50"
            >
              انضمام للغرفة
            </button>
          </form>
        </div>
      )}

      {/* Playing State */}
      {activeRoomId && room && (
        <div className="w-full max-w-4xl flex flex-col lg:flex-row gap-8 items-start justify-center">
          <div className="flex-1 w-full flex flex-col gap-4 items-center">
            <div className="flex items-center gap-4 bg-secondary/30 px-6 py-2 rounded-full border border-white/5 backdrop-blur-sm">
              <div>
                كود الغرفة: <span className="font-bold text-primary tracking-widest text-lg ml-2">{activeRoomId}</span>
              </div>
              <div className="h-6 w-px bg-white/20"></div>
              <button onClick={handleLeaveRoom} className="text-sm text-red-400 hover:text-red-300 transition-colors font-medium">
                خروج من الغرفة
              </button>
            </div>
            
            {room.gameType === "connect4" && (
              <Connect4Game
                roomId={activeRoomId}
                room={room}
                user={user!}
              />
            )}
            {room.gameType === "ludo" && (
              <LudoGame
                roomId={activeRoomId}
                room={room}
                user={user!}
              />
            )}
            {room.gameType === "domino" && (
              <DominoGame
                roomId={activeRoomId}
                room={room}
                user={user!}
              />
            )}
          </div>
          
          <div className="hidden lg:block w-full lg:w-80 mt-14">
            <RoomChat 
              roomId={activeRoomId} 
              user={user} 
              onNewMessage={handleNewMessage} 
            />
          </div>

          {/* Mobile Chat FAB */}
          <button
            onClick={() => {
              setIsChatOpen(true);
              setHasUnread(false);
            }}
            className="lg:hidden fixed bottom-6 left-6 w-14 h-14 bg-primary text-primary-foreground rounded-full shadow-[0_0_20px_rgba(108,92,231,0.5)] flex items-center justify-center hover:bg-primary/90 transition-colors z-30 touch-manipulation"
          >
            {hasUnread && (
              <span className="absolute top-0 right-0 w-3.5 h-3.5 bg-red-500 border-2 border-background rounded-full animate-pulse" />
            )}
            <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/>
            </svg>
          </button>

          {/* Mobile Chat Sheet */}
          <ChatSheet 
            isOpen={isChatOpen} 
            onClose={() => setIsChatOpen(false)} 
            roomId={activeRoomId} 
            user={user} 
          />
        </div>
      )}
    </div>
  );
}

export default function PlayPage() {
  return (
    <Suspense fallback={
      <div className="flex flex-col items-center justify-center min-h-screen bg-background p-6">
        <div className="flex flex-col items-center gap-4">
          <div className="w-12 h-12 rounded-xl bg-white/5 animate-pulse" />
          <div className="w-48 h-5 bg-white/5 rounded-full animate-pulse" />
        </div>
      </div>
    }>
      <PlayContent />
    </Suspense>
  );
}

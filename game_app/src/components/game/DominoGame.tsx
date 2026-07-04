"use client";

import { useDomino } from "@/hooks/useDomino";
import { DominoBoard } from "./DominoBoard";
import { GameRoom } from "@/hooks/useGameRoom";
import { User } from "firebase/auth";
import { useEffect, useRef, useMemo } from "react";
import confetti from "canvas-confetti";
import { soundEngine } from "@/lib/SoundEngine";
import { motion } from "framer-motion";

interface DominoGameProps {
  roomId: string;
  room: GameRoom;
  user: User;
}

export function DominoGame({ roomId, room, user }: DominoGameProps) {
  const { gameState, placePiece, passTurn, drawPiece, startNewRound, voteRematch, error } = useDomino(
    roomId,
    user,
    room.status,
    room.players
  );

  // Play sounds for piece placement
  const prevVersion = useRef<number>(gameState?.version || 0);
  useEffect(() => {
    if (gameState && gameState.version > prevVersion.current) {
      if (gameState.chain?.pieces?.length > 0) {
        // Just play a tick for placing a piece
        soundEngine.playTick();
      }
      prevVersion.current = gameState.version;
    }
  }, [gameState]);

  // Round Win / Game Win Confetti & Sound
  useEffect(() => {
    if (gameState?.gameWinner) {
      soundEngine.playWin();
      if (gameState.gameWinner === user.uid || (gameState.turnOrder.length === 4 && gameState.turnOrder[(gameState.turnOrder.indexOf(user.uid) + 2) % 4] === gameState.gameWinner)) {
        confetti({
          particleCount: 200,
          spread: 90,
          origin: { y: 0.6 },
          colors: ["#3b82f6", "#ef4444", "#f59e0b", "#10b981"]
        });
      }
    } else if (gameState?.roundWinner) {
      soundEngine.playWin(); // Or a different sound for round win
    }
  }, [gameState?.roundWinner, gameState?.gameWinner, user.uid, gameState?.turnOrder]);

  if (error) {
    return <div className="text-red-500 p-4 bg-red-500/10 rounded-lg">{error}</div>;
  }

  if (!gameState) {
    return (
      <div className="flex flex-col gap-4 w-full max-w-4xl">
        <div className="w-full h-16 bg-white/5 rounded-2xl animate-pulse" />
        <div className="w-full h-64 bg-white/5 rounded-3xl animate-pulse" />
        <div className="w-full h-32 bg-white/5 rounded-3xl animate-pulse" />
      </div>
    );
  }

  // Waiting for players
  if (room.status === "waiting") {
    return (
      <div className="w-full max-w-md bg-card border border-white/10 rounded-3xl p-8 flex flex-col items-center gap-4 text-center shadow-2xl">
        <div className="w-16 h-16 rounded-full bg-primary/15 flex items-center justify-center animate-pulse">
          <svg viewBox="0 0 40 40" className="w-8 h-8">
            <rect x="4" y="10" width="32" height="20" rx="3" fill="none" stroke="#5e6ad2" strokeWidth="3"/>
            <line x1="20" y1="10" x2="20" y2="30" stroke="#5e6ad2" strokeWidth="3"/>
            <circle cx="12" cy="20" r="2.5" fill="#5e6ad2"/>
            <circle cx="28" cy="20" r="2.5" fill="#5e6ad2"/>
          </svg>
        </div>
        <h3 className="text-xl font-bold">في انتظار اللاعبين...</h3>
        <p className="text-muted-foreground text-sm">
          شارك كود الغرفة <span className="text-primary font-bold">{roomId}</span> مع {room.maxPlayers - Object.keys(room.players).length} لاعب تاني
        </p>
        <div className="text-xs text-muted-foreground mt-2">
          الهدف: {gameState.targetScore || room.targetScore || 101} نقطة | {room.maxPlayers} لاعبين
        </div>
      </div>
    );
  }

  // Still initializing (dealing cards)
  if (gameState.needsInitialization || !gameState.hands || Object.keys(gameState.hands).length === 0) {
    return (
      <div className="flex flex-col gap-4 w-full max-w-4xl items-center">
        <div className="w-full h-16 bg-white/5 rounded-2xl animate-pulse" />
        <div className="text-muted-foreground font-medium animate-pulse">جاري توزيع القطع...</div>
      </div>
    );
  }

  const isTeammateOfWinner = useMemo(() => {
    if (!gameState || !gameState.gameWinner) return false;
    if (gameState.gameWinner === user.uid) return true;
    if (gameState.turnOrder.length === 4) {
      const myIndex = gameState.turnOrder.indexOf(user.uid);
      if (myIndex !== -1) {
        const partnerIndex = (myIndex + 2) % 4;
        const partnerUid = gameState.turnOrder[partnerIndex];
        return gameState.gameWinner === partnerUid;
      }
    }
    return false;
  }, [gameState, user]);

  return (
    <div className="w-full flex flex-col items-center gap-6 relative">
      
      {/* Game Over / Round Over Overlay */}
      {(gameState.roundWinner || gameState.gameWinner) && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-background/80 backdrop-blur-sm rounded-3xl">
          <motion.div 
            initial={{ scale: 0.8, opacity: 0 }}
            animate={{ scale: 1, opacity: 1 }}
            className="bg-card border border-white/10 shadow-2xl p-8 rounded-3xl flex flex-col items-center gap-4 text-center max-w-md w-full mx-4"
          >
            <h2 className="text-3xl font-bold text-primary">
              {gameState.gameWinner 
                ? (isTeammateOfWinner ? "لقد فزت باللعبة! 🎉" : "انتهت اللعبة") 
                : (gameState.roundWinner === 'tie' ? "تعادل (قفلة) 🔒" : "نهاية الجولة")}
            </h2>
            
            <p className="text-muted-foreground text-lg mb-4">
              {gameState.gameWinner 
                ? "الفريق الفائز وصل للهدف!" 
                : "النقاط تمت إضافتها للنتيجة."}
            </p>

            <div className="w-full bg-secondary/30 rounded-xl p-4 flex flex-col gap-2 mb-4">
              {gameState.turnOrder.map(uid => (
                <div key={`end-score-${uid}`} className="flex justify-between font-bold text-lg">
                  <span>{room.players[uid]?.name || (uid === user.uid ? "أنت" : "الخصم")}</span>
                  <span className="text-primary">{gameState.scores[uid]} / {gameState.targetScore}</span>
                </div>
              ))}
            </div>

            {gameState.gameWinner ? (
              <button
                onClick={voteRematch}
                className="w-full bg-primary hover:bg-primary/80 text-white font-bold py-4 rounded-xl transition-all"
              >
                {room.rematchVotes?.[user.uid] ? "في انتظار الخصم..." : "إعادة المباراة (Rematch)"}
              </button>
            ) : (
              // Only host (or first player) can start next round to avoid duplicates
              gameState.turnOrder[0] === user.uid ? (
                <button
                  onClick={startNewRound}
                  className="w-full bg-primary hover:bg-primary/80 text-white font-bold py-4 rounded-xl transition-all"
                >
                  بدء الجولة القادمة
                </button>
              ) : (
                <div className="text-muted-foreground font-medium animate-pulse">في انتظار مدير الغرفة لبدء الجولة...</div>
              )
            )}
          </motion.div>
        </div>
      )}

      <DominoBoard
        gameState={gameState}
        roomStatus={room.status}
        userId={user.uid}
        players={room.players}
        onPlacePiece={placePiece}
        onPass={passTurn}
        onDraw={drawPiece}
      />
    </div>
  );
}

"use client";

import { useLudo } from "@/hooks/useLudo";
import { LudoBoard } from "./LudoBoard";
import { GameRoom } from "@/hooks/useGameRoom";
import { User } from "firebase/auth";
import { LudoEngine } from "@/game-logic/ludo";
import { useEffect, useRef, useMemo } from "react";
import { motion, AnimatePresence } from "framer-motion";
import confetti from "canvas-confetti";
import { soundEngine } from "@/lib/SoundEngine";

interface LudoGameProps {
  roomId: string;
  room: GameRoom;
  user: User;
}

// Dice face SVG component (dots instead of numbers)
function DiceFace({ value }: { value: number }) {
  const dotPositions: Record<number, [number, number][]> = {
    1: [[20, 20]],
    2: [[10, 10], [30, 30]],
    3: [[10, 10], [20, 20], [30, 30]],
    4: [[10, 10], [30, 10], [10, 30], [30, 30]],
    5: [[10, 10], [30, 10], [20, 20], [10, 30], [30, 30]],
    6: [[10, 10], [30, 10], [10, 20], [30, 20], [10, 30], [30, 30]],
  };
  const dots = dotPositions[value] || [];
  return (
    <svg viewBox="0 0 40 40" className="w-full h-full">
      {dots.map(([cx, cy], i) => (
        <circle key={i} cx={cx} cy={cy} r="4.5" fill="#1a1a2e" />
      ))}
    </svg>
  );
}

const colorNames: Record<number, string> = {
  1: "أحمر",
  2: "أخضر",
  3: "أصفر",
  4: "أزرق",
};

const colorHex: Record<number, string> = {
  1: "#ef4444",
  2: "#22c55e",
  3: "#eab308",
  4: "#3b82f6",
};

export function LudoGame({ roomId, room, user }: LudoGameProps) {
  const { gameState, requestDiceRoll, movePiece, skipTurn, voteRematch, error } = useLudo(
    roomId,
    user,
    room.status,
    room.players
  );

  const colorMap = useMemo(() => {
    const map: Record<string, any> = {};
    if (room.players) {
      Object.entries(room.players).forEach(([pUid, pData]: [string, any]) => {
        map[pUid] = pData.color;
      });
    }
    return map;
  }, [room.players]);

  const isMyTurn = gameState?.turnOrder[gameState.currentTurnIndex] === user.uid;
  const myPieces = gameState?.pieces[user.uid] as [number, number, number, number];
  const validMoves = isMyTurn && gameState?.dice?.value ? LudoEngine.getValidMoves(myPieces, gameState.dice.value, user.uid, gameState, colorMap) : [];
  const hasValidMoves = validMoves.length > 0;

  // Auto-skip logic
  useEffect(() => {
    if (isMyTurn && gameState?.dice?.value && !hasValidMoves) {
      const timer = setTimeout(() => {
        skipTurn();
      }, 1500);
      return () => clearTimeout(timer);
    }
  }, [isMyTurn, gameState?.dice?.value, hasValidMoves, skipTurn]);

  // Dice Roll Sound
  useEffect(() => {
    if (gameState?.dice?.value && gameState?.dice?.rolledBy) {
      soundEngine.playDiceRoll();
    }
  }, [gameState?.dice?.value, gameState?.dice?.rolledAt]);

  // Move / Capture Sound
  const prevVersion = useRef<number>(gameState?.version || 0);
  const prevPieces = useRef<string>("");
  useEffect(() => {
    if (gameState && gameState.version > prevVersion.current) {
      if (!gameState?.dice?.value && !gameState.winner) {
        // Check if a capture happened (any piece went back to -1 compared to before)
        const currentPiecesStr = JSON.stringify(gameState.pieces);
        if (prevPieces.current && currentPiecesStr !== prevPieces.current) {
          const prev = JSON.parse(prevPieces.current);
          let captured = false;
          Object.entries(gameState.pieces).forEach(([uid, pieces]) => {
            if (prev[uid]) {
              (pieces as number[]).forEach((pos, idx) => {
                if (pos === -1 && prev[uid][idx] !== -1) captured = true;
              });
            }
          });
          if (captured) {
            soundEngine.playCapture();
          } else {
            soundEngine.playTick();
          }
        } else {
          soundEngine.playTick();
        }
      }
      prevVersion.current = gameState.version;
    }
    if (gameState?.pieces) {
      prevPieces.current = JSON.stringify(gameState.pieces);
    }
  }, [gameState]);

  // Victory Confetti
  useEffect(() => {
    if (gameState?.winner) {
      soundEngine.playWin();
      if (gameState.winner === user.uid) {
        confetti({
          particleCount: 200,
          spread: 90,
          origin: { y: 0.6 },
          colors: ["#3b82f6", "#ef4444", "#f59e0b", "#10b981"]
        });
      }
    }
  }, [gameState?.winner, user.uid]);

  if (error) {
    return <div className="text-red-500 p-4 bg-red-500/10 rounded-lg">{error}</div>;
  }

  if (!gameState) {
    return (
      <div className="flex flex-col gap-4 w-full max-w-2xl">
        {/* Skeleton loader */}
        <div className="h-10 bg-white/5 rounded-2xl animate-pulse" />
        <div className="w-full aspect-square bg-white/5 rounded-xl animate-pulse" />
        <div className="h-14 bg-white/5 rounded-full animate-pulse max-w-sm mx-auto w-full" />
      </div>
    );
  }

  // Get current turn player info
  const currentTurnUid = gameState.turnOrder[gameState.currentTurnIndex];
  const currentTurnColor = room.players[currentTurnUid]?.color;

  return (
    <div className="w-full flex flex-col items-center gap-4">
      
      {/* Player names bar */}
      {room.status === "playing" && !gameState.winner && gameState.turnOrder.length > 0 && (
        <div className="flex items-center justify-center gap-6 bg-secondary/30 px-5 py-2.5 rounded-2xl border border-white/5 backdrop-blur-sm">
          {gameState.turnOrder.map((uid) => {
            const pColor = room.players[uid]?.color;
            const isCurrent = uid === currentTurnUid;
            const isMe = uid === user.uid;
            return (
              <div
                key={uid}
                className={`flex items-center gap-2 px-3 py-1.5 rounded-full transition-all duration-300 ${
                  isCurrent ? "bg-white/10 scale-105" : "opacity-60"
                }`}
              >
                <div
                  className="w-3.5 h-3.5 rounded-full ring-2 ring-white/20"
                  style={{ backgroundColor: colorHex[pColor] || "#888" }}
                />
                <span className="text-xs font-semibold">
                  {isMe ? "أنت" : colorNames[pColor] || "لاعب"}
                </span>
                {isCurrent && (
                  <motion.span
                    animate={{ opacity: [1, 0.3, 1] }}
                    transition={{ repeat: Infinity, duration: 1.5 }}
                    className="text-xs"
                  >
                    ⏳
                  </motion.span>
                )}
              </div>
            );
          })}
        </div>
      )}

      <LudoBoard
        roomId={roomId}
        gameState={gameState}
        roomStatus={room.status}
        myColor={room.players[user.uid]?.color as any}
        onMakeMove={movePiece}
        userId={user.uid}
        players={room.players}
      />

      {/* Rematch UI */}
      {gameState.winner && (
        <div className="flex flex-col items-center gap-3 bg-secondary/20 p-5 rounded-2xl border border-white/10 w-full max-w-sm">
          {room.rematchVotes?.[user.uid] ? (
            <span className="text-muted-foreground animate-pulse text-sm">في انتظار موافقة الخصم على إعادة المباراة...</span>
          ) : (
            <button
              onClick={voteRematch}
              className="bg-primary hover:bg-primary/80 text-white font-bold py-3 px-8 rounded-full shadow-[0_0_15px_rgba(94,106,210,0.4)] transition-all active:scale-95"
            >
              إعادة المباراة (Rematch)
            </button>
          )}
          {Object.keys(room.rematchVotes || {}).length > 0 && (
            <span className="text-xs text-muted-foreground">
              {Object.keys(room.rematchVotes || {}).length}/{Object.keys(room.players).length} وافقوا
            </span>
          )}
        </div>
      )}
      
      {/* Compact Dice UI */}
      {room.status === "playing" && !gameState.winner && (
        <div className="flex items-center justify-between bg-secondary/40 backdrop-blur-md px-6 py-3 rounded-full border border-white/10 shadow-2xl w-full max-w-sm mx-auto">
          {/* Left side: Dice value or Wait text */}
          <div className="flex-1 min-h-[48px] flex items-center">
            <AnimatePresence mode="wait">
              {gameState?.dice?.value ? (
                <motion.div
                  key={`dice-${gameState.dice.rolledAt}`}
                  initial={{ scale: 0.5, rotateX: 180, rotateY: 180, opacity: 0 }}
                  animate={{ scale: 1, rotateX: 0, rotateY: 0, opacity: 1 }}
                  exit={{ scale: 0.5, opacity: 0 }}
                  transition={{ type: "spring", bounce: 0.6, duration: 0.8 }}
                  className="w-12 h-12 flex items-center justify-center bg-white rounded-xl shadow-[0_4px_15px_rgba(0,0,0,0.2),inset_0_-4px_8px_rgba(0,0,0,0.1)] border-b-4 border-gray-300 p-1.5"
                >
                  <DiceFace value={gameState.dice.value} />
                </motion.div>
              ) : (
                <motion.span 
                  key="wait-text"
                  initial={{ opacity: 0 }}
                  animate={{ opacity: 1 }}
                  exit={{ opacity: 0 }}
                  className="text-sm font-medium text-muted-foreground"
                >
                  {isMyTurn ? "جاء دورك!" : "في انتظار الخصم..."}
                </motion.span>
              )}
            </AnimatePresence>
          </div>
          
          {/* Right side: Action Button */}
          <div>
            {!gameState?.dice?.value ? (
              <button
                onClick={requestDiceRoll}
                disabled={!isMyTurn}
                className="flex items-center justify-center gap-2 px-6 py-2 bg-primary text-white rounded-full font-bold shadow-[0_0_15px_rgba(94,106,210,0.5)] disabled:opacity-50 hover:bg-primary/80 transition-all active:scale-95"
              >
                <svg viewBox="0 0 40 40" className="w-5 h-5">
                  <rect x="2" y="2" width="36" height="36" rx="6" fill="none" stroke="currentColor" strokeWidth="3"/>
                  <circle cx="12" cy="12" r="3" fill="currentColor"/>
                  <circle cx="28" cy="12" r="3" fill="currentColor"/>
                  <circle cx="20" cy="20" r="3" fill="currentColor"/>
                  <circle cx="12" cy="28" r="3" fill="currentColor"/>
                  <circle cx="28" cy="28" r="3" fill="currentColor"/>
                </svg>
                ارمِ النرد
              </button>
            ) : (
              isMyTurn ? (
                hasValidMoves ? (
                  <span className="text-green-500 font-bold animate-pulse text-sm">اختر قطعة للتحريك</span>
                ) : (
                  <span className="text-red-500 font-bold text-sm">يتم تخطي الدور...</span>
                )
              ) : (
                <span className="text-muted-foreground text-sm">يفكر...</span>
              )
            )}
          </div>
        </div>
      )}
    </div>
  );
}

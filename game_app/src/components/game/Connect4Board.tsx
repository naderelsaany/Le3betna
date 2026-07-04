"use client";

import { motion } from "framer-motion";
import { GameRoom } from "@/hooks/useGameRoom";
import { Player } from "@/game-logic/connect4";

import { Connect4State } from "@/hooks/useConnect4";

interface Connect4BoardProps {
  gameState: Connect4State;
  roomStatus: "waiting" | "playing" | "finished";
  rematchVotes?: Record<string, boolean>;
  myColor: Player | undefined;
  onMakeMove: (col: number) => void;
  onRematch?: () => void;
  userId?: string;
}

export function Connect4Board({ gameState, roomStatus, rematchVotes, myColor, onMakeMove, onRematch, userId }: Connect4BoardProps) {
  const { board, turn, winner } = gameState;

  const isSpectator = myColor === undefined;
  const isGameOver = !!winner;
  const isMyTurn = roomStatus === "playing" && !isGameOver && turn === myColor;

  const leftLabel = isSpectator ? "لاعب 1" : "أنت";
  const leftColor = isSpectator ? "bg-blue-500 shadow-blue-500/50" : (myColor === 1 ? "bg-blue-500 shadow-blue-500/50" : "bg-red-500 shadow-red-500/50");

  const rightLabel = isSpectator ? "لاعب 2" : "الخصم";
  const rightColor = isSpectator ? "bg-red-500 shadow-red-500/50" : (myColor === 1 ? "bg-red-500 shadow-red-500/50" : "bg-blue-500 shadow-blue-500/50");

  let statusText = null;
  if (roomStatus === "waiting") {
    statusText = (
      <span className="text-muted-foreground animate-pulse">
        {isSpectator ? "في انتظار اللاعبين..." : "في انتظار الخصم..."}
      </span>
    );
  } else if (roomStatus === "playing" && !isGameOver) {
    if (isSpectator) {
      statusText = <span className="text-muted-foreground">دور {turn === 1 ? "لاعب 1" : "لاعب 2"}</span>;
    } else {
      statusText = isMyTurn ? (
        <span className="text-primary">دورك الآن</span>
      ) : (
        <span className="text-muted-foreground">دور الخصم</span>
      );
    }
  } else if (isGameOver) {
    if (winner === "draw") {
      statusText = <span className="text-yellow-500">التعادل! 🤝</span>;
    } else if (isSpectator) {
      statusText = <span className="text-green-500">فاز {winner === 1 ? "لاعب 1" : "لاعب 2"}! 🎉</span>;
    } else {
      statusText = winner === myColor ? (
        <span className="text-green-500">لقد فزت! 🎉</span>
      ) : (
        <span className="text-destructive">لقد خسرت 😔</span>
      );
    }
  }

  return (
    <div className="flex flex-col items-center gap-6 w-full max-w-2xl mx-auto p-4">
      {/* Game Status Header */}
      <div className="flex justify-between items-center w-full px-4 py-3 bg-secondary/30 rounded-2xl border border-white/5 backdrop-blur-md">
        <div className="flex items-center gap-3">
          <div className={`w-4 h-4 rounded-full shadow-[0_0_10px_rgba(0,0,0,0.5)] ${leftColor}`} />
          <span className="font-medium text-sm">{leftLabel}</span>
        </div>
        
        <div className="text-center font-bold text-lg tracking-wider">
          {statusText}
        </div>

        <div className="flex items-center gap-3">
          <span className="font-medium text-sm">{rightLabel}</span>
          <div className={`w-4 h-4 rounded-full shadow-[0_0_10px_rgba(0,0,0,0.5)] ${rightColor}`} />
        </div>
      </div>

      {isGameOver && onRematch && userId && !isSpectator && (
        <div className="flex flex-col items-center gap-3 bg-secondary/20 p-4 rounded-2xl border border-white/10 w-full max-w-[600px] mb-2">
          {rematchVotes?.[userId] ? (
            <span className="text-muted-foreground animate-pulse">في انتظار موافقة الخصم على إعادة المباراة...</span>
          ) : (
            <button
              onClick={onRematch}
              className="bg-primary hover:bg-primary/80 text-white font-bold py-3 px-8 rounded-full shadow-[0_0_15px_rgba(94,106,210,0.4)] transition-all"
            >
              إعادة المباراة (Rematch)
            </button>
          )}
          {Object.keys(rematchVotes || {}).length > 0 && (
            <span className="text-xs text-muted-foreground">
              {Object.keys(rematchVotes || {}).length}/2 وافقوا
            </span>
          )}
        </div>
      )}

      {/* The Board */}
      <div className="relative bg-card p-2 sm:p-5 rounded-3xl border border-white/10 shadow-2xl flex justify-center w-full aspect-[7/6] max-w-[min(95vw,80dvh)] lg:max-w-[600px] transform-gpu touch-manipulation mx-auto">
        <div className="grid grid-cols-7 gap-1 sm:gap-2 w-full h-full bg-background/50 p-1 sm:p-2 rounded-2xl">
          {Array.from({ length: 7 }).map((_, colIndex) => (
            <div
              key={`col-${colIndex}`}
              className={`flex flex-col gap-1 sm:gap-2 rounded-full transition-colors duration-200 p-1 ${
                isMyTurn ? "hover:bg-white/10 cursor-pointer" : "cursor-default"
              }`}
              data-testid={`col-${colIndex}`}
              onClick={() => isMyTurn && onMakeMove(colIndex)}
            >
              {Array.from({ length: 6 }).map((_, rowIndex) => {
                const cellPlayer = board[rowIndex][colIndex];
                
                // Set color based on player
                let colorClass = "bg-black/40 shadow-inner"; // Empty slot
                if (cellPlayer === 1) {
                  // Player 1 (Blue)
                  colorClass = "bg-blue-500 shadow-[inset_0_-4px_8px_rgba(0,0,0,0.3),0_0_15px_rgba(59,130,246,0.6)] border border-blue-400";
                } else if (cellPlayer === 2) {
                  // Player 2 (Red)
                  colorClass = "bg-red-500 shadow-[inset_0_-4px_8px_rgba(0,0,0,0.3),0_0_15px_rgba(239,68,68,0.6)] border border-red-400";
                }

                return (
                  <div key={`cell-${rowIndex}-${colIndex}`} className="flex-1 w-full aspect-square relative">
                    <div className="absolute inset-0 rounded-full bg-black/60 shadow-[inset_0_3px_6px_rgba(0,0,0,0.8)] border border-white/5" />
                    {cellPlayer !== 0 && (
                      <motion.div
                        initial={{ y: -300, opacity: 0 }}
                        animate={{ y: 0, opacity: 1 }}
                        transition={{ type: "spring", bounce: 0.5, duration: 0.6 }}
                        className={`absolute inset-0 rounded-full ${colorClass}`}
                      />
                    )}
                  </div>
                );
              })}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

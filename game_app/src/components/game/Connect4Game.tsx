"use client";

import { useConnect4 } from "@/hooks/useConnect4";
import { Connect4Board } from "./Connect4Board";
import { GameRoom } from "@/hooks/useGameRoom";
import { User } from "firebase/auth";
import { useEffect, useRef } from "react";
import confetti from "canvas-confetti";
import { soundEngine } from "@/lib/SoundEngine";

interface Connect4GameProps {
  roomId: string;
  room: GameRoom;
  user: User;
}

export function Connect4Game({ roomId, room, user }: Connect4GameProps) {
  const { gameState, makeMove, voteRematch, error } = useConnect4(
    roomId,
    user,
    room.status,
    room.players
  );

  const prevVersion = useRef<number>(gameState?.version || 0);

  useEffect(() => {
    if (gameState && gameState.version > prevVersion.current) {
      if (!gameState.winner) {
        soundEngine.playTick();
      }
      prevVersion.current = gameState.version;
    }
  }, [gameState]);

  useEffect(() => {
    if (gameState?.winner && gameState.winner !== "draw") {
      soundEngine.playWin();
      if (gameState.winner === room.players[user.uid]?.color) {
        confetti({
          particleCount: 150,
          spread: 70,
          origin: { y: 0.6 },
          colors: ["#3b82f6", "#ef4444", "#f59e0b"]
        });
      }
    }
  }, [gameState?.winner, room.players, user.uid]);

  if (error) {
    return <div className="text-red-500 p-4 bg-red-500/10 rounded-lg">{error}</div>;
  }

  if (!gameState) {
    return (
      <div className="flex flex-col gap-4 w-full max-w-2xl">
        <div className="h-10 bg-white/5 rounded-2xl animate-pulse" />
        <div className="w-full aspect-[7/6] bg-white/5 rounded-3xl animate-pulse" />
      </div>
    );
  }

  return (
    <Connect4Board
      gameState={gameState}
      roomStatus={room.status}
      rematchVotes={room.rematchVotes}
      myColor={room.players[user.uid]?.color as any}
      onMakeMove={makeMove}
      onRematch={voteRematch}
      userId={user.uid}
    />
  );
}

import { useState, useEffect } from "react";
import { ref, onValue, runTransaction, serverTimestamp } from "firebase/database";
import { rtdb } from "@/firebase/client";

export function useGameEngine<T>(roomId: string | null, gameType: string | null) {
  const [gameState, setGameState] = useState<T | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Listen to game-specific state
  useEffect(() => {
    if (!roomId || !gameType) return;

    const gameRef = ref(rtdb, `rooms/${roomId}/${gameType}`);
    const unsubscribe = onValue(gameRef, (snapshot) => {
      if (snapshot.exists()) {
        setGameState(snapshot.val() as T);
      } else {
        setGameState(null);
      }
    });

    return () => {
      unsubscribe();
    };
  }, [roomId, gameType]);

  // Generic update for game state using transaction
  const updateGameState = async (updateFn: (currentData: T) => T | undefined | null) => {
    if (!roomId || !gameType) return;
    
    const gameRef = ref(rtdb, `rooms/${roomId}/${gameType}`);
    try {
      const result = await runTransaction(gameRef, (currentData: any) => {
        if (currentData === null) return currentData;
        const newData = updateFn(currentData as T);
        return newData;
      });
      return result;
    } catch (err) {
      console.error("Game update failed:", err);
      throw err;
    }
  };

  return { gameState, updateGameState, error };
}

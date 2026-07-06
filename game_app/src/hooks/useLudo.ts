import { useCallback, useMemo, useRef, useEffect } from "react";
import { useGameEngine } from "./useGameEngine";
import { update, ref, runTransaction } from "firebase/database";
import { rtdb } from "@/firebase/client";
import { User } from "firebase/auth";
import { LudoEngine, PlayerColor, LudoState } from "@/game-logic/ludo";

export function useLudo(roomId: string | null, user: User | null, roomStatus: string | undefined, players: any) {
  const { gameState, updateGameState, error } = useGameEngine<LudoState>(roomId, "ludo");

  // Keep a ref so useCallback doesn't need gameState in deps
  const gameStateRef = useRef(gameState);
  useEffect(() => {
    gameStateRef.current = gameState;
  }, [gameState]);

  // Memoize colorMap to avoid recreating it on every render
  const colorMap = useMemo(() => {
    const map: Record<string, PlayerColor> = {};
    if (players) {
      Object.entries(players).forEach(([pUid, pData]: [string, any]) => {
        map[pUid] = pData.color as PlayerColor;
      });
    }
    return map;
  }, [players]);

  const requestDiceRoll = useCallback(async () => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const isMyTurn = gs.turnOrder[gs.currentTurnIndex] === uid;
    
    if (!isMyTurn || gs?.dice?.value) return; 

    // Generate random value outside the transaction to guarantee determinism
    // If the transaction retries, it uses the exact same roll result.
    const randomValue = Math.floor(Math.random() * 6) + 1;
    const isSix = randomValue === 6;
    const rollTimestamp = Date.now();

    try {
      await updateGameState((currentData: LudoState) => {
        if (currentData.winner) return currentData;
        if (currentData.turnOrder[currentData.currentTurnIndex] !== uid) return currentData;
        if (currentData?.dice?.value) return currentData;

        const newSixCount = isSix ? (currentData.consecutiveSixes || 0) + 1 : 0;

        if (newSixCount >= 3) {
          // 3 sixes penalty: turn ends immediately, dice cleared, consecutiveSixes reset
          return {
            ...currentData,
            dice: { value: null, rolledBy: null, rolledAt: null },
            consecutiveSixes: 0,
            currentTurnIndex: (currentData.currentTurnIndex + 1) % currentData.turnOrder.length,
            version: (currentData.version || 0) + 1,
          };
        } else {
          return {
            ...currentData,
            dice: {
              value: randomValue,
              rolledBy: uid,
              rolledAt: rollTimestamp,
            },
            consecutiveSixes: newSixCount,
            version: (currentData.version || 0) + 1,
          };
        }
      });
    } catch (err) {
      console.error("Dice roll failed:", err);
    }
  }, [user, roomId, roomStatus, updateGameState]);

  const movePiece = useCallback(async (pieceIndex: number) => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const isMyTurn = gs.turnOrder[gs.currentTurnIndex] === uid;
    
    if (!isMyTurn || !gs?.dice?.value) return; 

    try {
      const roomRef = ref(rtdb, `rooms/${roomId}`);
      await runTransaction(roomRef, (currentRoomData: any) => {
        if (!currentRoomData) return currentRoomData;
        const currentData = currentRoomData.ludo;
        if (!currentData) return currentRoomData;

        if (currentData.winner) return currentRoomData;
        if (currentData.turnOrder[currentData.currentTurnIndex] !== uid) return currentRoomData;
        if (!currentData?.dice?.value) return currentRoomData;

        try {
          const updatedLudo = LudoEngine.applyMove(currentData, uid, pieceIndex, colorMap);
          currentRoomData.ludo = updatedLudo;
          if (updatedLudo.winner) {
            currentRoomData.status = "finished";
          }
          currentRoomData.version = (currentRoomData.version || 0) + 1;
          return currentRoomData;
        } catch (e) {
          return currentRoomData;
        }
      });
    } catch (err) {
      console.error("Move failed:", err);
    }
  }, [user, roomId, roomStatus, colorMap]);

  const skipTurn = useCallback(async () => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const isMyTurn = gs.turnOrder[gs.currentTurnIndex] === uid;
    if (!isMyTurn || !gs?.dice?.value) return;

    try {
      await updateGameState((currentData: LudoState) => {
        if (currentData.winner) return currentData;
        if (currentData.turnOrder[currentData.currentTurnIndex] !== uid) return currentData;
        if (!currentData?.dice?.value) return currentData;
        
        // Immutable update
        return {
          ...currentData,
          currentTurnIndex: (currentData.currentTurnIndex + 1) % currentData.turnOrder.length,
          dice: { value: null, rolledBy: null, rolledAt: null },
          consecutiveSixes: 0,
          version: (currentData.version || 0) + 1,
        };
      });
    } catch (err) {
      console.error("Skip turn failed:", err);
    }
  }, [user, roomId, roomStatus, updateGameState]);

  const voteRematch = useCallback(async () => {
    if (roomStatus !== "finished" || !roomId || !user) return;
    
    try {
      const { runTransaction, ref: dbRef } = await import("firebase/database");
      const roomRef = dbRef(rtdb, `rooms/${roomId}`);
      await runTransaction(roomRef, (currentData: any) => {
        if (!currentData) return currentData;
        if (!currentData.rematchVotes) currentData.rematchVotes = {};
        currentData.rematchVotes[user.uid] = true;
        
        const playersCount = Object.keys(currentData.players || {}).length;
        const votesCount = Object.keys(currentData.rematchVotes).length;
        
        if (votesCount >= playersCount && playersCount > 0) {
          currentData.status = "playing";
          currentData.rematchVotes = null;
          if (currentData.ludo) {
            const pieces: Record<string, [number, number, number, number]> = {};
            currentData.ludo.turnOrder.forEach((uid: string) => {
              pieces[uid] = [-1, -1, -1, -1];
            });
            currentData.ludo.pieces = pieces;
            currentData.ludo.currentTurnIndex = 0;
            currentData.ludo.dice = { value: null, rolledBy: null, rolledAt: null };
            currentData.ludo.winner = null;
            currentData.ludo.consecutiveSixes = 0;
            currentData.ludo.version = (currentData.ludo.version || 0) + 1;
          }
        }
        currentData.version = (currentData.version || 0) + 1;
        return currentData;
      });
    } catch (err) {
      console.error("Ludo rematch vote failed:", err);
    }
  }, [roomId, user, roomStatus]);

  return { gameState, requestDiceRoll, movePiece, skipTurn, voteRematch, error };
}


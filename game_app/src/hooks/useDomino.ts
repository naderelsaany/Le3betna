import { useCallback, useRef, useEffect } from "react";
import { useGameEngine } from "./useGameEngine";
import { update, ref } from "firebase/database";
import { rtdb } from "@/firebase/client";
import { User } from "firebase/auth";
import { DominoEngine, DominoState } from "@/game-logic/domino";

export function useDomino(roomId: string | null, user: User | null, roomStatus: string | undefined, players: any) {
  const { gameState, updateGameState, error } = useGameEngine<DominoState>(roomId, "domino");

  const gameStateRef = useRef(gameState);
  gameStateRef.current = gameState;

  // Initialize game state if it was just created
  useEffect(() => {
    if (gameState?.needsInitialization && roomStatus === "playing" && user && roomId) {
      // Anyone can attempt to initialize. The transaction inner check prevents race conditions.
      updateGameState((currentData: any) => {
        if (!currentData.needsInitialization) return currentData;
        
        const initialState = DominoEngine.createInitialState(
          currentData.turnOrder,
          currentData.targetScore || 101
        );
        
        // Preserve targetScore
        initialState.targetScore = currentData.targetScore || 101;
        
        return initialState;
      }).catch(console.error);
    }
  }, [gameState?.needsInitialization, roomStatus, user, roomId, updateGameState]);

  const placePiece = useCallback(async (pieceId: number, side: 'left' | 'right') => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const isMyTurn = gs.turnOrder[gs.currentTurnIndex] === uid;
    
    if (!isMyTurn) return;

    try {
      const result = await updateGameState((currentData: DominoState) => {
        if (currentData.turnOrder[currentData.currentTurnIndex] !== uid) return currentData;
        if (currentData.roundWinner || currentData.gameWinner) return currentData;
        
        try {
          return DominoEngine.placePiece(currentData, uid, pieceId, side);
        } catch (e) {
          return currentData;
        }
      });

      if (result?.committed) {
        const newData = result.snapshot.val();
        if (newData?.gameWinner) {
          update(ref(rtdb), { [`rooms/${roomId}/status`]: "finished" });
        }
      }
    } catch (err) {
      console.error("Domino move failed:", err);
    }
  }, [user, roomId, roomStatus, updateGameState]);

  const passTurn = useCallback(async () => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const isMyTurn = gs.turnOrder[gs.currentTurnIndex] === uid;
    
    if (!isMyTurn) return;

    try {
      const result = await updateGameState((currentData: DominoState) => {
        if (currentData.turnOrder[currentData.currentTurnIndex] !== uid) return currentData;
        if (currentData.roundWinner || currentData.gameWinner) return currentData;

        return DominoEngine.passTurn(currentData, uid);
      });

      if (result?.committed) {
        const newData = result.snapshot.val();
        if (newData?.gameWinner) {
          update(ref(rtdb), { [`rooms/${roomId}/status`]: "finished" });
        }
      }
    } catch (err) {
      console.error("Domino pass failed:", err);
    }
  }, [user, roomId, roomStatus, updateGameState]);

  const drawPiece = useCallback(async () => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const isMyTurn = gs.turnOrder[gs.currentTurnIndex] === uid;
    
    if (!isMyTurn) return;

    try {
      await updateGameState((currentData: DominoState) => {
        if (currentData.turnOrder[currentData.currentTurnIndex] !== uid) return currentData;
        if (currentData.roundWinner || currentData.gameWinner) return currentData;

        return DominoEngine.drawPiece(currentData, uid);
      });
    } catch (err) {
      console.error("Domino draw failed:", err);
    }
  }, [user, roomId, roomStatus, updateGameState]);

  const startNewRound = useCallback(async () => {
    const gs = gameStateRef.current;
    if (!user || !roomId || !gs) return;
    if (roomStatus !== "playing") return;
    
    if (!gs.roundWinner || gs.gameWinner) return;

    try {
      await updateGameState((currentData: DominoState) => {
        if (!currentData.roundWinner || currentData.gameWinner) return currentData;
        
        return DominoEngine.dealNewRound(currentData, currentData.roundWinner === 'tie' ? null : currentData.roundWinner);
      });
    } catch (err) {
      console.error("Domino start round failed:", err);
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
          if (currentData.domino) {
            currentData.domino = DominoEngine.createInitialState(
              currentData.domino.turnOrder, 
              currentData.domino.targetScore
            );
          }
        }
        return currentData;
      });
    } catch (err) {
      console.error("Domino rematch vote failed:", err);
    }
  }, [roomId, user, roomStatus]);

  return { gameState, placePiece, passTurn, drawPiece, startNewRound, voteRematch, error };
}

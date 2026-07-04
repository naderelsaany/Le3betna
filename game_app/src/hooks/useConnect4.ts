import { useGameEngine } from "./useGameEngine";
import { Connect4Engine, Board, Player } from "@/game-logic/connect4";
import { User } from "firebase/auth";
import { update, ref, runTransaction } from "firebase/database";
import { rtdb } from "@/firebase/client";

export interface Connect4State {
  board: Board;
  turn: Player;
  winner: Player | "draw" | null;
  version: number;
}

export function useConnect4(roomId: string | null, user: User | null, roomStatus: string | undefined, players: any) {
  const { gameState, updateGameState, error } = useGameEngine<Connect4State>(roomId, "connect4");

  const makeMove = async (col: number) => {
    if (!user || !roomId || !gameState) return;
    if (roomStatus !== "playing") return;

    const uid = user.uid;
    const playerColor = players?.[uid]?.color;
    
    if (!playerColor || gameState.turn !== playerColor) return; // Not their turn

    try {
      const roomRef = ref(rtdb, `rooms/${roomId}`);
      await runTransaction(roomRef, (currentRoomData: any) => {
        if (!currentRoomData) return currentRoomData;
        const currentData = currentRoomData.connect4;
        if (!currentData) return currentRoomData;

        if (currentData.winner) return currentRoomData;
        // Double check turn inside transaction
        if (currentData.turn !== playerColor) return currentRoomData;

        try {
          // Attempt the drop using the pure engine
          const newBoard = Connect4Engine.dropPiece(currentData.board, col, playerColor as Player);
          
          // Check win/draw
          const winner = Connect4Engine.checkWinner(newBoard);
          const isDraw = !winner && Connect4Engine.isDraw(newBoard);

          const updatedConnect4 = {
            ...currentData,
            board: newBoard,
            winner: winner ? winner : isDraw ? "draw" : null,
            turn: winner || isDraw ? currentData.turn : (playerColor === 1 ? 2 : 1) as Player,
            version: (currentData.version || 0) + 1,
          };

          currentRoomData.connect4 = updatedConnect4;

          if (updatedConnect4.winner) {
            currentRoomData.status = "finished";
          }
          currentRoomData.version = (currentRoomData.version || 0) + 1;
          return currentRoomData;
        } catch (e) {
          // Invalid move (e.g. column full), abort update
          return currentRoomData;
        }
      });
    } catch (err) {
      console.error("Move failed:", err);
    }
  };

  const voteRematch = async () => {
    if (roomStatus !== "finished" || !roomId || !user) return;
    
    try {
      const roomRef = ref(rtdb, `rooms/${roomId}`);
      await runTransaction(roomRef, (currentData: any) => {
        if (!currentData) return currentData;
        
        // Initialize rematchVotes if not exists
        if (!currentData.rematchVotes) {
          currentData.rematchVotes = {};
        }
        
        // Add current user's vote
        currentData.rematchVotes[user.uid] = true;
        
        // Check if all players have voted
        const playersCount = Object.keys(currentData.players || {}).length;
        const votesCount = Object.keys(currentData.rematchVotes).length;
        
        if (votesCount >= playersCount && playersCount > 0) {
          // Everyone voted, reset game
          currentData.status = "playing";
          currentData.rematchVotes = null; // Clear votes
          
          if (currentData.connect4) {
            const prevWinner = currentData.connect4.winner;
            let nextTurn: 1 | 2 = 1;
            if (prevWinner === 1) {
              nextTurn = 2;
            } else if (prevWinner === 2) {
              nextTurn = 1;
            } else {
              nextTurn = Math.random() < 0.5 ? 1 : 2;
            }

            currentData.connect4.board = Connect4Engine.createEmptyBoard();
            currentData.connect4.turn = nextTurn;
            currentData.connect4.winner = null;
            currentData.connect4.version = (currentData.connect4.version || 0) + 1;
          }
        }
        
        currentData.version = (currentData.version || 0) + 1;
        return currentData;
      });
    } catch (err) {
      console.error("Rematch voting failed:", err);
    }
  };

  return { gameState, makeMove, voteRematch, error };
}

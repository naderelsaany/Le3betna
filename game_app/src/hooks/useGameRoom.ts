import { useState, useEffect, useCallback, useRef } from "react";
import { ref, onValue, set, get, update, onDisconnect, serverTimestamp, runTransaction } from "firebase/database";
import { rtdb } from "@/firebase/client";
import { User } from "firebase/auth";

export type RoomStatus = "waiting" | "playing" | "finished";
export type GameType = "connect4" | "ludo" | "domino";

export interface GameRoom {
  status: RoomStatus;
  gameType: GameType;
  maxPlayers: number;
  targetScore?: number; // Added for domino
  players: Record<string, { color: number; lastSeen: number; online: boolean; name?: string; photoURL?: string }>;
  version: number;
  lastActivity: object;
  rematchVotes?: Record<string, boolean>;
  ludo?: any;
  connect4?: any;
  domino?: any;
}

export function useGameRoom(user: User | null, roomId: string | null) {
  const [room, setRoom] = useState<GameRoom | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const disconnectRef = useRef<any>(null);

  // Listen to Room Changes
  useEffect(() => {
    if (!roomId || !user) return;

    const roomRef = ref(rtdb, `rooms/${roomId}`);
    const unsubscribe = onValue(roomRef, (snapshot) => {
      if (snapshot.exists()) {
        setRoom(snapshot.val() as GameRoom);
      } else {
        setRoom(null);
        setError("الغرفة غير موجودة أو تم حذفها.");
      }
    });

    // Setup onDisconnect & Heartbeat
    const playerRef = ref(rtdb, `rooms/${roomId}/players/${user.uid}`);
    if (disconnectRef.current) {
      disconnectRef.current.cancel();
    }
    disconnectRef.current = onDisconnect(playerRef);
    disconnectRef.current.update({ online: false, lastSeen: serverTimestamp() });

    // Set as online immediately
    update(playerRef, { online: true, lastSeen: serverTimestamp() });

    return () => {
      unsubscribe();
      if (disconnectRef.current) {
        disconnectRef.current.cancel();
      }
    };
  }, [roomId, user]);

  // Create a new Room with a unique 4-digit code
  const createRoom = async (gameType: GameType, maxPlayers: number, initialGameState: any, targetScore?: number) => {
    if (!user) return null;
    setLoading(true);
    setError(null);

    let code = "";
    let committed = false;

    const newRoom: any = {
      status: "waiting",
      gameType,
      maxPlayers,
      players: {
        [user.uid]: { color: 1, lastSeen: Date.now(), online: true },
      },
      version: 1,
      lastActivity: serverTimestamp() as object,
    };
    
    if (targetScore) {
      newRoom.targetScore = targetScore;
    }
    
    if (initialGameState) {
      newRoom[gameType] = initialGameState;
    }

    // Pre-initialize host in Ludo if needed
    if (gameType === "ludo" && newRoom.ludo) {
      newRoom.ludo.turnOrder = [user.uid];
      newRoom.ludo.pieces = { [user.uid]: [-1, -1, -1, -1] };
    }

    // Retry loop to ensure 4-digit code uniqueness using transaction
    for (let i = 0; i < 5; i++) {
      code = Math.floor(1000 + Math.random() * 9000).toString(); // 1000 - 9999
      try {
        const result = await runTransaction(ref(rtdb, `rooms/${code}`), (currentData) => {
          if (currentData === null) {
            return newRoom;
          }
          return; // Abort transaction if room already exists
        });
        
        if (result.committed) {
          committed = true;
          break;
        }
      } catch (err) {
        console.error("Transaction error during room creation:", err);
      }
    }

    if (!committed) {
      setError("فشل إنشاء غرفة، يرجى المحاولة مرة أخرى.");
      setLoading(false);
      return null;
    }

    setLoading(false);
    return code;
  };

  // Join an existing room
  const joinRoom = async (code: string) => {
    if (!user) return false;
    setLoading(true);
    setError(null);

    const roomRef = ref(rtdb, `rooms/${code}`);
    try {
      // Fetch first to populate local cache so transaction doesn't abort on null
      const snap = await get(roomRef);
      if (!snap.exists()) {
        setError("الغرفة غير موجودة.");
        setLoading(false);
        return false;
      }

      const result = await runTransaction(roomRef, (currentData: GameRoom | null) => {
        if (currentData === null) {
          return currentData; // Let it proceed or fetch
        }

        // Evict offline players if room is still waiting
        if (currentData.status === "waiting" && currentData.players) {
          Object.keys(currentData.players).forEach(pUid => {
            if (!currentData.players[pUid].online && pUid !== user.uid) {
              delete currentData.players[pUid];
            }
          });
        }
        
        const playersCount = Object.keys(currentData.players || {}).length;
        
        // If user is already in the room, just return current data (reconnect)
        if (currentData.players && currentData.players[user.uid]) {
          currentData.players[user.uid].online = true;
          currentData.players[user.uid].lastSeen = Date.now();
          currentData.version = (currentData.version || 0) + 1;
          return currentData;
        }

        // If room is full
        if (playersCount >= (currentData.maxPlayers || 2)) {
          return; // Abort
        }

        // Add player as next available color and start game if full
        let newColor = playersCount + 1;
        // In a 2-player Ludo game, assign color 3 (Yellow) to player 2 so they sit opposite player 1 (Red)
        if (currentData.gameType === "ludo" && currentData.maxPlayers === 2 && playersCount === 1) {
          newColor = 3;
        }
        currentData.players[user.uid] = { color: newColor, lastSeen: Date.now(), online: true };
        
        if (playersCount + 1 === (currentData.maxPlayers || 2)) {
          currentData.status = "playing";

          // Initialize game state specific data if needed
          const uids = Object.keys(currentData.players);
          
          if (currentData.gameType === "ludo" && currentData.ludo) {
            currentData.ludo.turnOrder = uids;
            uids.forEach((u) => {
              currentData.ludo.pieces[u] = [-1, -1, -1, -1];
            });
          } else if (currentData.gameType === "domino" && currentData.domino) {
            currentData.domino.turnOrder = uids;
            // The creator should have already initialized scores for themselves, but we recreate full initial state here
            // because we now have all players
            // Need to import DominoEngine or just set initial structure here and let a cloud fn or first player initialize?
            // Since we can't easily import DominoEngine inside this transaction without making it messy,
            // we will set a flag `needsInitialization: true` and let the UI trigger initialization, 
            // OR we just initialize the basic structure and let `useDomino` handle it.
            // Actually, we can initialize scores array here:
            const scores: Record<string, number> = {};
            uids.forEach((uid) => (scores[uid] = 0));
            currentData.domino.scores = scores;
            currentData.domino.needsInitialization = true; // Signals the UI to call DominoEngine.dealNewRound
          }
        }
        
        currentData.lastActivity = serverTimestamp() as object;
        currentData.version = (currentData.version || 0) + 1;

        return currentData;
      });

      if (!result.committed) {
        setError("الغرفة ممتلئة أو غير موجودة.");
        setLoading(false);
        return false;
      }

      setLoading(false);
      return true;
    } catch (err: any) {
      setError(err.message);
      setLoading(false);
      return false;
    }
  };

  // Generic update for game state (scoped to specific path)
  const updateGameState = async (subPath: string, updateFn: (currentData: any) => any | undefined | null) => {
    if (!user || !roomId || !room) return;
    
    const gameRef = ref(rtdb, `rooms/${roomId}/${subPath}`);
    try {
      await runTransaction(gameRef, (currentData: any) => {
        if (currentData === null) return;
        return updateFn(currentData);
      });
    } catch (err) {
      console.error("Update failed:", err);
    }
  };

  // Leave Room
  const leaveRoom = async () => {
    if (!user || !roomId) return;
    try {
      // Try to cancel disconnect hook FIRST
      const playerRef = ref(rtdb, `rooms/${roomId}/players/${user.uid}`);
      await onDisconnect(playerRef).cancel();

      const roomRef = ref(rtdb, `rooms/${roomId}`);
      await runTransaction(roomRef, (currentData: GameRoom | null) => {
        if (!currentData) return;
        if (currentData.players && currentData.players[user.uid]) {
          delete currentData.players[user.uid];
          
          const remaining = Object.keys(currentData.players).length;
          if (remaining === 0) {
            return null; // delete room if empty
          }
          currentData.status = "waiting";
          currentData.rematchVotes = null as any;
          
          // Wipe game states to prevent stale states on next join
          if (currentData.ludo) {
            currentData.ludo = {
              turnOrder: [],
              currentTurnIndex: 0,
              dice: { value: null, rolledBy: null, rolledAt: null },
              pieces: {},
              winner: null,
              consecutiveSixes: 0,
              version: 1
            };
          }
          if (currentData.connect4) {
            currentData.connect4 = {
              board: Array(6).fill(null).map(() => Array(7).fill(0)),
              turn: 1,
              winner: null,
              version: 1
            };
          }

          currentData.version = (currentData.version || 0) + 1;
        }
        return currentData;
      });
    } catch (err) {
      console.error("Failed to leave room", err);
    }
  };

  return { room, loading, error, createRoom, joinRoom, leaveRoom, updateGameState };
}

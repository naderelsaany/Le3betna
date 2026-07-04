export type PlayerColor = 1 | 2 | 3 | 4; // 1: Red, 2: Green, 3: Yellow, 4: Blue

export interface LudoState {
  turnOrder: string[]; // UIDs of players in order
  currentTurnIndex: number;
  dice: {
    value: number | null;
    rolledBy: string | null;
    rolledAt: number | null;
  };
  pieces: Record<string, [number, number, number, number]>; 
  winner: string | null;
  version: number;
  consecutiveSixes: number; // Added for the 3-sixes rule
}

export const LudoEngine = {
  SAFE_ZONES: new Set([0, 8, 13, 21, 26, 34, 39, 47]), // Use Set for O(1) lookup
  MAX_CONSECUTIVE_SIXES: 3,

  // Convert relative position to absolute track position (0-51)
  getAbsolutePosition: (playerColor: PlayerColor, relativePos: number): number => {
    if (relativePos < 0 || relativePos > 50) return -1; // Not on main track
    const offsets = { 1: 13, 2: 0, 3: 39, 4: 26 };
    return (relativePos + offsets[playerColor]) % 52;
  },

  // Check if a move is valid theoretically based on dice
  isValidMove: (relativePos: number, diceValue: number): boolean => {
    if (relativePos === -1) return diceValue === 6;
    if (relativePos + diceValue > 56) return false;
    if (relativePos === 56) return false;
    return true;
  },

  // Check if the path of a piece is blocked by an enemy blockade
  isPathBlocked: (
    fromPos: number,
    diceValue: number,
    myColor: PlayerColor,
    state: LudoState,
    colorMap: Record<string, PlayerColor>
  ): boolean => {
    const blockades = LudoEngine.getBlockades(state, colorMap);
    
    if (fromPos === -1) {
      // Entering the board: check absolute position of relative position 0
      const startAbsPos = LudoEngine.getAbsolutePosition(myColor, 0);
      const posMap = blockades.get(startAbsPos);
      if (posMap) {
        let enemyHasBlockade = false;
        posMap.forEach((count, color) => {
          if (color !== myColor && count >= 2) {
            enemyHasBlockade = true;
          }
        });
        if (enemyHasBlockade) return true;
      }
      return false;
    }

    // Moving along the track
    for (let step = fromPos + 1; step <= fromPos + diceValue; step++) {
      if (step >= 0 && step <= 50) {
        const absPos = LudoEngine.getAbsolutePosition(myColor, step);
        const posMap = blockades.get(absPos);
        if (posMap) {
          let enemyHasBlockade = false;
          posMap.forEach((count, color) => {
            if (color !== myColor && count >= 2) {
              enemyHasBlockade = true;
            }
          });
          if (enemyHasBlockade) return true;
        }
      }
    }
    
    return false;
  },

  // Get all valid moves for a player
  getValidMoves: (
    pieces: [number, number, number, number],
    diceValue: number | null,
    uid?: string,
    state?: LudoState,
    colorMap?: Record<string, PlayerColor>
  ): number[] => {
    if (!diceValue) return [];
    return pieces
      .map((pos, idx) => {
        if (!LudoEngine.isValidMove(pos, diceValue)) return -1;
        if (uid && state && colorMap) {
          const myColor = colorMap[uid];
          if (myColor && LudoEngine.isPathBlocked(pos, diceValue, myColor, state, colorMap)) {
            return -1;
          }
        }
        return idx;
      })
      .filter((idx) => idx !== -1);
  },

  // Count pieces per color per absolute position (for blockade detection)
  getBlockades: (
    state: LudoState,
    colorMap: Record<string, PlayerColor>
  ): Map<number, Map<PlayerColor, number>> => {
    const blockades = new Map<number, Map<PlayerColor, number>>();
    Object.entries(state.pieces).forEach(([uid, playerPieces]) => {
      const color = colorMap[uid];
      if (!color) return;
      playerPieces.forEach((pos) => {
        if (pos >= 0 && pos <= 50) {
          const absPos = LudoEngine.getAbsolutePosition(color, pos);
          if (!blockades.has(absPos)) {
            blockades.set(absPos, new Map());
          }
          const posMap = blockades.get(absPos)!;
          posMap.set(color, (posMap.get(color) || 0) + 1);
        }
      });
    });
    return blockades;
  },

  // Apply a move and return the new state, completely immutable
  applyMove: (
    state: LudoState,
    uid: string,
    pieceIndex: number,
    colorMap: Record<string, PlayerColor>
  ): LudoState => {
    const diceValue = state?.dice?.value;
    if (!diceValue) throw new Error("No dice rolled");

    // Deep copy of pieces array to ensure true immutability for React state
    const newState: LudoState = {
      ...state,
      pieces: Object.fromEntries(
        Object.entries(state.pieces).map(([k, v]) => [k, [...v] as [number, number, number, number]])
      ),
    };

    const playerPieces = newState.pieces[uid];
    const currentPos = playerPieces[pieceIndex];

    if (!LudoEngine.isValidMove(currentPos, diceValue)) {
      throw new Error("Invalid move");
    }

    const myColor = colorMap[uid];

    // Blockade check
    if (myColor && LudoEngine.isPathBlocked(currentPos, diceValue, myColor, newState, colorMap)) {
      throw new Error("Path is blocked by an enemy blockade");
    }

    const newPos = currentPos === -1 ? 0 : currentPos + diceValue;
    playerPieces[pieceIndex] = newPos;

    let captured = false;

    // Check for captures on main track
    if (newPos >= 0 && newPos <= 50) {
      const myAbsPos = LudoEngine.getAbsolutePosition(myColor, newPos);
      
      if (!LudoEngine.SAFE_ZONES.has(myAbsPos)) {
        // Check for blockades before capturing
        const blockades = LudoEngine.getBlockades(newState, colorMap);
        const posMap = blockades.get(myAbsPos);
        
        // A blockade exists if any ENEMY color has 2+ pieces on this square
        let enemyHasBlockade = false;
        if (posMap) {
          posMap.forEach((count, color) => {
            if (color !== myColor && count >= 2) {
              enemyHasBlockade = true;
            }
          });
        }
        
        if (!enemyHasBlockade) {
          Object.entries(newState.pieces).forEach(([otherUid, otherPieces]) => {
            if (otherUid === uid) return;
            const otherColor = colorMap[otherUid];
            if (!otherColor) return;

            otherPieces.forEach((otherPos, otherIdx) => {
              if (otherPos >= 0 && otherPos <= 50) {
                const otherAbsPos = LudoEngine.getAbsolutePosition(otherColor, otherPos);
                if (otherAbsPos === myAbsPos) {
                  // Capture piece
                  otherPieces[otherIdx] = -1;
                  captured = true;
                }
              }
            });
          });
        }
      }
    }

    // Check Win Condition
    const hasWon = playerPieces.every((p) => p === 56);
    if (hasWon) {
      newState.winner = uid;
    }

    // Turn logic
    const isSix = diceValue === 6;
    let extraTurn = isSix || captured || newPos === 56;

    // Clear dice
    newState.dice = { value: null, rolledBy: null, rolledAt: null };

    if (!extraTurn && !hasWon) {
      newState.currentTurnIndex = (newState.currentTurnIndex + 1) % newState.turnOrder.length;
    }

    newState.version = (newState.version || 0) + 1;
    return newState;
  }
};

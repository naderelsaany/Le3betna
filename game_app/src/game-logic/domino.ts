export interface DominoPiece {
  id: number;
  left: number;
  right: number;
  isDouble: boolean;
}

export interface DominoState {
  turnOrder: string[];
  currentTurnIndex: number;
  hands: Record<string, number[]>;
  chain: {
    pieces: { pieceId: number; displayLeft?: number; displayRight?: number; flipped?: boolean; isDouble: boolean }[];
    leftEnd: number | null;
    rightEnd: number | null;
  };
  consecutivePasses: number;
  scores: Record<string, number>;
  targetScore: number;
  roundWinner: string | null;
  gameWinner: string | null;
  version: number;
  isFirstMoveOfRound: boolean;
  boneyard: number[];
  needsInitialization?: boolean;
}

// Generate the standard Double-Six domino set
const DOMINO_SET: DominoPiece[] = [];
let idCounter = 0;
for (let i = 0; i <= 6; i++) {
  for (let j = i; j <= 6; j++) {
    DOMINO_SET.push({
      id: idCounter++,
      left: i,
      right: j,
      isDouble: i === j,
    });
  }
}

export const DominoEngine = {
  getPieceById(id: number): DominoPiece {
    return DOMINO_SET[id];
  },

  getAllPieces(): DominoPiece[] {
    return DOMINO_SET;
  },

  // Shuffle array (Fisher-Yates)
  shuffle<T>(array: T[]): T[] {
    const arr = [...array];
    for (let i = arr.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [arr[i], arr[j]] = [arr[j], arr[i]];
    }
    return arr;
  },

  // Initial state setup for a new game
  createInitialState(turnOrder: string[], targetScore: number): DominoState {
    const scores: Record<string, number> = {};
    turnOrder.forEach((uid) => (scores[uid] = 0));
    
    const state: DominoState = {
      turnOrder,
      currentTurnIndex: 0,
      hands: {},
      chain: { pieces: [], leftEnd: null, rightEnd: null },
      consecutivePasses: 0,
      scores,
      targetScore,
      roundWinner: null,
      gameWinner: null,
      version: 1,
      isFirstMoveOfRound: true,
      boneyard: [],
    };
    return this.dealNewRound(state, null);
  },

  // Deal hands for a new round
  dealNewRound(state: DominoState, winnerOfLastRound: string | null): DominoState {
    const newState = {
      ...state,
      scores: { ...state.scores },
      turnOrder: [...state.turnOrder]
    };
    
    const shuffledIds = this.shuffle(DOMINO_SET.map(p => p.id));
    const hands: Record<string, number[]> = {};
    
    newState.turnOrder.forEach((uid, index) => {
      // 7 pieces per player
      hands[uid] = shuffledIds.slice(index * 7, (index + 1) * 7);
    });

    newState.hands = hands;
    newState.boneyard = shuffledIds.slice(newState.turnOrder.length * 7);
    newState.chain = { pieces: [], leftEnd: null, rightEnd: null };
    newState.consecutivePasses = 0;
    newState.roundWinner = null;
    newState.isFirstMoveOfRound = true;

    // Determine who starts
    if (winnerOfLastRound && newState.turnOrder.includes(winnerOfLastRound)) {
      newState.currentTurnIndex = newState.turnOrder.indexOf(winnerOfLastRound);
    } else {
      // Find player with highest double, or highest piece
      let highestDouble = -1;
      let highestDoublePlayer = 0;
      let highestPieceValue = -1;
      let highestPiecePlayer = 0;

      newState.turnOrder.forEach((uid, index) => {
        hands[uid].forEach(pieceId => {
          const piece = DOMINO_SET[pieceId];
          const val = piece.left + piece.right;
          if (piece.isDouble && piece.left > highestDouble) {
            highestDouble = piece.left;
            highestDoublePlayer = index;
          }
          if (val > highestPieceValue) {
            highestPieceValue = val;
            highestPiecePlayer = index;
          }
        });
      });

      newState.currentTurnIndex = highestDouble > -1 ? highestDoublePlayer : highestPiecePlayer;
    }

    newState.version++;
    return newState;
  },

  getValidMoves(handIds: number[], chain: DominoState['chain'], isFirstMove: boolean): number[] {
    const pieces = chain?.pieces || [];
    if (pieces.length === 0) {
      if (isFirstMove) {
        // If it's the very first move of the round, typically they should play their highest double
        // But for simplicity and flexibility, we allow playing any piece if the board is empty.
        // Some strict Egyptian rules say MUST play the highest double if you have one.
        // Let's enforce it: find max double in hand.
        let maxDouble = -1;
        let maxDoubleId = -1;
        handIds.forEach(id => {
          const p = DOMINO_SET[id];
          if (p.isDouble && p.left > maxDouble) {
            maxDouble = p.left;
            maxDoubleId = id;
          }
        });
        if (maxDoubleId !== -1) {
          return [maxDoubleId]; // Must play highest double
        }
        return handIds; // Can play anything if no doubles
      }
      return handIds;
    }

    return handIds.filter(id => {
      const p = DOMINO_SET[id];
      return p.left === chain.leftEnd || p.right === chain.leftEnd || 
             p.left === chain.rightEnd || p.right === chain.rightEnd;
    });
  },

  // side: 'left' | 'right'
  placePiece(state: DominoState, uid: string, pieceId: number, side: 'left' | 'right'): DominoState {
    const chainPieces = state.chain?.pieces || [];
    const newState = {
      ...state,
      hands: Object.keys(state.hands).reduce((acc, k) => {
        acc[k] = [...state.hands[k]];
        return acc;
      }, {} as Record<string, number[]>),
      chain: {
        ...state.chain,
        pieces: [...chainPieces]
      },
      scores: { ...state.scores }
    };
    
    // Security Check: Verify player owns the piece
    if (!newState.hands[uid].includes(pieceId)) {
      throw new Error("Player does not own this piece");
    }

    // Security Check: Verify it is a valid move
    const validMoves = this.getValidMoves(newState.hands[uid], newState.chain, newState.isFirstMoveOfRound);
    if (!validMoves.includes(pieceId)) {
      throw new Error("Invalid move");
    }
    
    // Remove from hand
    newState.hands[uid] = newState.hands[uid].filter(id => id !== pieceId);
    
    const piece = DOMINO_SET[pieceId];

    // Side placement check (ensure piece actually matches the end it's being placed on)
    if (newState.chain.pieces.length > 0) {
      if (side === 'left') {
        if (piece.left !== newState.chain.leftEnd && piece.right !== newState.chain.leftEnd) {
          throw new Error("Piece does not match the left end of the chain");
        }
      } else {
        if (piece.left !== newState.chain.rightEnd && piece.right !== newState.chain.rightEnd) {
          throw new Error("Piece does not match the right end of the chain");
        }
      }
    }
    
    if (newState.chain.pieces.length === 0) {
      // First piece on board — display as-is
      newState.chain.pieces.push({ pieceId, displayLeft: piece.left, displayRight: piece.right, isDouble: piece.isDouble });
      newState.chain.leftEnd = piece.left;
      newState.chain.rightEnd = piece.right;
    } else {
      if (side === 'left') {
        // Placing on LEFT: the piece's inner end must match chain.leftEnd
        // Result: [displayLeft | displayRight=chain.leftEnd] → [chain...]
        let displayLeft: number, displayRight: number;
        if (piece.right === newState.chain.leftEnd) {
          // piece.right connects → no flip needed
          displayLeft = piece.left;
          displayRight = piece.right;
        } else {
          // piece.left connects → swap display
          displayLeft = piece.right;
          displayRight = piece.left;
        }
        newState.chain.leftEnd = displayLeft;
        newState.chain.pieces.unshift({ pieceId, displayLeft, displayRight, isDouble: piece.isDouble });
      } else {
        // Placing on RIGHT: the piece's inner end must match chain.rightEnd
        // Result: [...chain] → [displayLeft=chain.rightEnd | displayRight]
        let displayLeft: number, displayRight: number;
        if (piece.left === newState.chain.rightEnd) {
          // piece.left connects → no flip needed
          displayLeft = piece.left;
          displayRight = piece.right;
        } else {
          // piece.right connects → swap display
          displayLeft = piece.right;
          displayRight = piece.left;
        }
        newState.chain.rightEnd = displayRight;
        newState.chain.pieces.push({ pieceId, displayLeft, displayRight, isDouble: piece.isDouble });
      }
    }

    newState.consecutivePasses = 0;
    newState.isFirstMoveOfRound = false;
    
    // Check if player won the round (empty hand)
    if (newState.hands[uid].length === 0) {
      return this.handleRoundEnd(newState, uid);
    }

    newState.currentTurnIndex = (newState.currentTurnIndex + 1) % newState.turnOrder.length;
    newState.version++;
    return newState;
  },

  passTurn(state: DominoState, uid: string): DominoState {
    const newState = {
      ...state,
      hands: Object.keys(state.hands).reduce((acc, k) => {
        acc[k] = [...state.hands[k]];
        return acc;
      }, {} as Record<string, number[]>),
      scores: { ...state.scores },
      chain: {
        ...state.chain,
        pieces: [...(state.chain?.pieces || [])]
      }
    };
    newState.consecutivePasses++;
    
    // Check for Block (قفلة) - if all players passed
    if (newState.consecutivePasses >= newState.turnOrder.length) {
      return this.handleRoundEnd(newState, null);
    }

    newState.currentTurnIndex = (newState.currentTurnIndex + 1) % newState.turnOrder.length;
    newState.version++;
    return newState;
  },

  drawPiece(state: DominoState, uid: string): DominoState {
    const newState = {
      ...state,
      hands: Object.keys(state.hands).reduce((acc, k) => {
        acc[k] = [...state.hands[k]];
        return acc;
      }, {} as Record<string, number[]>),
      boneyard: [...state.boneyard],
      chain: {
        ...state.chain,
        pieces: [...(state.chain?.pieces || [])]
      },
      scores: { ...state.scores }
    };
    
    // Ensure boneyard has pieces. According to some strict Egyptian rules, leave 2 pieces.
    // For wider compatibility, we just allow drawing until empty.
    if (!newState.boneyard || newState.boneyard.length === 0) {
      return newState;
    }

    const drawnId = newState.boneyard.shift()!;
    newState.hands[uid] = [...newState.hands[uid], drawnId];
    
    // reset passes because drawing changes the state
    newState.consecutivePasses = 0;
    newState.version++;
    
    return newState;
  },

  // Calculate points and handle winner
  handleRoundEnd(state: DominoState, winnerUid: string | null): DominoState {
    const newState = { ...state, scores: { ...state.scores } };
    const isTeamGame = newState.turnOrder.length === 4;

    // Calculate sum of pieces for each player
    const handSums: Record<string, number> = {};
    newState.turnOrder.forEach(u => {
      handSums[u] = newState.hands[u].reduce((sum, id) => {
        const p = DOMINO_SET[id];
        return sum + p.left + p.right;
      }, 0);
    });

    let pointsGained = 0;
    let winningTeamUids: string[] = [];

    if (winnerUid) {
      // A player finished their hand
      winningTeamUids = isTeamGame 
        ? [winnerUid, newState.turnOrder[(newState.turnOrder.indexOf(winnerUid) + 2) % 4]]
        : [winnerUid];
      
      // Points = sum of opponent's pieces
      newState.turnOrder.forEach(u => {
        if (!winningTeamUids.includes(u)) {
          pointsGained += handSums[u];
        }
      });
      newState.roundWinner = winnerUid;
    } else {
      // Block (قفلة)
      // Find team with lowest sum
      let minSum = Infinity;
      
      if (isTeamGame) {
        const team1Sum = handSums[newState.turnOrder[0]] + handSums[newState.turnOrder[2]];
        const team2Sum = handSums[newState.turnOrder[1]] + handSums[newState.turnOrder[3]];
        
        if (team1Sum < team2Sum) {
          winningTeamUids = [newState.turnOrder[0], newState.turnOrder[2]];
          pointsGained = team2Sum - team1Sum;
          newState.roundWinner = newState.turnOrder[0]; // just as a marker
        } else if (team2Sum < team1Sum) {
          winningTeamUids = [newState.turnOrder[1], newState.turnOrder[3]];
          pointsGained = team1Sum - team2Sum;
          newState.roundWinner = newState.turnOrder[1];
        } else {
          // Tie in block -> no points usually, or just declare it a tie round
          pointsGained = 0;
          newState.roundWinner = 'tie';
        }
      } else {
        // Non-team game (2, 3, etc. players)
        // Find player with the lowest score
        let minSum = Infinity;
        let winners: string[] = [];
        
        newState.turnOrder.forEach(u => {
          const sum = handSums[u] || 0;
          if (sum < minSum) {
            minSum = sum;
            winners = [u];
          } else if (sum === minSum) {
            winners.push(u);
          }
        });
        
        if (winners.length > 1) {
          // Tie -> no points, round is a tie
          pointsGained = 0;
          newState.roundWinner = 'tie';
        } else {
          const blockWinner = winners[0];
          winningTeamUids = [blockWinner];
          // Winner gets points equal to the sum of all other players' hand sums
          pointsGained = newState.turnOrder.reduce((sum, u) => {
            return u !== blockWinner ? sum + handSums[u] : sum;
          }, 0);
          newState.roundWinner = blockWinner;
        }
      }
    }

    // Add points to winners
    winningTeamUids.forEach(u => {
      newState.scores[u] += pointsGained;
    });

    // Check game over
    let gameWinner: string | null = null;
    winningTeamUids.forEach(u => {
      if (newState.scores[u] >= newState.targetScore) {
        gameWinner = u;
      }
    });

    if (gameWinner) {
      newState.gameWinner = gameWinner;
    }

    newState.version++;
    return newState;
  }
};

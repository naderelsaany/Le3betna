export type Player = 1 | 2;
export type Cell = Player | 0;
export type Board = Cell[][];

export class Connect4Engine {
  static readonly ROWS = 6;
  static readonly COLS = 7;

  /**
   * Creates an empty Connect 4 board (6 rows x 7 cols)
   */
  static createEmptyBoard(): Board {
    return Array.from({ length: this.ROWS }, () => Array(this.COLS).fill(0));
  }

  /**
   * Drops a piece into the specified column.
   * Returns a NEW board array to avoid mutating the original (important for React/State).
   * Throws an error if the column is full or invalid.
   */
  static dropPiece(board: Board, col: number, player: Player): Board {
    if (col < 0 || col >= this.COLS) {
      throw new Error("Invalid column");
    }

    const newBoard = board.map((row) => [...row]); // Deep copy of rows

    for (let row = this.ROWS - 1; row >= 0; row--) {
      if (newBoard[row][col] === 0) {
        newBoard[row][col] = player;
        return newBoard;
      }
    }

    throw new Error("Column is full");
  }

  /**
   * Checks if there's a winner on the board.
   * Returns Player 1 | 2 if someone won, otherwise null.
   */
  static checkWinner(board: Board): Player | null {
    // Check horizontal
    for (let r = 0; r < this.ROWS; r++) {
      for (let c = 0; c <= this.COLS - 4; c++) {
        const cell = board[r][c];
        if (
          cell !== 0 &&
          cell === board[r][c + 1] &&
          cell === board[r][c + 2] &&
          cell === board[r][c + 3]
        ) {
          return cell as Player;
        }
      }
    }

    // Check vertical
    for (let c = 0; c < this.COLS; c++) {
      for (let r = 0; r <= this.ROWS - 4; r++) {
        const cell = board[r][c];
        if (
          cell !== 0 &&
          cell === board[r + 1][c] &&
          cell === board[r + 2][c] &&
          cell === board[r + 3][c]
        ) {
          return cell as Player;
        }
      }
    }

    // Check diagonal (bottom-left to top-right)
    for (let r = 3; r < this.ROWS; r++) {
      for (let c = 0; c <= this.COLS - 4; c++) {
        const cell = board[r][c];
        if (
          cell !== 0 &&
          cell === board[r - 1][c + 1] &&
          cell === board[r - 2][c + 2] &&
          cell === board[r - 3][c + 3]
        ) {
          return cell as Player;
        }
      }
    }

    // Check diagonal (top-left to bottom-right)
    for (let r = 0; r <= this.ROWS - 4; r++) {
      for (let c = 0; c <= this.COLS - 4; c++) {
        const cell = board[r][c];
        if (
          cell !== 0 &&
          cell === board[r + 1][c + 1] &&
          cell === board[r + 2][c + 2] &&
          cell === board[r + 3][c + 3]
        ) {
          return cell as Player;
        }
      }
    }

    return null;
  }

  /**
   * Checks if the board is completely full without a winner (Draw).
   */
  static isDraw(board: Board): boolean {
    return board[0].every((cell) => cell !== 0);
  }
}

import { Connect4Engine, Player } from "./connect4";

function runTests() {
  console.log("Running Connect 4 Engine Tests...");
  let passed = 0;
  let failed = 0;

  const assert = (condition: boolean, message: string) => {
    if (condition) {
      passed++;
      console.log(`✅ PASS: ${message}`);
    } else {
      failed++;
      console.error(`❌ FAIL: ${message}`);
    }
  };

  // Test 1: Empty board
  let board = Connect4Engine.createEmptyBoard();
  assert(board.length === 6 && board[0].length === 7, "Board should be 6x7");

  // Test 2: Drop piece logic (gravity)
  board = Connect4Engine.dropPiece(board, 0, 1);
  assert(board[5][0] === 1, "Piece should drop to the very bottom (row 5)");
  assert(board[4][0] === 0, "Row above should be empty");

  // Test 3: Drop piece on top of another
  board = Connect4Engine.dropPiece(board, 0, 2);
  assert(board[4][0] === 2, "Piece should stack on top of the previous one (row 4)");

  // Test 4: Horizontal Win
  let hBoard = Connect4Engine.createEmptyBoard();
  hBoard = Connect4Engine.dropPiece(hBoard, 0, 1);
  hBoard = Connect4Engine.dropPiece(hBoard, 1, 1);
  hBoard = Connect4Engine.dropPiece(hBoard, 2, 1);
  assert(Connect4Engine.checkWinner(hBoard) === null, "Should be no winner yet (3 in a row)");
  hBoard = Connect4Engine.dropPiece(hBoard, 3, 1);
  assert(Connect4Engine.checkWinner(hBoard) === 1, "Player 1 should win horizontally");

  // Test 5: Full column throw error
  let fullColBoard = Connect4Engine.createEmptyBoard();
  for (let i = 0; i < 6; i++) {
    fullColBoard = Connect4Engine.dropPiece(fullColBoard, 3, i % 2 === 0 ? 1 : 2);
  }
  let threwError = false;
  try {
    Connect4Engine.dropPiece(fullColBoard, 3, 1);
  } catch (e) {
    threwError = true;
  }
  assert(threwError, "Should throw error when dropping in a full column");

  console.log(`\nTests Completed: ${passed} Passed, ${failed} Failed.`);
}

runTests();

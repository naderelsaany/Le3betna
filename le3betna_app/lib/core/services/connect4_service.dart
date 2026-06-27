import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Connect4Service {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  StreamSubscription? _hostSubscription;

  // 1. Initialize Game
  Future<void> initializeGame(String roomCode, String hostUid, String guestUid) async {
    // Create empty 6x7 grid (6 rows, 7 columns). 0 = empty, 1 = player1 (host), 2 = player2 (guest)
    List<List<int>> grid = List.generate(6, (_) => List.generate(7, (_) => 0));

    Map<String, dynamic> gameState = {
      'grid': grid,
      'turn': hostUid, // Host starts
      'status': 'playing', // playing, finished
      'winner': null,
      'player1': hostUid,
      'player2': guestUid,
      'lastMoveId': null,
    };

    await _db.child('rooms').child(roomCode).update({
      'status': 'playing',
      'gameState': gameState,
    });
  }

  // 2. Client pushes a move
  Future<void> dropToken(String roomCode, int col) async {
    await _db.child('rooms').child(roomCode).child('moves').push().set({
      'uid': _uid,
      'col': col,
      'timestamp': ServerValue.timestamp,
    });
  }

  // 3. Host Engine to process moves
  void startHostEngine(String roomCode) {
    _hostSubscription?.cancel();
    _hostSubscription = _db.child('rooms').child(roomCode).child('moves').onChildAdded.listen((event) async {
      final moveId = event.snapshot.key;
      if (moveId == null || event.snapshot.value == null) return;
      
      final move = event.snapshot.value as Map<dynamic, dynamic>;
      final uid = move['uid'];
      final col = move['col'];
      
      final roomRef = _db.child('rooms').child(roomCode).child('gameState');

      await roomRef.runTransaction((Object? gameState) {
        if (gameState == null) return Transaction.success(gameState);

        Map<dynamic, dynamic> state = Map<dynamic, dynamic>.from(gameState as Map);
        
        // Prevent reprocessing the same move
        if (state['lastMoveId'] == moveId) {
          return Transaction.success(state);
        }

        if (state['status'] != 'playing' || state['turn'] != uid) {
          return Transaction.success(state); // Not your turn or game over
        }

        List<dynamic> rawGrid = List.from(state['grid']);
        List<List<int>> grid = rawGrid.map((r) => List<int>.from(r)).toList();

        int playerNum = state['player1'] == uid ? 1 : 2;
        String opponentUid = state['player1'] == uid ? state['player2'] : state['player1'];

        // Find lowest empty row in the column
        int targetRow = -1;
        for (int r = 5; r >= 0; r--) {
          if (grid[r][col] == 0) {
            targetRow = r;
            break;
          }
        }

        if (targetRow == -1) {
          // Column is full
          return Transaction.success(state);
        }

        // Drop token
        grid[targetRow][col] = playerNum;
        state['grid'] = grid;
        state['lastMoveId'] = moveId; // Mark move as processed

        // Check win
        if (_checkWin(grid, targetRow, col, playerNum)) {
          state['status'] = 'finished';
          state['winner'] = uid;
        } else if (_checkDraw(grid)) {
          state['status'] = 'finished';
          state['winner'] = 'draw';
        } else {
          // Switch turn
          state['turn'] = opponentUid;
        }

        return Transaction.success(state);
      });
    });
  }

  void stopHostEngine() {
    _hostSubscription?.cancel();
    _hostSubscription = null;
  }

  bool _checkWin(List<List<int>> grid, int r, int c, int player) {
    int countDirection(int rDelta, int cDelta) {
      int count = 0;
      int currR = r + rDelta;
      int currC = c + cDelta;
      while (currR >= 0 && currR < 6 && currC >= 0 && currC < 7 && grid[currR][currC] == player) {
        count++;
        currR += rDelta;
        currC += cDelta;
      }
      return count;
    }

    // Horizontal
    if (countDirection(0, -1) + countDirection(0, 1) >= 3) return true;
    // Vertical
    if (countDirection(-1, 0) + countDirection(1, 0) >= 3) return true;
    // Diagonal \
    if (countDirection(-1, -1) + countDirection(1, 1) >= 3) return true;
    // Diagonal /
    if (countDirection(1, -1) + countDirection(-1, 1) >= 3) return true;

    return false;
  }

  bool _checkDraw(List<List<int>> grid) {
    for (int c = 0; c < 7; c++) {
      if (grid[0][c] == 0) return false;
    }
    return true;
  }
}

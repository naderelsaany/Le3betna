import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class Connect4Service {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. Initialize Game
  Future<void> initializeGame(String roomCode, String hostUid, String guestUid) async {
    List<List<int>> grid = List.generate(6, (_) => List.generate(7, (_) => 0));

    Map<String, dynamic> gameState = {
      'grid': grid,
      'turn': hostUid, // Host starts
      'status': 'playing',
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

  // 2. Client-Driven Move
  Future<void> dropToken(String roomCode, int col) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    
    await roomRef.runTransaction((Object? post) {
      if (post == null) {
        return Transaction.success(post);
      }

      Map<String, dynamic> state = Map<String, dynamic>.from(post as Map);

      if (state['status'] != 'playing' || state['turn'] != _uid) {
        return Transaction.abort(); // Not your turn or game over
      }

      List<dynamic> rawGrid = List.from(state['grid']);
      List<List<int>> grid = rawGrid.map((r) => (r as List).map((e) => (e as num).toInt()).toList()).toList();

      int playerNum = state['player1'] == _uid ? 1 : 2;
      String opponentUid = state['player1'] == _uid ? state['player2'] : state['player1'];

      int targetRow = -1;
      for (int r = 5; r >= 0; r--) {
        if (grid[r][col] == 0) {
          targetRow = r;
          break;
        }
      }

      if (targetRow == -1) return Transaction.abort(); // Column full

      grid[targetRow][col] = playerNum;
      state['grid'] = grid;

      if (_checkWin(grid, targetRow, col, playerNum)) {
        state['status'] = 'finished';
        state['winner'] = _uid;
      } else if (_checkDraw(grid)) {
        state['status'] = 'finished';
        state['winner'] = 'draw';
      } else {
        // Switch turn
        state['turn'] = opponentUid;
      }
      
      print('DEBUG: Turn switched to ${state['turn']}');
      return Transaction.success(state);
    });
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

    if (countDirection(0, -1) + countDirection(0, 1) >= 3) return true;
    if (countDirection(-1, 0) + countDirection(1, 0) >= 3) return true;
    if (countDirection(-1, -1) + countDirection(1, 1) >= 3) return true;
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

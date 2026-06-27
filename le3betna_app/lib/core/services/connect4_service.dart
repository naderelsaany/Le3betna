import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Connect4Service {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> initializeGame(String roomCode, String hostUid, String guestUid) async {
    print('DEBUG CLEAN: initializeGame called for room: $roomCode');
    
    // Create a strict 6x7 grid of zeros
    List<List<int>> grid = List.generate(6, (_) => List.generate(7, (_) => 0));

    Map<String, dynamic> gameState = {
      'grid': grid,
      'turn': hostUid, // Host always starts
      'status': 'playing',
      'winner': null,
      'player1': hostUid,
      'player2': guestUid,
      'debugLog': 'Game Initialized',
    };

    await _db.child('rooms').child(roomCode).update({
      'status': 'playing',
      'gameState': gameState,
    });
    
    print('DEBUG CLEAN: Game initialized successfully. First turn: $hostUid');
  }

  Future<void> dropToken(String roomCode, int col) async {
    print('DEBUG CLEAN: dropToken called for col: $col');
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    
    await roomRef.runTransaction((Object? post) {
      print('DEBUG CLEAN: Inside runTransaction start');
      if (post == null) {
        print('DEBUG CLEAN: Post is null, aborting transaction');
        return Transaction.abort();
      }

      Map<String, dynamic> state = Map<String, dynamic>.from(post as Map);

      if (state['status'] != 'playing') {
        print('DEBUG CLEAN: Game is not playing (status=${state['status']}), aborting');
        return Transaction.abort();
      }
      if (state['turn'] != _uid) {
        print('DEBUG CLEAN: Not my turn (turn=${state['turn']}, myUid=$_uid), aborting');
        return Transaction.abort();
      }

      // Safe array parsing
      List<dynamic> rawGrid = _parseFirebaseArray(state['grid']);
      List<List<int>> grid = rawGrid.map((r) {
        final row = _parseFirebaseArray(r);
        return row.map((e) => (e as num).toInt()).toList();
      }).toList();

      int playerNum = state['player1'] == _uid ? 1 : 2;
      String opponentUid = state['player1'] == _uid ? state['player2'] : state['player1'];

      // Find lowest empty row in column
      int targetRow = -1;
      for (int r = 5; r >= 0; r--) {
        if (grid[r][col] == 0) {
          targetRow = r;
          break;
        }
      }

      if (targetRow == -1) {
        print('DEBUG CLEAN: Column $col is full, aborting');
        return Transaction.abort();
      }

      print('DEBUG CLEAN: Placing token for Player $playerNum at [$targetRow, $col]');
      grid[targetRow][col] = playerNum;
      state['grid'] = grid;

      // Check win condition
      if (_checkWin(grid, playerNum)) {
        print('DEBUG CLEAN: WIN DETECTED for $_uid!');
        state['status'] = 'finished';
        state['winner'] = _uid;
      } else if (_checkDraw(grid)) {
        print('DEBUG CLEAN: DRAW DETECTED!');
        state['status'] = 'finished';
        state['winner'] = 'draw';
      } else {
        // Change turn
        print('DEBUG CLEAN: Turn changing from $_uid to $opponentUid');
        state['turn'] = opponentUid;
      }
      
      state['debugLog'] = 'Last move by Player $playerNum in col $col';

      print('DEBUG CLEAN: runTransaction success payload ready');
      return Transaction.success(state);
    });
  }

  // Safe parsing array logic
  List<dynamic> _parseFirebaseArray(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return List<dynamic>.from(value.where((e) => e != null));
    }
    if (value is Map) {
      final keys = value.keys.toList()..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));
      return keys.map((k) => value[k]).where((e) => e != null).toList();
    }
    return [];
  }

  // Simple brute-force win checker
  bool _checkWin(List<List<int>> grid, int player) {
    // Horizontal
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player && grid[r][c+1] == player && grid[r][c+2] == player && grid[r][c+3] == player) return true;
      }
    }
    // Vertical
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 7; c++) {
        if (grid[r][c] == player && grid[r+1][c] == player && grid[r+2][c] == player && grid[r+3][c] == player) return true;
      }
    }
    // Diagonal (down-right)
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player && grid[r+1][c+1] == player && grid[r+2][c+2] == player && grid[r+3][c+3] == player) return true;
      }
    }
    // Diagonal (up-right)
    for (int r = 3; r < 6; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player && grid[r-1][c+1] == player && grid[r-2][c+2] == player && grid[r-3][c+3] == player) return true;
      }
    }
    return false;
  }

  bool _checkDraw(List<List<int>> grid) {
    for (int c = 0; c < 7; c++) {
      if (grid[0][c] == 0) return false;
    }
    return true;
  }
}

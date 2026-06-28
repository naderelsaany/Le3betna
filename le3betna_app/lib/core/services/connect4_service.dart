import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Connect4Service {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> initializeGame(String roomCode, String hostUid, String guestUid) async {
    print('DEBUG C4: initializeGame called for room: $roomCode');
    
    // Create a strict 6x7 grid of zeros
    List<List<int>> grid = List.generate(6, (_) => List.generate(7, (_) => 0));

    Map<String, dynamic> gameState = {
      'grid': grid,
      'turn': hostUid,
      'status': 'playing',
      'winner': '',
      'player1': hostUid,
      'player2': guestUid,
      'debugLog': 'Game Initialized. Host=$hostUid Guest=$guestUid',
      'moveCount': 0,
    };

    await _db.child('rooms').child(roomCode).update({
      'status': 'playing',
      'gameState': gameState,
    });
    
    print('DEBUG C4: Game initialized successfully. First turn: $hostUid');
  }

  Future<void> dropToken(String roomCode, int col) async {
    print('DEBUG C4: dropToken called for col: $col, uid: $_uid');
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    
    final result = await roomRef.runTransaction((Object? post) {
      if (post == null) {
        print('DEBUG C4: Transaction post is NULL — aborting');
        return Transaction.abort();
      }

      Map<String, dynamic> state = Map<String, dynamic>.from(post as Map);

      if (state['status'] != 'playing') {
        return Transaction.abort();
      }
      if (state['turn'] != _uid) {
        print('DEBUG C4: Not my turn. turn=${state['turn']} me=$_uid');
        return Transaction.abort();
      }

      // SAFE grid parsing — preserve all elements including zeros
      List<List<int>> grid = _parseGrid(state['grid']);
      
      // Validate grid dimensions
      if (grid.length != 6 || grid.any((row) => row.length != 7)) {
        print('DEBUG C4: Grid dimensions invalid: ${grid.length}x${grid.isEmpty ? 0 : grid[0].length}');
        return Transaction.abort();
      }

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
        return Transaction.abort();
      }

      grid[targetRow][col] = playerNum;
      state['grid'] = grid.map((row) => row.toList()).toList();

      int moveCount = (state['moveCount'] ?? 0) as int;
      moveCount++;
      state['moveCount'] = moveCount;

      // Check win condition
      if (_checkWin(grid, playerNum)) {
        state['status'] = 'finished';
        state['winner'] = _uid;
        state['debugLog'] = 'WIN! P$playerNum col=$col move#$moveCount';
      } else if (_checkDraw(grid)) {
        state['status'] = 'finished';
        state['winner'] = 'draw';
        state['debugLog'] = 'DRAW at move#$moveCount';
      } else {
        state['turn'] = opponentUid;
        state['debugLog'] = 'P$playerNum→col$col row$targetRow move#$moveCount';
      }

      return Transaction.success(state);
    });

    if (result.committed) {
      print('DEBUG C4: Transaction COMMITTED for col $col');
    } else {
      print('DEBUG C4: Transaction REJECTED for col $col');
    }
  }

  /// Safe grid parser that preserves zeros and handles Firebase quirks.
  /// Firebase may store arrays as Maps when some indices are missing,
  /// and may store all-zero arrays as null. This handles all cases.
  List<List<int>> _parseGrid(dynamic rawGrid) {
    if (rawGrid == null) {
      // Grid is null (shouldn't happen after init, but be safe)
      return List.generate(6, (_) => List.generate(7, (_) => 0));
    }

    List<dynamic> rows;
    if (rawGrid is List) {
      rows = rawGrid;
    } else if (rawGrid is Map) {
      // Firebase stored array as a Map {0: [...], 1: [...], ...}
      int maxIndex = 0;
      for (var key in rawGrid.keys) {
        int k = int.parse(key.toString());
        if (k > maxIndex) maxIndex = k;
      }
      rows = List.generate(maxIndex + 1, (i) => rawGrid[i] ?? rawGrid['$i']);
    } else {
      return List.generate(6, (_) => List.generate(7, (_) => 0));
    }

    // Parse each row
    List<List<int>> result = [];
    for (int r = 0; r < 6; r++) {
      if (r >= rows.length || rows[r] == null) {
        result.add(List.generate(7, (_) => 0));
        continue;
      }
      
      dynamic row = rows[r];
      List<int> parsedRow;
      
      if (row is List) {
        parsedRow = List.generate(7, (c) {
          if (c >= row.length || row[c] == null) return 0;
          return (row[c] as num).toInt();
        });
      } else if (row is Map) {
        parsedRow = List.generate(7, (c) {
          var val = row[c] ?? row['$c'];
          if (val == null) return 0;
          return (val as num).toInt();
        });
      } else {
        parsedRow = List.generate(7, (_) => 0);
      }
      
      result.add(parsedRow);
    }
    
    return result;
  }

  bool _checkWin(List<List<int>> grid, int player) {
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player && grid[r][c+1] == player && grid[r][c+2] == player && grid[r][c+3] == player) return true;
      }
    }
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 7; c++) {
        if (grid[r][c] == player && grid[r+1][c] == player && grid[r+2][c] == player && grid[r+3][c] == player) return true;
      }
    }
    for (int r = 0; r < 3; r++) {
      for (int c = 0; c < 4; c++) {
        if (grid[r][c] == player && grid[r+1][c+1] == player && grid[r+2][c+2] == player && grid[r+3][c+3] == player) return true;
      }
    }
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

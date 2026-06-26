import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/domino_models.dart';

class GameService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  // 1. Initialize Game (Only Host calls this)
  Future<void> initializeGame(String roomCode, String hostUid, String guestUid) async {
    // Generate 28 tiles
    List<DominoTile> allTiles = [];
    int idCounter = 0;
    for (int i = 0; i <= 6; i++) {
      for (int j = i; j <= 6; j++) {
        allTiles.add(DominoTile(value1: i, value2: j, id: 't_${idCounter++}'));
      }
    }

    // Shuffle
    allTiles.shuffle();

    // Deal 7 to each
    List<DominoTile> hostHand = allTiles.sublist(0, 7);
    List<DominoTile> guestHand = allTiles.sublist(7, 14);
    List<DominoTile> boneyard = allTiles.sublist(14);

    // Determine who starts
    String startingPlayerUid = _determineStartingPlayer(hostHand, guestHand, hostUid, guestUid);

    // Initial State
    Map<String, dynamic> gameState = {
      'board': [],
      'boneyard': boneyard.map((e) => e.toJson()).toList(),
      'hands': {
        hostUid: hostHand.map((e) => e.toJson()).toList(),
        guestUid: guestHand.map((e) => e.toJson()).toList(),
      },
      'turn': startingPlayerUid,
      'status': 'playing', // playing, finished
      'passCount': 0, // Track consecutive passes
      'scores': {
        hostUid: 0,
        guestUid: 0,
      }
    };

    // Update Room status to playing and set gameState
    await _db.child('rooms').child(roomCode).update({
      'status': 'playing',
      'gameState': gameState,
    });
  }

  String _determineStartingPlayer(List<DominoTile> hand1, List<DominoTile> hand2, String uid1, String uid2) {
    // Find highest double
    int highestDouble1 = -1;
    int highestDouble2 = -1;

    for (var t in hand1) {
      if (t.isDouble && t.value1 > highestDouble1) highestDouble1 = t.value1;
    }
    for (var t in hand2) {
      if (t.isDouble && t.value1 > highestDouble2) highestDouble2 = t.value1;
    }

    if (highestDouble1 > highestDouble2) return uid1;
    if (highestDouble2 > highestDouble1) return uid2;

    // If no doubles, find highest sum
    int highestSum1 = -1;
    int highestSum2 = -1;
    for (var t in hand1) {
      if (t.sum > highestSum1) highestSum1 = t.sum;
    }
    for (var t in hand2) {
      if (t.sum > highestSum2) highestSum2 = t.sum;
    }

    if (highestSum1 > highestSum2) return uid1;
    return uid2;
  }

  // 2. Play a tile
  Future<void> playTile({
    required String roomCode,
    required DominoTile tile,
    required bool reversed,
    required String opponentUid,
    required bool isLeft,
  }) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    
    // Using a transaction to ensure atomic updates
    await roomRef.runTransaction((Object? gameState) {
      if (gameState == null) return Transaction.success(gameState);

      Map<dynamic, dynamic> state = Map<dynamic, dynamic>.from(gameState as Map);
      
      // Update Board
      List<dynamic> board = List.from(state['board'] ?? []);
      Map<String, dynamic> playedTile = {'tile': tile.toJson(), 'reversed': reversed};
      
      if (isLeft) {
        board.insert(0, playedTile);
      } else {
        board.add(playedTile);
      }
      state['board'] = board;

      // Remove from Hand
      Map<dynamic, dynamic> hands = Map<dynamic, dynamic>.from(state['hands']);
      List<dynamic> myHand = List.from(hands[_uid]);
      myHand.removeWhere((t) => t['id'] == tile.id);
      hands[_uid] = myHand;
      state['hands'] = hands;

      // Reset pass count since a tile was played
      state['passCount'] = 0;

      // Check win condition
      if (myHand.isEmpty) {
        state['status'] = 'finished';
        // Calculate points
        List<dynamic> oppHand = List.from(hands[opponentUid]);
        int points = 0;
        for (var t in oppHand) {
          points += (t['value1'] as int) + (t['value2'] as int);
        }
        
        Map<dynamic, dynamic> scores = Map<dynamic, dynamic>.from(state['scores']);
        scores[_uid] = (scores[_uid] ?? 0) + points;
        state['scores'] = scores;
      } else {
        // Change turn
        state['turn'] = opponentUid;
      }

      return Transaction.success(state);
    });
  }

  // 3. Draw a tile
  Future<bool> drawTile(String roomCode) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    bool drew = false;

    await roomRef.runTransaction((Object? gameState) {
      if (gameState == null) return Transaction.success(gameState);

      Map<dynamic, dynamic> state = Map<dynamic, dynamic>.from(gameState as Map);
      List<dynamic> boneyard = List.from(state['boneyard'] ?? []);
      
      if (boneyard.isEmpty) return Transaction.success(state);

      Map<dynamic, dynamic> hands = Map<dynamic, dynamic>.from(state['hands']);
      List<dynamic> myHand = List.from(hands[_uid]);

      // Draw first tile
      myHand.add(boneyard.removeAt(0));
      hands[_uid] = myHand;
      
      state['boneyard'] = boneyard;
      state['hands'] = hands;
      
      drew = true;
      return Transaction.success(state);
    });
    return drew;
  }

  // 4. Pass turn (Khabbat)
  Future<void> passTurn(String roomCode, String opponentUid) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    
    await roomRef.runTransaction((Object? gameState) {
      if (gameState == null) return Transaction.success(gameState);

      Map<dynamic, dynamic> state = Map<dynamic, dynamic>.from(gameState as Map);
      int passCount = (state['passCount'] ?? 0) + 1;
      state['passCount'] = passCount;
      
      if (passCount >= 2) {
        // Game is blocked (القفلة)
        state['status'] = 'finished';
        
        Map<dynamic, dynamic> hands = Map<dynamic, dynamic>.from(state['hands']);
        List<dynamic> myHand = List.from(hands[_uid]);
        List<dynamic> oppHand = List.from(hands[opponentUid]);
        
        int mySum = myHand.fold(0, (sum, t) => sum + (t['value1'] as int) + (t['value2'] as int));
        int oppSum = oppHand.fold(0, (sum, t) => sum + (t['value1'] as int) + (t['value2'] as int));
        
        Map<dynamic, dynamic> scores = Map<dynamic, dynamic>.from(state['scores']);
        if (mySum < oppSum) {
          scores[_uid] = (scores[_uid] ?? 0) + oppSum;
        } else if (oppSum < mySum) {
          scores[opponentUid] = (scores[opponentUid] ?? 0) + mySum;
        }
        state['scores'] = scores;
      } else {
        state['turn'] = opponentUid;
      }
      
      return Transaction.success(state);
    });
  }
}

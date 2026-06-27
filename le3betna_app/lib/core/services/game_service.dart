import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/domino_models.dart';

class GameService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  StreamSubscription? _hostSubscription;

  // 1. Initialize Game (Only Host calls this)
  Future<void> initializeGame(String roomCode, String hostUid, String guestUid) async {
    List<DominoTile> allTiles = [];
    int idCounter = 0;
    for (int i = 0; i <= 6; i++) {
      for (int j = i; j <= 6; j++) {
        allTiles.add(DominoTile(value1: i, value2: j, id: 't_${idCounter++}'));
      }
    }
    allTiles.shuffle();

    List<DominoTile> hostHand = allTiles.sublist(0, 7);
    List<DominoTile> guestHand = allTiles.sublist(7, 14);
    List<DominoTile> boneyard = allTiles.sublist(14);

    String startingPlayerUid = _determineStartingPlayer(hostHand, guestHand, hostUid, guestUid);

    Map<String, dynamic> gameState = {
      'board': [],
      'boneyard': boneyard.map((e) => e.toJson()).toList(),
      'turn': startingPlayerUid,
      'status': 'playing',
      'passCount': 0,
      'lastMoveId': null,
      'scores': {
        hostUid: 0,
        guestUid: 0,
      },
      'handCounts': {
        hostUid: 7,
        guestUid: 7,
      },
      'player1': hostUid,
      'player2': guestUid,
    };

    Map<String, dynamic> hands = {
      hostUid: hostHand.map((e) => e.toJson()).toList(),
      guestUid: guestHand.map((e) => e.toJson()).toList(),
    };

    await _db.child('rooms').child(roomCode).update({
      'status': 'playing',
      'gameState': gameState,
      'hands': hands,
    });
  }

  String _determineStartingPlayer(List<DominoTile> hand1, List<DominoTile> hand2, String uid1, String uid2) {
    int highestDouble1 = -1, highestDouble2 = -1;
    for (var t in hand1) { if (t.isDouble && t.value1 > highestDouble1) highestDouble1 = t.value1; }
    for (var t in hand2) { if (t.isDouble && t.value1 > highestDouble2) highestDouble2 = t.value1; }

    if (highestDouble1 > highestDouble2) return uid1;
    if (highestDouble2 > highestDouble1) return uid2;

    int highestSum1 = -1, highestSum2 = -1;
    for (var t in hand1) { if (t.sum > highestSum1) highestSum1 = t.sum; }
    for (var t in hand2) { if (t.sum > highestSum2) highestSum2 = t.sum; }

    if (highestSum1 > highestSum2) return uid1;
    return uid2;
  }

  // 2. Client actions (Push to moves)
  Future<void> playTile({
    required String roomCode,
    required DominoTile tile,
    required bool reversed,
    required bool isLeft,
  }) async {
    await _db.child('rooms').child(roomCode).child('moves').push().set({
      'type': 'play',
      'uid': _uid,
      'tile': tile.toJson(),
      'reversed': reversed,
      'isLeft': isLeft,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> drawTile(String roomCode) async {
    await _db.child('rooms').child(roomCode).child('moves').push().set({
      'type': 'draw',
      'uid': _uid,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> passTurn(String roomCode) async {
    await _db.child('rooms').child(roomCode).child('moves').push().set({
      'type': 'pass',
      'uid': _uid,
      'timestamp': ServerValue.timestamp,
    });
  }

  // 3. Host Engine to process moves
  void startHostEngine(String roomCode) {
    _hostSubscription?.cancel();
    _hostSubscription = _db.child('rooms').child(roomCode).child('moves').orderByChild('timestamp').onChildAdded.listen((event) async {
      final moveId = event.snapshot.key;
      if (moveId == null || event.snapshot.value == null) return;
      
      final move = event.snapshot.value as Map<dynamic, dynamic>;
      final uid = move['uid'];
      
      // Fetch current state
      final roomSnap = await _db.child('rooms').child(roomCode).get();
      if (!roomSnap.exists) return;
      
      final roomData = roomSnap.value as Map<dynamic, dynamic>;
      final state = Map<String, dynamic>.from(roomData['gameState'] ?? {});
      final hands = Map<String, dynamic>.from(roomData['hands'] ?? {});
      
      if (state['lastMoveId'] == moveId) return; // Already processed
      if (state['status'] != 'playing' || state['turn'] != uid) return; // Invalid move

      final opponentUid = state['player1'] == uid ? state['player2'] : state['player1'];
      Map<String, dynamic> updates = {};

      String type = move['type'];
      
      if (type == 'play') {
        List<dynamic> board = List.from(state['board'] ?? []);
        Map<String, dynamic> playedTile = {'tile': move['tile'], 'reversed': move['reversed']};
        
        if (move['isLeft']) {
          board.insert(0, playedTile);
        } else {
          board.add(playedTile);
        }
        
        List<dynamic> myHand = List.from(hands[uid] ?? []);
        myHand.removeWhere((t) => t['id'] == move['tile']['id']);
        
        updates['gameState/board'] = board;
        updates['hands/$uid'] = myHand;
        updates['gameState/handCounts/$uid'] = myHand.length;
        updates['gameState/passCount'] = 0;
        
        if (myHand.isEmpty) {
          updates['gameState/status'] = 'finished';
          List<dynamic> oppHand = List.from(hands[opponentUid] ?? []);
          int points = oppHand.fold(0, (sum, t) => sum + (t['value1'] as int) + (t['value2'] as int));
          
          Map<String, dynamic> scores = Map<String, dynamic>.from(state['scores'] ?? {});
          scores[uid] = (scores[uid] ?? 0) + points;
          updates['gameState/scores'] = scores;
        } else {
          updates['gameState/turn'] = opponentUid;
        }
      } 
      else if (type == 'draw') {
        List<dynamic> boneyard = List.from(state['boneyard'] ?? []);
        if (boneyard.isNotEmpty) {
          List<dynamic> myHand = List.from(hands[uid] ?? []);
          myHand.add(boneyard.removeAt(0));
          
          updates['gameState/boneyard'] = boneyard;
          updates['hands/$uid'] = myHand;
          updates['gameState/handCounts/$uid'] = myHand.length;
        }
      }
      else if (type == 'pass') {
        int passCount = (state['passCount'] ?? 0) + 1;
        updates['gameState/passCount'] = passCount;
        
        if (passCount >= 2) {
          updates['gameState/status'] = 'finished';
          List<dynamic> myHand = List.from(hands[uid] ?? []);
          List<dynamic> oppHand = List.from(hands[opponentUid] ?? []);
          
          int mySum = myHand.fold(0, (sum, t) => sum + (t['value1'] as int) + (t['value2'] as int));
          int oppSum = oppHand.fold(0, (sum, t) => sum + (t['value1'] as int) + (t['value2'] as int));
          
          Map<String, dynamic> scores = Map<String, dynamic>.from(state['scores'] ?? {});
          if (mySum < oppSum) {
            scores[uid] = (scores[uid] ?? 0) + oppSum;
          } else if (oppSum < mySum) {
            scores[opponentUid] = (scores[opponentUid] ?? 0) + mySum;
          }
          updates['gameState/scores'] = scores;
        } else {
          updates['gameState/turn'] = opponentUid;
        }
      }
      
      updates['gameState/lastMoveId'] = moveId;
      await _db.child('rooms').child(roomCode).update(updates);
    });
  }

  void stopHostEngine() {
    _hostSubscription?.cancel();
    _hostSubscription = null;
  }
}

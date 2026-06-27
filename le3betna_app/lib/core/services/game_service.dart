import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../models/domino_models.dart';

class GameService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

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

  // --- Client-Driven Actions ---
  Future<void> playTile({
    required String roomCode,
    required DominoTile tile,
    required bool reversed,
    required bool isLeft,
  }) async {
    final roomSnap = await _db.child('rooms').child(roomCode).get();
    if (!roomSnap.exists) return;
    
    final roomData = roomSnap.value as Map<dynamic, dynamic>;
    final state = Map<String, dynamic>.from(roomData['gameState'] ?? {});
    final hands = Map<String, dynamic>.from(roomData['hands'] ?? {});
    
    if (state['status'] != 'playing' || state['turn'] != _uid) return;

    final opponentUid = state['player1'] == _uid ? state['player2'] : state['player1'];
    List<dynamic> board = _parseFirebaseArray(state['board']);
    Map<String, dynamic> playedTile = {'tile': tile.toJson(), 'reversed': reversed};
    
    if (isLeft) {
      board.insert(0, playedTile);
    } else {
      board.add(playedTile);
    }
    state['board'] = board;
    state['passCount'] = 0;

    List<dynamic> myHandRaw = _parseFirebaseArray(hands[_uid]);
    myHandRaw.removeWhere((t) => t['id'] == tile.id);
    hands[_uid] = myHandRaw;
    state['handCounts'][_uid] = myHandRaw.length;

    if (myHandRaw.isEmpty) {
      _handleWin(state, hands, _uid);
      print('DEBUG: Game won by $_uid');
    } else {
      state['turn'] = opponentUid;
      print('DEBUG: Turn changed to $opponentUid in playTile');
    }

    await _db.child('rooms').child(roomCode).update({
      'gameState': state,
      'hands': hands,
    });
  }

  Future<void> drawTile(String roomCode) async {
    final roomSnap = await _db.child('rooms').child(roomCode).get();
    if (!roomSnap.exists) return;
    
    final roomData = roomSnap.value as Map<dynamic, dynamic>;
    final state = Map<String, dynamic>.from(roomData['gameState'] ?? {});
    final hands = Map<String, dynamic>.from(roomData['hands'] ?? {});
    
    if (state['status'] != 'playing' || state['turn'] != _uid) return;

    List<dynamic> boneyard = _parseFirebaseArray(state['boneyard']);
    if (boneyard.isEmpty) return;

    final drawnTile = boneyard.removeAt(0);
    state['boneyard'] = boneyard;

    List<dynamic> myHandRaw = _parseFirebaseArray(hands[_uid]);
    myHandRaw.add(drawnTile);
    hands[_uid] = myHandRaw;
    state['handCounts'][_uid] = myHandRaw.length;

    // The user requested that drawing a tile passes the turn
    final opponentUid = state['player1'] == _uid ? state['player2'] : state['player1'];
    state['turn'] = opponentUid;
    print('DEBUG: Turn changed to $opponentUid in drawTile');

    await _db.child('rooms').child(roomCode).update({
      'gameState': state,
      'hands': hands,
    });
  }

  Future<void> passTurn(String roomCode) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    final stateSnap = await roomRef.get();
    if (!stateSnap.exists) return;
    
    final state = Map<String, dynamic>.from(stateSnap.value as Map);
    if (state['status'] != 'playing' || state['turn'] != _uid) return;

    final opponentUid = state['player1'] == _uid ? state['player2'] : state['player1'];
    
    state['passCount'] = ((state['passCount'] ?? 0) as num).toInt() + 1;
    state['turn'] = opponentUid;
    print('DEBUG: Turn changed to $opponentUid in passTurn');

    if (state['passCount'] >= 2) {
      final roomSnap = await _db.child('rooms').child(roomCode).get();
      final hands = Map<String, dynamic>.from((roomSnap.value as Map)['hands'] ?? {});
      _handleBlocked(state, hands);
      await _db.child('rooms').child(roomCode).update({
        'gameState': state,
      });
    } else {
      await roomRef.update(state);
    }
  }

  void _handleWin(Map<dynamic, dynamic> state, Map<dynamic, dynamic> hands, String winnerUid) {
    state['status'] = 'finished';
    state['winner'] = winnerUid;
    
    String loserUid = state['player1'] == winnerUid ? state['player2'] : state['player1'];
    int loserSum = _calculateHandSum(_parseFirebaseArray(hands[loserUid]));
    
    state['scores'][winnerUid] = ((state['scores'][winnerUid] ?? 0) as num).toInt() + loserSum;
  }

  void _handleBlocked(Map<dynamic, dynamic> state, Map<dynamic, dynamic> hands) {
    state['status'] = 'finished';
    
    String p1 = state['player1'];
    String p2 = state['player2'];
    
    int sum1 = _calculateHandSum(_parseFirebaseArray(hands[p1]));
    int sum2 = _calculateHandSum(_parseFirebaseArray(hands[p2]));

    if (sum1 < sum2) {
      state['winner'] = p1;
      state['scores'][p1] = ((state['scores'][p1] ?? 0) as num).toInt() + sum2;
    } else if (sum2 < sum1) {
      state['winner'] = p2;
      state['scores'][p2] = ((state['scores'][p2] ?? 0) as num).toInt() + sum1;
    } else {
      state['winner'] = 'draw';
    }
  }

  int _calculateHandSum(List<dynamic> handRaw) {
    int sum = 0;
    for (var raw in handRaw) {
      sum += ((raw['value1'] ?? 0) as num).toInt() + ((raw['value2'] ?? 0) as num).toInt();
    }
    return sum;
  }
}

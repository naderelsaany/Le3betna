import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import '../models/ludo_models.dart';

class LudoService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> initGame(String roomCode, String p1, String p2) async {
    List<Map<String, dynamic>> tokens = [];
    for (int i = 0; i < 4; i++) {
      tokens.add(LudoToken(id: i, color: 'red').toJson()); // P1
      tokens.add(LudoToken(id: i + 4, color: 'blue').toJson()); // P2
    }

    await _db.child('rooms').child(roomCode).update({
      'status': 'playing',
      'gameState': {
        'status': 'playing',
        'turn': p1,
        'player1': p1,
        'player2': p2,
        'diceValue': 0,
        'hasRolled': false,
        'tokens': tokens,
        'sixesRolled': 0,
        'lastMoveId': null,
      }
    });
  }

  // --- Client-Driven Actions ---
  Future<void> rollDice(String roomCode) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    final roomSnap = await roomRef.get();
    if (!roomSnap.exists) return;

    final state = Map<String, dynamic>.from(roomSnap.value as Map);
    if (state['status'] != 'playing' || state['turn'] != _uid || state['hasRolled'] == true) return;

    int dice = Random().nextInt(6) + 1;
    int sixes = (state['sixesRolled'] ?? 0) is num ? ((state['sixesRolled'] ?? 0) as num).toInt() : 0;
    
    if (dice == 6) {
      sixes++;
    } else {
      sixes = 0;
    }

    Map<String, dynamic> updates = {};
    if (sixes == 3) {
      updates['diceValue'] = dice;
      updates['hasRolled'] = false;
      updates['sixesRolled'] = 0;
      updates['turn'] = state['player1'] == _uid ? state['player2'] : state['player1'];
      print('DEBUG: Turn changed to ${updates['turn']} (3 sixes)');
    } else {
      bool hasLegalMove = _checkLegalMoves(state, _uid, dice);
      if (!hasLegalMove) {
        updates['diceValue'] = dice;
        updates['hasRolled'] = false;
        updates['sixesRolled'] = 0;
        updates['turn'] = state['player1'] == _uid ? state['player2'] : state['player1'];
        print('DEBUG: Turn changed to ${updates['turn']} (no legal move)');
      } else {
        updates['diceValue'] = dice;
        updates['hasRolled'] = true;
        updates['sixesRolled'] = sixes;
        print('DEBUG: hasRolled set to true with dice $dice');
      }
    }
    await roomRef.update(updates);
  }

  Future<void> moveToken(String roomCode, int tokenId) async {
    final roomRef = _db.child('rooms').child(roomCode).child('gameState');
    final roomSnap = await roomRef.get();
    if (!roomSnap.exists) return;

    final state = Map<String, dynamic>.from(roomSnap.value as Map);
    if (state['status'] != 'playing' || state['turn'] != _uid || state['hasRolled'] != true) return;

    int dice = state['diceValue'];
    String myColor = state['player1'] == _uid ? 'red' : 'blue';
    
    final rawTokens = _parseFirebaseArray(state['tokens']);
    List<LudoToken> tokens = rawTokens.map((e) => LudoToken.fromJson(Map<dynamic,dynamic>.from(e))).toList();

    int tokenIndex = tokens.indexWhere((t) => t.id == tokenId && t.color == myColor);
    if (tokenIndex == -1) return;
    
    LudoToken targetToken = tokens[tokenIndex];

    bool isValidMove = false;
    if (targetToken.localPosition == -1 && dice == 6) isValidMove = true;
    if (targetToken.localPosition != -1 && targetToken.localPosition + dice <= 57) isValidMove = true;

    if (!isValidMove) return;

    bool extraTurn = false;
    if (targetToken.localPosition == -1 && dice == 6) {
      tokens[tokenIndex] = LudoToken(id: targetToken.id, color: targetToken.color, localPosition: 0);
      extraTurn = true;
    } else {
      int newLocal = targetToken.localPosition + dice;
      
      if (newLocal <= 51) {
        int newGlobal = _getGlobalPosition(newLocal, myColor);
        if (!_isSafe(newGlobal)) {
          for (int i = 0; i < tokens.length; i++) {
            if (tokens[i].color != myColor && tokens[i].localPosition >= 0 && tokens[i].localPosition <= 51) {
              int oppGlobal = _getGlobalPosition(tokens[i].localPosition, tokens[i].color);
              if (oppGlobal == newGlobal) {
                tokens[i] = LudoToken(id: tokens[i].id, color: tokens[i].color, localPosition: -1);
                extraTurn = true;
              }
            }
          }
        }
      }
      tokens[tokenIndex] = LudoToken(id: targetToken.id, color: targetToken.color, localPosition: newLocal);
      if (newLocal == 57) {
        extraTurn = true;
      }
    }

    if (dice == 6) extraTurn = true;

    Map<String, dynamic> updates = {};
    updates['tokens'] = tokens.map((t) => t.toJson()).toList();
    updates['hasRolled'] = false;
    print('DEBUG: hasRolled set to false in moveToken');
    
    if (!extraTurn) {
      updates['turn'] = state['player1'] == _uid ? state['player2'] : state['player1'];
      print('DEBUG: Turn changed to ${updates['turn']} in moveToken');
    } else {
      print('DEBUG: Extra turn granted in moveToken');
    }

    if (_checkWin(tokens, myColor)) {
      updates['status'] = 'finished';
      updates['winner'] = _uid;
    }

    await roomRef.update(updates);
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

  bool _checkLegalMoves(Map<String, dynamic> state, String uid, int dice) {
    String myColor = state['player1'] == uid ? 'red' : 'blue';
    final rawTokens = _parseFirebaseArray(state['tokens']);
    List<LudoToken> tokens = rawTokens.map((e) => LudoToken.fromJson(Map<dynamic,dynamic>.from(e))).toList();
    
    for (var t in tokens) {
      if (t.color == myColor) {
        if (t.localPosition == -1 && dice == 6) return true;
        if (t.localPosition != -1 && t.localPosition + dice <= 57) return true;
      }
    }
    return false;
  }

  bool _checkWin(List<LudoToken> tokens, String color) {
    int homeCount = 0;
    for (var t in tokens) {
      if (t.color == color && t.localPosition == 57) homeCount++;
    }
    return homeCount == 4;
  }

  int _getGlobalPosition(int localPos, String color) {
    if (localPos > 51) return -1; // In home stretch
    if (color == 'red') return localPos; // Red starts at 0
    if (color == 'blue') return (localPos + 26) % 52; // Blue starts opposite
    return localPos;
  }

  bool _isSafe(int globalPos) {
    List<int> safeSpots = [0, 8, 13, 21, 26, 34, 39, 47];
    return safeSpots.contains(globalPos);
  }
}

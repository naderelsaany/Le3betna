import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ludo_models.dart';
import 'dart:math';

class LudoService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> initGame(String roomCode, String p1, String p2) async {
    final stateRef = _db.child('rooms').child(roomCode).child('gameState');
    
    // Initialize tokens
    List<Map<String, dynamic>> tokens = [];
    for (int i = 0; i < 4; i++) {
      tokens.add(LudoToken(id: i, color: 'red').toJson()); // P1
      tokens.add(LudoToken(id: i + 4, color: 'blue').toJson()); // P2
    }

    await stateRef.set({
      'status': 'playing',
      'turn': p1,
      'player1': p1,
      'player2': p2,
      'diceValue': 0,
      'hasRolled': false,
      'tokens': tokens,
      'sixesRolled': 0,
    });
  }

  Future<void> rollDice(String roomCode) async {
    final stateRef = _db.child('rooms').child(roomCode).child('gameState');
    final snapshot = await stateRef.get();
    if (!snapshot.exists) return;
    
    final state = snapshot.value as Map<dynamic, dynamic>;
    if (state['turn'] != _uid || state['hasRolled'] == true) return;

    int dice = Random().nextInt(6) + 1;
    int sixes = (state['sixesRolled'] ?? 0) as int;
    
    if (dice == 6) {
      sixes++;
    } else {
      sixes = 0;
    }

    // Three sixes rule - lose turn
    if (sixes == 3) {
      await stateRef.update({
        'diceValue': dice,
        'hasRolled': false,
        'sixesRolled': 0,
        'turn': state['player1'] == _uid ? state['player2'] : state['player1'],
      });
      return;
    }

    // Check if player has any legal moves
    bool hasLegalMove = _checkLegalMoves(state, _uid, dice);

    if (!hasLegalMove) {
      // Auto pass turn
      await stateRef.update({
        'diceValue': dice,
        'hasRolled': false,
        'sixesRolled': 0,
        'turn': state['player1'] == _uid ? state['player2'] : state['player1'],
      });
    } else {
      await stateRef.update({
        'diceValue': dice,
        'hasRolled': true,
        'sixesRolled': sixes,
      });
    }
  }

  bool _checkLegalMoves(Map<dynamic, dynamic> state, String uid, int dice) {
    String myColor = state['player1'] == uid ? 'red' : 'blue';
    final rawTokens = List<dynamic>.from(state['tokens']);
    final tokens = rawTokens.map((e) => LudoToken.fromJson(e)).toList();

    for (var t in tokens) {
      if (t.color == myColor) {
        if (t.localPosition == -1 && dice == 6) return true;
        if (t.localPosition != -1 && t.localPosition + dice <= 57) return true;
      }
    }
    return false;
  }

  Future<void> moveToken(String roomCode, int tokenId) async {
    final stateRef = _db.child('rooms').child(roomCode).child('gameState');
    final snapshot = await stateRef.get();
    if (!snapshot.exists) return;
    
    final state = snapshot.value as Map<dynamic, dynamic>;
    if (state['turn'] != _uid || state['hasRolled'] != true) return;

    int dice = state['diceValue'];
    String myColor = state['player1'] == _uid ? 'red' : 'blue';
    
    final rawTokens = List<dynamic>.from(state['tokens']);
    List<LudoToken> tokens = rawTokens.map((e) => LudoToken.fromJson(e)).toList();

    int tokenIndex = tokens.indexWhere((t) => t.id == tokenId && t.color == myColor);
    if (tokenIndex == -1) return;

    LudoToken targetToken = tokens[tokenIndex];

    // Invalid move rules
    if (targetToken.localPosition == -1 && dice != 6) return;
    if (targetToken.localPosition != -1 && targetToken.localPosition + dice > 57) return;

    bool extraTurn = false;

    // Moving logic
    if (targetToken.localPosition == -1 && dice == 6) {
      // Come out of home
      tokens[tokenIndex] = LudoToken(id: targetToken.id, color: targetToken.color, localPosition: 0);
      extraTurn = true; // Still rolled 6, get extra turn
    } else {
      int newLocal = targetToken.localPosition + dice;
      
      // Check capture only if it's on the main track (0-51)
      if (newLocal <= 51) {
        int newGlobal = _getGlobalPosition(newLocal, myColor);
        if (!_isSafe(newGlobal)) {
          // Check for opponent tokens at this global position
          for (int i = 0; i < tokens.length; i++) {
            if (tokens[i].color != myColor && tokens[i].localPosition >= 0 && tokens[i].localPosition <= 51) {
              int oppGlobal = _getGlobalPosition(tokens[i].localPosition, tokens[i].color);
              if (oppGlobal == newGlobal) {
                // Capture!
                tokens[i] = LudoToken(id: tokens[i].id, color: tokens[i].color, localPosition: -1);
                extraTurn = true; // Extra turn for capturing
              }
            }
          }
        }
      }

      tokens[tokenIndex] = LudoToken(id: targetToken.id, color: targetToken.color, localPosition: newLocal);
      
      // Reached finish
      if (newLocal == 57) {
        extraTurn = true;
      }
    }

    if (dice == 6) extraTurn = true;

    // Check Win
    bool hasWon = tokens.where((t) => t.color == myColor).every((t) => t.localPosition == 57);
    
    if (hasWon) {
      await stateRef.update({
        'status': 'finished',
        'winner': _uid,
        'tokens': tokens.map((e) => e.toJson()).toList(),
      });
      return;
    }

    String nextTurn = extraTurn ? _uid : (state['player1'] == _uid ? state['player2'] : state['player1']);

    await stateRef.update({
      'hasRolled': false,
      'turn': nextTurn,
      'tokens': tokens.map((e) => e.toJson()).toList(),
    });
  }

  int _getGlobalPosition(int local, String color) {
    if (color == 'red') return local % 52;
    if (color == 'blue') return (local + 13) % 52;
    if (color == 'yellow') return (local + 26) % 52;
    if (color == 'green') return (local + 39) % 52;
    return local;
  }

  bool _isSafe(int global) {
    // 0, 13, 26, 39 are starting points.
    // 8, 21, 34, 47 are stars.
    const safeZones = [0, 8, 13, 21, 26, 34, 39, 47];
    return safeZones.contains(global);
  }
}

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:math';
import '../models/ludo_models.dart';

class LudoService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  StreamSubscription? _hostSubscription;

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

  // --- Client Actions (Push to Moves Log) ---
  Future<void> rollDice(String roomCode) async {
    await _db.child('rooms').child(roomCode).child('moves').push().set({
      'type': 'roll',
      'uid': _uid,
      'timestamp': ServerValue.timestamp,
    });
  }

  Future<void> moveToken(String roomCode, int tokenId) async {
    await _db.child('rooms').child(roomCode).child('moves').push().set({
      'type': 'move',
      'uid': _uid,
      'tokenId': tokenId,
      'timestamp': ServerValue.timestamp,
    });
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

  // --- Host Engine ---
  void startHostEngine(String roomCode) {
    _hostSubscription?.cancel();
    _hostSubscription = _db.child('rooms').child(roomCode).child('moves').orderByChild('timestamp').onChildAdded.listen((event) async {
      final moveId = event.snapshot.key;
      if (moveId == null || event.snapshot.value == null) return;
      
      final move = event.snapshot.value as Map<dynamic, dynamic>;
      final uid = move['uid'] as String;
      
      final roomSnap = await _db.child('rooms').child(roomCode).child('gameState').get();
      if (!roomSnap.exists) return;
      
      final state = Map<String, dynamic>.from(roomSnap.value as Map);
      if (state['lastMoveId'] == moveId) return; // Already processed
      if (state['status'] != 'playing' || state['turn'] != uid) return; // Not their turn
      
      String type = move['type'];
      Map<String, dynamic> updates = {};

      if (type == 'roll' && state['hasRolled'] == false) {
        int dice = Random().nextInt(6) + 1;
        int sixes = (state['sixesRolled'] ?? 0) as int;
        
        if (dice == 6) {
          sixes++;
        } else {
          sixes = 0;
        }

        if (sixes == 3) {
          // Rule: 3 sixes lose turn
          updates['diceValue'] = dice;
          updates['hasRolled'] = false;
          updates['sixesRolled'] = 0;
          updates['turn'] = state['player1'] == uid ? state['player2'] : state['player1'];
        } else {
          bool hasLegalMove = _checkLegalMoves(state, uid, dice);
          if (!hasLegalMove) {
            // Auto pass
            updates['diceValue'] = dice;
            updates['hasRolled'] = false;
            updates['sixesRolled'] = 0;
            updates['turn'] = state['player1'] == uid ? state['player2'] : state['player1'];
          } else {
            updates['diceValue'] = dice;
            updates['hasRolled'] = true;
            updates['sixesRolled'] = sixes;
          }
        }
      } 
      else if (type == 'move' && state['hasRolled'] == true) {
        int tokenId = move['tokenId'];
        int dice = state['diceValue'];
        String myColor = state['player1'] == uid ? 'red' : 'blue';
        
        final rawTokens = _parseFirebaseArray(state['tokens']);
        List<LudoToken> tokens = rawTokens.map((e) => LudoToken.fromJson(Map<dynamic,dynamic>.from(e))).toList();

        int tokenIndex = tokens.indexWhere((t) => t.id == tokenId && t.color == myColor);
        if (tokenIndex != -1) {
          LudoToken targetToken = tokens[tokenIndex];

          bool isValidMove = false;
          if (targetToken.localPosition == -1 && dice == 6) isValidMove = true;
          if (targetToken.localPosition != -1 && targetToken.localPosition + dice <= 57) isValidMove = true;

          if (isValidMove) {
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

            bool hasWon = tokens.where((t) => t.color == myColor).every((t) => t.localPosition == 57);
            
            if (hasWon) {
              updates['status'] = 'finished';
              updates['winner'] = uid;
            } else {
              updates['hasRolled'] = false;
              if (!extraTurn) {
                updates['turn'] = state['player1'] == uid ? state['player2'] : state['player1'];
              }
            }
            updates['tokens'] = tokens.map((e) => e.toJson()).toList();
          }
        }
      }

      if (updates.isNotEmpty) {
        updates['lastMoveId'] = moveId;
        await _db.child('rooms').child(roomCode).child('gameState').update(updates);
      } else {
        // If no updates (invalid move), still update lastMoveId to prevent loop
        await _db.child('rooms').child(roomCode).child('gameState').update({'lastMoveId': moveId});
      }
    });
  }

  void stopHostEngine() {
    _hostSubscription?.cancel();
    _hostSubscription = null;
  }

  bool _checkLegalMoves(Map<String, dynamic> state, String uid, int dice) {
    String myColor = state['player1'] == uid ? 'red' : 'blue';
    final rawTokens = List<dynamic>.from(state['tokens'] ?? []);
    final tokens = rawTokens.map((e) => LudoToken.fromJson(Map<dynamic,dynamic>.from(e))).toList();

    for (var t in tokens) {
      if (t.color == myColor) {
        if (t.localPosition == -1 && dice == 6) return true;
        if (t.localPosition != -1 && t.localPosition + dice <= 57) return true;
      }
    }
    return false;
  }

  int _getGlobalPosition(int local, String color) {
    if (color == 'red') return local % 52;
    if (color == 'blue') return (local + 13) % 52;
    if (color == 'yellow') return (local + 26) % 52;
    if (color == 'green') return (local + 39) % 52;
    return local;
  }

  bool _isSafe(int global) {
    const safeZones = [0, 8, 13, 21, 26, 34, 39, 47];
    return safeZones.contains(global);
  }
}

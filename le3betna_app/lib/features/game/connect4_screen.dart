import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/connect4_service.dart';
import '../../core/services/room_service.dart';
import '../../core/services/sound_manager.dart';

class Connect4Screen extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const Connect4Screen({super.key, required this.roomCode, this.isHost = false});

  @override
  State<Connect4Screen> createState() => _Connect4ScreenState();
}

class _Connect4ScreenState extends State<Connect4Screen> {
  final Connect4Service _connect4Service = Connect4Service();
  final RoomService _roomService = RoomService();
  final SoundManager _soundManager = SoundManager();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _gameOverShown = false;

  /// Bulletproof grid parser — preserves zeros, handles Map/List/null from Firebase.
  List<List<int>> _parseGrid(dynamic rawGrid) {
    if (rawGrid == null) {
      return List.generate(6, (_) => List.generate(7, (_) => 0));
    }

    List<dynamic> rows;
    if (rawGrid is List) {
      rows = rawGrid;
    } else if (rawGrid is Map) {
      int maxIndex = 0;
      for (var key in rawGrid.keys) {
        int k = int.parse(key.toString());
        if (k > maxIndex) maxIndex = k;
      }
      rows = List.generate(maxIndex + 1, (i) => rawGrid[i] ?? rawGrid['$i']);
    } else {
      return List.generate(6, (_) => List.generate(7, (_) => 0));
    }

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

  void _showGameOverDialog(String winner, String p1, String p2) {
    if (_gameOverShown) return;
    _gameOverShown = true;

    String message = '';
    if (winner == 'draw') {
      message = 'تعادل!';
    } else if (winner == _myUid) {
      message = 'مبروك! كسبت الجيم 🎉';
      _soundManager.playSfx('win.wav');
    } else {
      message = 'هارد لك! خسرت الجيم 😢';
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text(message, style: const TextStyle(color: Colors.white, fontSize: 24), textAlign: TextAlign.center),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
              onPressed: () {
                _roomService.leaveRoom(widget.roomCode);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('رجوع للرئيسية', style: TextStyle(color: AppTheme.bgDeep, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('٤ في صف - الغرفة: ${widget.roomCode}', style: const TextStyle(fontSize: 18, color: Colors.white54)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_soundManager.isMuted ? Icons.volume_off : Icons.volume_up),
            onPressed: () => setState(() => _soundManager.toggleMute()),
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/gameState').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final turn = (state['turn'] ?? '') as String;
          final status = (state['status'] ?? 'waiting') as String;
          final debugLog = state['debugLog'] ?? '';
          final moveCount = state['moveCount'] ?? 0;
          
          final p1 = (state['player1'] ?? '') as String;
          final p2 = (state['player2'] ?? '') as String;
          
          final isMyTurn = turn == _myUid;
          final int myPlayerNum = _myUid == p1 ? 1 : 2;

          // Use the bulletproof grid parser
          final grid = _parseGrid(state['grid']);

          if (status == 'finished') {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               _showGameOverDialog(state['winner'] ?? '', p1, p2);
             });
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Debug Log Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                color: Colors.black,
                child: Text(
                  'LOG: $debugLog | moves: $moveCount | grid: ${grid.length}x${grid.isEmpty ? 0 : grid[0].length}',
                  style: const TextStyle(color: Colors.greenAccent, fontFamily: 'monospace', fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

              // Status Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: myPlayerNum == 1 ? Colors.redAccent : Colors.blueAccent,
                        boxShadow: [BoxShadow(color: (myPlayerNum == 1 ? Colors.redAccent : Colors.blueAccent).withOpacity(0.5), blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isMyTurn ? 'دورك للعب!' : 'انتظر الخصم...',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: isMyTurn ? AppTheme.accentGold : Colors.white54
                      ),
                    ),
                  ],
                ),
              ),

              // The Board
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 7 / 6,
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade900,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(color: Colors.blueAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                        ],
                      ),
                      child: Column(
                        children: List.generate(6, (r) {
                          return Expanded(
                            child: Row(
                              children: List.generate(7, (c) {
                                int cellValue = (r < grid.length && c < grid[r].length) ? grid[r][c] : 0;
                                Color cellColor = AppTheme.bgDeep;
                                if (cellValue == 1) cellColor = Colors.redAccent;
                                if (cellValue == 2) cellColor = Colors.blueAccent;

                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      if (isMyTurn && status == 'playing') {
                                        _connect4Service.dropToken(widget.roomCode, c);
                                      }
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: cellColor,
                                        shape: BoxShape.circle,
                                        border: cellValue == 0 ? Border.all(color: Colors.white12) : null,
                                        boxShadow: cellValue != 0 ? [
                                          BoxShadow(color: cellColor.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)
                                        ] : [
                                          const BoxShadow(color: Colors.black54, blurRadius: 4)
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

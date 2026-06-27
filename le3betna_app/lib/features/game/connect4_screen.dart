import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/connect4_service.dart';
import '../../core/services/room_service.dart';
import '../../core/services/sound_manager.dart';
import '../../core/services/transient_service.dart';
import 'widgets/transient_widget.dart';

class Connect4Screen extends StatefulWidget {
  final String roomCode;
  final bool isHost;

  const Connect4Screen({super.key, required this.roomCode, required this.isHost});

  @override
  State<Connect4Screen> createState() => _Connect4ScreenState();
}

class _Connect4ScreenState extends State<Connect4Screen> {
  final _connect4Service = Connect4Service();
  final _roomService = RoomService();
  final _transientService = TransientService();
  final _soundManager = SoundManager();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  bool _gameOverShown = false;
  List<Widget> _activeTransients = [];
  int _transientKeyCounter = 0;

  @override
  void initState() {
    super.initState();
    _transientService.listenToTransients(widget.roomCode).listen((event) {
      if (event.snapshot.key != _myUid && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _showTransient(data['emoji']);
      }
    });
    // Check if host and start engine
    if (widget.isHost) {
      _connect4Service.startHostEngine(widget.roomCode);
    }
  }

  @override
  void dispose() {
    _connect4Service.stopHostEngine();
    super.dispose();
  }

  void _showTransient(String emoji) {
    if (!mounted) return;
    _soundManager.playSfx('throw.wav');
    final key = _transientKeyCounter++;
    setState(() {
      _activeTransients.add(
        TransientWidget(
          key: ValueKey(key),
          emoji: emoji,
          onComplete: () {
            if (mounted) {
              setState(() {
                _activeTransients.removeWhere((w) => w.key == ValueKey(key));
              });
            }
          },
        ),
      );
    });
  }

  void _showGameOverDialog(String? winnerId, String p1, String p2) {
    if (_gameOverShown) return;
    _gameOverShown = true;
    
    String message = '';
    if (winnerId == 'draw') {
      message = 'تعادل!';
    } else if (winnerId == _myUid) {
      message = 'مبروك! كسبت الجولة 🎉';
    } else {
      message = 'هارد لك! خسرت الجولة 😢';
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
              onPressed: () {
                _roomService.leaveRoom(widget.roomCode);
                Navigator.pop(context);
                Navigator.pop(context); // Go back to lobby/dashboard
              },
              child: const Text('رجوع'),
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
            onPressed: () {
              setState(() => _soundManager.toggleMute());
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.emoji_emotions),
            onSelected: (emoji) {
              _transientService.sendEmoji(widget.roomCode, emoji);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: '🩴', child: Text('🩴 اضرب بالشبشب')),
              const PopupMenuItem(value: '🍅', child: Text('🍅 ارمي طماطم')),
              const PopupMenuItem(value: '😂', child: Text('😂 اضحك')),
              const PopupMenuItem(value: '😡', child: Text('😡 اغضب')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/gameState').onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final state = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final turn = state['turn'] as String;
          final status = state['status'] as String;
          final isMyTurn = turn == _myUid;
          
          final p1 = state['player1'] as String;
          final p2 = state['player2'] as String;
          final int myPlayerNum = _myUid == p1 ? 1 : 2;
          
          final rawGrid = List<dynamic>.from(state['grid']);
          final grid = rawGrid.map((r) => (r as List).map((e) => (e as num).toInt()).toList()).toList();

          if (status == 'finished') {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               _showGameOverDialog(state['winner'], p1, p2);
             });
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: myPlayerNum == 1 ? Colors.redAccent : Colors.yellowAccent,
                        boxShadow: [BoxShadow(color: (myPlayerNum == 1 ? Colors.redAccent : Colors.yellowAccent).withOpacity(0.5), blurRadius: 10)],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      isMyTurn ? 'دورك للعب!' : 'انتظر الخصم...',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: isMyTurn ? AppTheme.accentRed : Colors.white54
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
                        color: Colors.blueAccent.shade700,
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
                                int cellValue = grid[r][c];
                                Color cellColor = AppTheme.bgDeep; // empty
                                if (cellValue == 1) cellColor = Colors.redAccent;
                                if (cellValue == 2) cellColor = Colors.yellowAccent;

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
      // Active transients
      ..._activeTransients,
    ],
  ),
);
  }
}

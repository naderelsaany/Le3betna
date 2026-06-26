import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/ludo_service.dart';
import '../../core/services/sound_manager.dart';
import '../../core/services/transient_service.dart';
import '../game/widgets/transient_widget.dart';
import 'widgets/ludo_board_painter.dart';

class LudoScreen extends StatefulWidget {
  final String roomCode;

  const LudoScreen({super.key, required this.roomCode});

  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  final _ludoService = LudoService();
  final _transientService = TransientService();
  final _soundManager = SoundManager();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('ليدو - الغرفة: ${widget.roomCode}', style: const TextStyle(fontSize: 18, color: Colors.white54)),
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
              final isMyTurn = turn == _myUid;
              final dice = state['diceValue'] ?? 0;
              final hasRolled = state['hasRolled'] == true;
              final status = state['status'] as String;
              final tokens = List<dynamic>.from(state['tokens'] ?? []);

              if (status == 'finished') {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('انتهت اللعبة!', style: TextStyle(fontSize: 32, color: Colors.white)),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('رجوع'),
                      )
                    ],
                  ),
                );
              }

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isMyTurn ? 'دورك للعب!' : 'انتظر الخصم...',
                      style: TextStyle(
                        fontSize: 24, 
                        fontWeight: FontWeight.bold, 
                        color: isMyTurn ? AppTheme.accentRed : Colors.white54
                      ),
                    ),
                  ),

                  // Ludo Board
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.black54, blurRadius: 20),
                            ],
                          ),
                          child: GestureDetector(
                            onTapDown: (details) {
                              // Simplified logic for clicking a token
                              if (!isMyTurn || !hasRolled) return;
                              // Usually we'd figure out which token was clicked.
                              // Here we just auto-pick the first valid token.
                              _ludoService.moveToken(widget.roomCode, state['player1'] == _myUid ? 0 : 4);
                            },
                            child: CustomPaint(
                              painter: LudoBoardPainter(tokens: tokens),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Dice
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 10),
                            ]
                          ),
                          child: Center(
                            child: Text(
                              dice > 0 ? dice.toString() : '🎲',
                              style: const TextStyle(fontSize: 48, color: Colors.black, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: (isMyTurn && !hasRolled) ? () {
                            _soundManager.playSfx('dice.wav');
                            _ludoService.rollDice(widget.roomCode);
                          } : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                            backgroundColor: AppTheme.accentRed,
                          ),
                          child: const Text('ارمِ النرد', style: TextStyle(fontSize: 20)),
                        )
                      ],
                    ),
                  )
                ],
              );
            },
          ),
          ..._activeTransients,
        ],
      ),
    );
  }
}

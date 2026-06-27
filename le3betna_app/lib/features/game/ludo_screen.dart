import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/ludo_service.dart';
import '../../core/services/room_service.dart';
import '../../core/services/sound_manager.dart';
import '../../core/services/transient_service.dart';
import '../game/widgets/transient_widget.dart';
import 'widgets/ludo_board_painter.dart';
import 'widgets/glass_panel.dart';
import 'widgets/animated_ludo_dice.dart';

class LudoScreen extends StatefulWidget {
  final String roomCode;

  const LudoScreen({super.key, required this.roomCode});

  @override
  State<LudoScreen> createState() => _LudoScreenState();
}

class _LudoScreenState extends State<LudoScreen> {
  final _ludoService = LudoService();
  final _roomService = RoomService();
  final _transientService = TransientService();
  final _soundManager = SoundManager();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';

  List<Widget> _activeTransients = [];
  int _transientKeyCounter = 0;
  bool _gameOverShown = false;

  @override
  void initState() {
    super.initState();
    _transientService.listenToTransients(widget.roomCode).listen((event) {
      if (event.snapshot.key != _myUid && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _showTransient(data['emoji']);
      }
    });

    FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/hostUid').get().then((snapshot) {
      if (snapshot.value == _myUid) {
        _ludoService.startHostEngine(widget.roomCode);
      }
    });
  }

  @override
  void dispose() {
    _ludoService.stopHostEngine();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!_gameOverShown) {
                    _gameOverShown = true;
                    if (state['winner'] == _myUid) {
                      _soundManager.playSfx('win.wav');
                    }
                  }
                });

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('انتهت اللعبة!', style: TextStyle(fontSize: 32, color: Colors.white)),
                      ElevatedButton(
                        onPressed: () {
                          _roomService.leaveRoom(widget.roomCode);
                          Navigator.pop(context);
                        },
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
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              double cellSize = constraints.maxWidth / 15;
                              
                              List<Widget> tokenWidgets = [];
                              Map<String, List<Map<String, dynamic>>> groupedTokens = {};
                              for (var t in tokens) {
                                String posKey = '${t['localPosition']}_${t['color']}';
                                groupedTokens.putIfAbsent(posKey, () => []).add(Map<String,dynamic>.from(t));
                              }

                              for (var entry in groupedTokens.entries) {
                                List<Map<String, dynamic>> tList = entry.value;
                                for (int i = 0; i < tList.length; i++) {
                                  var t = tList[i];
                                  String colorStr = t['color'];
                                  int localPos = t['localPosition'];
                                  int tokenId = t['id'];
                                  
                                  Color tColor = LudoBoardPainter.redColor;
                                  if (colorStr == 'blue') tColor = LudoBoardPainter.blueColor;
                                  if (colorStr == 'yellow') tColor = LudoBoardPainter.yellowColor;
                                  if (colorStr == 'green') tColor = LudoBoardPainter.greenColor;
                                  
                                  Offset basePos = LudoBoardPainter.getTokenOffset(localPos, colorStr, cellSize, tokenId);
                                  
                                  if (localPos != -1 && tList.length > 1) {
                                    double offsetAmt = cellSize * 0.15;
                                    if (i == 0) basePos += Offset(-offsetAmt, -offsetAmt);
                                    if (i == 1) basePos += Offset(offsetAmt, offsetAmt);
                                    if (i == 2) basePos += Offset(-offsetAmt, offsetAmt);
                                    if (i == 3) basePos += Offset(offsetAmt, -offsetAmt);
                                  }

                                  double radius = cellSize * 0.35;
                                  
                                  bool canMove = isMyTurn && hasRolled && colorStr == (state['player1'] == _myUid ? 'red' : 'blue');
                                  
                                  tokenWidgets.add(
                                    Positioned(
                                      left: basePos.dx - radius,
                                      top: basePos.dy - radius,
                                      width: radius * 2,
                                      height: radius * 2,
                                      child: GestureDetector(
                                        onTap: canMove ? () {
                                          _soundManager.playSfx('move.wav');
                                          _ludoService.moveToken(widget.roomCode, tokenId);
                                        } : null,
                                        child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 300),
                                            curve: Curves.easeOutBack,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(color: Colors.black45, blurRadius: 6, offset: const Offset(0, 4)),
                                                if (canMove) BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 15, spreadRadius: 3),
                                              ],
                                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                                              gradient: RadialGradient(
                                                center: const Alignment(-0.3, -0.5),
                                                radius: 0.8,
                                                colors: [
                                                  Colors.white.withOpacity(0.8),
                                                  tColor,
                                                  tColor.withRed((tColor.red * 0.4).toInt())
                                                        .withGreen((tColor.green * 0.4).toInt())
                                                        .withBlue((tColor.blue * 0.4).toInt()),
                                                ],
                                                stops: const [0.0, 0.4, 1.0],
                                              )
                                            ),
                                            child: Stack(
                                              children: [
                                                // Glossy Reflection Top
                                                Positioned(
                                                  top: radius * 0.1,
                                                  left: radius * 0.3,
                                                  right: radius * 0.3,
                                                  height: radius * 0.8,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.4),
                                                      borderRadius: BorderRadius.circular(100),
                                                    ),
                                                  ),
                                                ),
                                                // Inner Indent
                                                Center(
                                                  child: Container(
                                                    width: radius * 0.8,
                                                    height: radius * 0.8,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(color: Colors.black12, width: 1),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ),
                                    ),
                                  );
                                }
                              }

                              return Stack(
                                children: [
                                  CustomPaint(
                                    size: Size(constraints.maxWidth, constraints.maxHeight),
                                    painter: LudoBoardPainter(tokens: []),
                                  ),
                                  ...tokenWidgets,
                                ],
                              );
                            }
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Animated Dice Bottom UI
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
                    child: GlassPanel(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isMyTurn ? 'دورك الآن' : 'انتظر الخصم', style: TextStyle(color: isMyTurn ? AppTheme.accentGreen : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              if (isMyTurn && !hasRolled) const Text('اضغط على النرد للعب', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          AnimatedLudoDice(
                            value: dice,
                            isRolling: isMyTurn && !hasRolled && dice == 0,
                            onTap: (isMyTurn && !hasRolled) ? () {
                              _soundManager.playSfx('dice.wav');
                              _ludoService.rollDice(widget.roomCode);
                            } : null,
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              );
            },
          ),
          
          // Custom Top App Bar (Glassmorphism)
          Positioned(
            top: 16, left: 16, right: 16,
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                    onPressed: () {
                      _roomService.leaveRoom(widget.roomCode);
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Ludo Game', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)),
                        Text('Room: ${widget.roomCode}', style: const TextStyle(fontSize: 12, color: AppTheme.accentGold)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_soundManager.isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
                        onPressed: () => setState(() => _soundManager.toggleMute()),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.emoji_emotions, color: Colors.white),
                        onSelected: (emoji) => _transientService.sendEmoji(widget.roomCode, emoji),
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: '🩴', child: Text('🩴 اضرب بالشبشب')),
                          const PopupMenuItem(value: '🍅', child: Text('🍅 ارمي طماطم')),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          ..._activeTransients,
        ],
      ),
    ));
  }
}

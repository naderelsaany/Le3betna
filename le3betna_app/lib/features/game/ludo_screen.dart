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
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('لودو - الغرفة: ${widget.roomCode}', style: const TextStyle(fontSize: 18, color: Colors.white54)),
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
                                          duration: const Duration(milliseconds: 200),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: tColor,
                                            boxShadow: [
                                              BoxShadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 4)),
                                              if (canMove) BoxShadow(color: Colors.white70, blurRadius: 10, spreadRadius: 2),
                                            ],
                                            border: Border.all(color: Colors.white30, width: 1.5),
                                            gradient: RadialGradient(
                                              center: const Alignment(-0.3, -0.5),
                                              radius: 0.8,
                                              colors: [
                                                tColor.withOpacity(0.9),
                                                tColor,
                                                tColor.withRed((tColor.red * 0.5).toInt())
                                                      .withGreen((tColor.green * 0.5).toInt())
                                                      .withBlue((tColor.blue * 0.5).toInt()),
                                              ],
                                              stops: const [0.0, 0.4, 1.0],
                                            )
                                          ),
                                          child: Align(
                                            alignment: Alignment(-0.3, -0.3),
                                            child: Container(
                                              width: radius * 0.5,
                                              height: radius * 0.5,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white.withOpacity(0.4),
                                              ),
                                            ),
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

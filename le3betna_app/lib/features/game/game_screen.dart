import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/domino_models.dart';
import '../../core/services/game_service.dart';
import '../../core/services/sound_manager.dart';
import '../../core/services/transient_service.dart';
import 'widgets/domino_piece.dart';
import 'widgets/transient_widget.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;
  final String opponentUid;

  const GameScreen({super.key, required this.roomCode, required this.opponentUid});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _gameService = GameService();
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
    _soundManager.playSfx('throw.wav'); // We assume throw.wav exists or ignores gracefully
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
        title: Text('الغرفة: ${widget.roomCode}', style: const TextStyle(fontSize: 18, color: Colors.white54)),
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
          final isMyTurn = turn == _myUid;
          
          final hands = state['hands'] as Map<dynamic, dynamic>;
          final myHandJson = List<dynamic>.from(hands[_myUid] ?? []);
          final oppHandJson = List<dynamic>.from(hands[widget.opponentUid] ?? []);
          
          final myHand = myHandJson.map((e) => DominoTile.fromJson(e)).toList();
          final oppCardCount = oppHandJson.length;

          final boardJson = List<dynamic>.from(state['board'] ?? []);
          final board = boardJson.map((e) => PlayedTile.fromJson(e)).toList();

          final boneyard = List<dynamic>.from(state['boneyard'] ?? []);
          final status = state['status'] as String;

          if (status == 'finished') {
             WidgetsBinding.instance.addPostFrameCallback((_) {
               _showGameOverDialog(state);
             });
          }

          return Column(
            children: [
              // 1. Opponent Hand
              Container(
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(oppCardCount, (index) => _buildOpponentTile()),
                ),
              ),

              // 2. Status / Turn indicator
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  isMyTurn ? 'دورك يا بطل!' : 'انتظر دور الخصم...',
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: isMyTurn ? AppTheme.accentRed : Colors.white54
                  ),
                ),
              ),

              // 3. Board
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: board.isEmpty 
                      ? const Center(child: Text('العب أول كارت!', style: TextStyle(color: Colors.white54, fontSize: 20)))
                      : SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: board.map((playedTile) => _buildPlayedTile(playedTile)).toList(),
                          ),
                        ),
                ),
              ),

              // 4. Actions (Draw / Pass)
              if (isMyTurn)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: boneyard.isNotEmpty ? () => _gameService.drawTile(widget.roomCode) : null,
                      icon: const Icon(Icons.style),
                      label: Text('سحب (${boneyard.length})'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: boneyard.isEmpty ? () => _gameService.passTurn(widget.roomCode, widget.opponentUid) : null,
                      icon: const Icon(Icons.skip_next),
                      label: const Text('خبط'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),

              // 5. My Hand
              Container(
                height: 120,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.black26,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: myHand.map((tile) => _buildMyTile(tile, isMyTurn, board)).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      // Render active transients on top
      ..._activeTransients,
    ],
  ),
);
  }

  Widget _buildOpponentTile() {
    return Container(
      width: 40,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
      ),
      child: const Center(child: Icon(Icons.games, color: AppTheme.accentGold, size: 20)),
    );
  }

  Widget _buildPlayedTile(PlayedTile pt) {
    // Determine if it should be displayed horizontally (standard play) or vertically (if double)
    bool isHorizontal = !pt.tile.isDouble;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: DominoPiece(
        value1: pt.leftValue,
        value2: pt.rightValue,
        isHorizontal: isHorizontal,
        isPlayable: true, // Always fully opaque on board
      ),
    );
  }

  void _playTileLogic(DominoTile tile, bool canPlayLeft, bool canPlayRight, List<PlayedTile> board) {
    if (canPlayLeft && canPlayRight) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: const Text('تلعب فين؟', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _gameService.playTile(
                    roomCode: widget.roomCode,
                    tile: tile,
                    reversed: tile.value1 == board.first.leftValue,
                    opponentUid: widget.opponentUid,
                    isLeft: true,
                  );
                },
                child: const Text('شمال'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _gameService.playTile(
                    roomCode: widget.roomCode,
                    tile: tile,
                    reversed: tile.value2 == board.last.rightValue,
                    opponentUid: widget.opponentUid,
                    isLeft: false,
                  );
                },
                child: const Text('يمين'),
              ),
            ],
          ),
        ),
      );
    } else {
      bool playLeft = canPlayLeft;
      bool reversed = false;
      
      if (playLeft) {
        reversed = tile.value1 == board.first.leftValue;
      } else {
        reversed = tile.value2 == board.last.rightValue;
      }

      _gameService.playTile(
        roomCode: widget.roomCode,
        tile: tile,
        reversed: reversed,
        opponentUid: widget.opponentUid,
        isLeft: playLeft,
      );
    }
  }

  bool _gameOverShown = false;
  void _showGameOverDialog(Map<dynamic, dynamic> state) {
    if (_gameOverShown) return;
    _gameOverShown = true;
    
    final scores = state['scores'] as Map<dynamic, dynamic>;
    final myScore = scores[_myUid] ?? 0;
    final oppScore = scores[widget.opponentUid] ?? 0;
    
    String message = '';
    if (myScore > oppScore) message = 'مبروك! كسبت الجولة 🎉';
    else if (myScore < oppScore) message = 'هارد لك! خسرت الجولة 😢';
    else message = 'تعادل!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text(message, style: const TextStyle(color: Colors.white, fontSize: 24), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('نقاطك: $myScore', style: const TextStyle(color: AppTheme.accentRed, fontSize: 20)),
            Text('نقاط الخصم: $oppScore', style: const TextStyle(color: Colors.redAccent, fontSize: 20)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
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

  Widget _buildMyTile(DominoTile tile, bool isMyTurn, List<PlayedTile> board) {
    // Check if playable
    bool isPlayable = false;
    bool canPlayLeft = false;
    bool canPlayRight = false;

    if (board.isEmpty) {
      isPlayable = true;
      canPlayLeft = true;
    } else {
      int leftEnd = board.first.leftValue;
      int rightEnd = board.last.rightValue;
      if (tile.canPlayOn(leftEnd)) {
        isPlayable = true;
        canPlayLeft = true;
      }
      if (tile.canPlayOn(rightEnd)) {
        isPlayable = true;
        canPlayRight = true;
      }
    }

    final canInteract = isMyTurn && isPlayable;

    return GestureDetector(
      onTap: canInteract ? () => _playTileLogic(tile, canPlayLeft, canPlayRight, board) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: DominoPiece(
          value1: tile.value1,
          value2: tile.value2,
          isHorizontal: false, // Hand tiles are vertical
          isPlayable: canInteract || (!isMyTurn && isPlayable), // Glow if it's playable (even if not your turn yet, keeps it visible)
        ),
      ),
    );
  }
}

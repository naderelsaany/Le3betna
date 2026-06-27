import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/models/domino_models.dart';
import '../../core/services/game_service.dart';
import '../../core/services/room_service.dart';
import '../../core/services/sound_manager.dart';
import '../../core/services/transient_service.dart';
import 'widgets/domino_board_widget.dart';
import 'widgets/player_hand_widget.dart';
import 'widgets/game_reactions_overlay.dart';
import '../../core/utils/avatar_utils.dart';
import 'dart:async';
import 'dart:math' as math;
import 'widgets/domino_tile_widget.dart';

class GameScreen extends StatefulWidget {
  final String roomCode;
  final String opponentUid;

  const GameScreen({super.key, required this.roomCode, required this.opponentUid});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _gameService = GameService();
  final _roomService = RoomService();
  final _transientService = TransientService();
  final _soundManager = SoundManager();
  final String _myUid = FirebaseAuth.instance.currentUser?.uid ?? '';
  
  late final StreamController<ReactionEvent> _reactionStreamController;
  
  DominoTile? _selectedTile;
  DominoTile? _illegalTile;

  @override
  void initState() {
    super.initState();
    _reactionStreamController = StreamController<ReactionEvent>.broadcast();

    _transientService.listenToTransients(widget.roomCode).listen((event) {
      if (event.snapshot.key != _myUid && event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        _reactionStreamController.add(ReactionEvent(data['emoji'], event.snapshot.key as String));
        _soundManager.playSfx('throw.wav'); // Sound effect for reaction
      }
    });

    FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/hostUid').get().then((snapshot) {
      if (snapshot.value == _myUid) {
        _gameService.startHostEngine(widget.roomCode);
      }
    });
  }

  @override
  void dispose() {
    _gameService.stopHostEngine();
    _reactionStreamController.close();
    super.dispose();
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

  void _onReactionSent(String emoji, String targetUid) {
    _transientService.sendEmoji(widget.roomCode, emoji);
  }

  void _onChatSent(String message) {
    // We can use transient service for chat as well
    _transientService.sendEmoji(widget.roomCode, message);
  }

  void _playTileLogic(DominoTile tile, bool canPlayLeft, bool canPlayRight, List<PlayedTile> board, {bool? forceLeft}) {
    if (board.isEmpty) {
      _gameService.playTile(
        roomCode: widget.roomCode,
        tile: tile,
        reversed: false,
        isLeft: true,
      );
      setState(() { _selectedTile = null; });
      return;
    }

    if (forceLeft != null) {
      // Drag & Drop explicitly specified the side
      bool reversed = forceLeft 
          ? tile.value1 == board.first.leftValue 
          : tile.value2 == board.last.rightValue;

      _gameService.playTile(
        roomCode: widget.roomCode,
        tile: tile,
        reversed: reversed,
        isLeft: forceLeft,
      );
      setState(() { _selectedTile = null; });
      return;
    }

    if (canPlayLeft && canPlayRight) {
      // If tapped, and can go both ways, prompt user
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppTheme.bgCard,
          title: const Text('تلعب فين؟', style: TextStyle(color: Colors.white), textAlign: TextAlign.center),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentTeal),
                onPressed: () {
                  Navigator.pop(context);
                  _gameService.playTile(
                    roomCode: widget.roomCode,
                    tile: tile,
                    reversed: tile.value1 == board.first.leftValue,
                    isLeft: true,
                  );
                  setState(() { _selectedTile = null; });
                },
                child: const Text('شمال'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed),
                onPressed: () {
                  Navigator.pop(context);
                  _gameService.playTile(
                    roomCode: widget.roomCode,
                    tile: tile,
                    reversed: tile.value2 == board.last.rightValue,
                    isLeft: false,
                  );
                  setState(() { _selectedTile = null; });
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
        isLeft: playLeft,
      );
      setState(() { _selectedTile = null; });
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
            Text('نقاطك: $myScore', style: const TextStyle(color: AppTheme.accentTeal, fontSize: 20)),
            Text('نقاط الخصم: $oppScore', style: const TextStyle(color: AppTheme.accentRed, fontSize: 20)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentGold),
              onPressed: () {
                _roomService.leaveRoom(widget.roomCode);
                Navigator.pop(context);
                Navigator.pop(context); // Go back to lobby/dashboard
              },
              child: const Text('رجوع للرئيسية', style: TextStyle(color: AppTheme.bgDeep)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBoneyard(int count, bool canDraw) {
    return GestureDetector(
      onTap: canDraw ? () {
        _soundManager.playSfx('click.wav');
        _gameService.drawTile(widget.roomCode);
      } : () {
        if (count > 0 && !canDraw) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('لا يمكنك السحب الآن', style: TextStyle(fontFamily: 'Cairo')), duration: Duration(seconds: 1)),
           );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Draw stacked cards
          for (int i = 0; i < math.min(count, 5); i++)
            Positioned(
              left: i * 4.0,
              top: i * -4.0,
              child: const DominoTileWidget(
                faceDown: true,
                size: 30,
              ),
            ),
          // Top card
          DominoTileWidget(
            faceDown: true,
            size: 30,
            isPlayable: canDraw, // makes it glow if playable
          ),
          // Count Badge
          Positioned(
            right: -10,
            top: -15,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppTheme.accentRed,
                shape: BoxShape.circle,
              ),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppTheme.bgDeep, // Deep navy background
        body: GameReactionsOverlay(
        reactionStream: _reactionStreamController.stream,
        onReactionSent: _onReactionSent,
        onChatSent: _onChatSent,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              
              Expanded(
                child: StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/gameState').onValue,
                  builder: (context, snapshotState) {
                    if (!snapshotState.hasData || snapshotState.data?.snapshot.value == null) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                    }

                    final state = snapshotState.data!.snapshot.value as Map<dynamic, dynamic>;
                    final turn = state['turn'] as String;
                    final isMyTurn = turn == _myUid;
                    
                    final handCounts = state['handCounts'] as Map<dynamic, dynamic>? ?? {};
                    final oppCardCount = handCounts[widget.opponentUid] ?? 0;

                    final boardJson = _parseFirebaseArray(state['board']);
                    final board = boardJson.map((e) => PlayedTile.fromJson(Map<String,dynamic>.from(e))).toList();
                    final boneyard = _parseFirebaseArray(state['boneyard']);
                    final status = state['status'] as String;

                    if (status == 'finished') {
                       WidgetsBinding.instance.addPostFrameCallback((_) {
                         _showGameOverDialog(state);
                       });
                    }

                    return StreamBuilder<DatabaseEvent>(
                      stream: FirebaseDatabase.instance.ref().child('rooms/${widget.roomCode}/hands/$_myUid').onValue,
                      builder: (context, snapshotHand) {
                        if (!snapshotHand.hasData || snapshotHand.data?.snapshot.value == null) {
                          return const Center(child: CircularProgressIndicator(color: AppTheme.accentTeal));
                        }

                        final myHandJson = _parseFirebaseArray(snapshotHand.data!.snapshot.value);
                        final myHand = myHandJson.map((e) => DominoTile.fromJson(Map<String,dynamic>.from(e))).toList();

                        // Determine Playable Tiles
                        List<DominoTile> playableTiles = [];
                        bool highlightLeft = false;
                        bool highlightRight = false;

                        if (isMyTurn) {
                          for (var tile in myHand) {
                            if (board.isEmpty) {
                              playableTiles.add(tile);
                            } else {
                              if (tile.canPlayOn(board.first.leftValue) || tile.canPlayOn(board.last.rightValue)) {
                                playableTiles.add(tile);
                              }
                            }
                          }
                          
                          if (_selectedTile != null && board.isNotEmpty) {
                            highlightLeft = _selectedTile!.canPlayOn(board.first.leftValue);
                            highlightRight = _selectedTile!.canPlayOn(board.last.rightValue);
                          }
                        }

                        return Column(
                          children: [
                            // Opponent Area
                            _buildOpponentArea(oppCardCount, isMyTurn),

                            // Center Board
                            Expanded(
                              child: Stack(
                                children: [
                                  DominoBoardWidget(
                                    board: board,
                                    highlightLeft: highlightLeft,
                                    highlightRight: highlightRight,
                                    onDrop: (isLeft) {
                                      if (_selectedTile != null) {
                                        _playTileLogic(_selectedTile!, true, true, board, forceLeft: isLeft);
                                      }
                                    },
                                  ),
                                  // Boneyard UI
                                  if (boneyard.isNotEmpty)
                                    Positioned(
                                      right: 32,
                                      bottom: 32,
                                      child: _buildBoneyard(boneyard.length, isMyTurn && playableTiles.isEmpty),
                                    ),
                                ],
                              ),
                            ),

                            // Actions (Pass only if no boneyard)
                            if (isMyTurn && playableTiles.isEmpty && boneyard.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () => _gameService.passTurn(widget.roomCode),
                                      icon: const Icon(Icons.skip_next, color: Colors.white),
                                      label: const Text('تمرير الدور', style: TextStyle(fontWeight: FontWeight.bold)),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentRed, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Player Hand (Fan layout)
                            PlayerHandWidget(
                              hand: myHand,
                              selectedTile: _selectedTile,
                              illegalTile: _illegalTile,
                              playableTiles: playableTiles,
                              onTileDragStarted: (tile) {
                                setState(() {
                                  _selectedTile = tile;
                                });
                              },
                              onTileTap: (tile) {
                                if (playableTiles.contains(tile)) {
                                  if (_selectedTile == tile) {
                                    // Tapped again -> play it automatically if possible
                                    bool canPlayLeft = board.isEmpty || tile.canPlayOn(board.first.leftValue);
                                    bool canPlayRight = board.isEmpty || tile.canPlayOn(board.last.rightValue);
                                    _playTileLogic(tile, canPlayLeft, canPlayRight, board);
                                  } else {
                                    setState(() {
                                      _selectedTile = tile;
                                      _illegalTile = null;
                                    });
                                  }
                                } else {
                                  setState(() {
                                    _illegalTile = tile; // Triggers shake
                                  });
                                }
                              },
                            ),
                          ],
                        );
                      }
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16, vertical: AppSpacing.sm8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _roomService.leaveRoom(widget.roomCode);
              Navigator.pop(context);
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
            ),
            child: Text(
              widget.roomCode,
              style: const TextStyle(
                fontFamily: 'Rajdhani', 
                fontWeight: FontWeight.bold, 
                letterSpacing: 4, 
                color: AppTheme.accentGold,
                fontSize: 18,
              ),
            ),
          ),
          IconButton(
            icon: Icon(_soundManager.isMuted ? Icons.volume_off : Icons.volume_up, color: Colors.white),
            onPressed: () => setState(() => _soundManager.toggleMute()),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentArea(int cardCount, bool isMyTurn) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md16),
      child: StreamBuilder<DatabaseEvent>(
        stream: FirebaseDatabase.instance.ref().child('users/${widget.opponentUid}/stats').onValue,
        builder: (context, oppSnap) {
          String oppName = 'الخصم';
          String oppPhoto = '';
          if (oppSnap.hasData && oppSnap.data?.snapshot.value != null) {
            final oppData = oppSnap.data!.snapshot.value as Map<dynamic, dynamic>;
            oppName = oppData['name'] ?? 'الخصم';
            oppPhoto = oppData['avatarUrl'] ?? '';
          }

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Opponent Avatar with Pulse if their turn
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: !isMyTurn ? [
                    BoxShadow(color: AppTheme.accentRed.withOpacity(0.6), blurRadius: 20, spreadRadius: 5)
                  ] : [],
                ),
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.bgCard,
                  backgroundImage: oppPhoto.isNotEmpty ? AvatarUtils.getImageProvider(oppPhoto) : null,
                  child: oppPhoto.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
                ),
              ),
              const SizedBox(width: AppSpacing.md16),
              // Opponent cards info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(oppName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Row(
                    children: [
                      const Icon(Icons.style, color: AppTheme.textSecondary, size: 16),
                      const SizedBox(width: 4),
                      Text('$cardCount قطع متبقية', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  )
                ],
              )
            ],
          );
        }
      ),
    );
  }
}

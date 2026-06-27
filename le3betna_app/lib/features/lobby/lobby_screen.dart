import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/room_service.dart';
import '../../core/services/game_service.dart';
import '../../core/services/connect4_service.dart';
import '../../core/services/ludo_service.dart';
import '../game/game_screen.dart' deferred as gameScreen;
import '../game/connect4_screen.dart' deferred as connect4Screen;
import '../game/ludo_screen.dart' deferred as ludoScreen;

class LobbyScreen extends StatefulWidget {
  final String roomCode;
  final bool isHost;
  final String gameName;

  const LobbyScreen({super.key, required this.roomCode, required this.isHost, required this.gameName});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with SingleTickerProviderStateMixin {
  final _roomService = RoomService();
  final _gameService = GameService();
  final _connect4Service = Connect4Service();
  final _ludoService = LudoService();
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _copyRoomCode() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('تم نسخ كود الغرفة! ابعته لصاحبك 🚀'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.accentTeal.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppTheme.bgDeep,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withOpacity(0.8),
            border: const Border(bottom: BorderSide(color: AppTheme.borderTransparent)),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'غرفة الانتظار',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Animated Ambient Background (Gold & Teal for Lobby)
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Positioned(
                  top: -150 + (_bgController.value * 100),
                  left: -100 - (_bgController.value * 50),
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentGold.withOpacity(0.12),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Positioned(
                  bottom: -100 - (_bgController.value * 100),
                  right: -50 + (_bgController.value * 50),
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentTeal.withOpacity(0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            SafeArea(
              child: StreamBuilder<DatabaseEvent>(
                stream: _roomService.getRoomStream(widget.roomCode),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('حدث خطأ في الاتصال!', style: TextStyle(color: AppTheme.accentRed)));
                  }

                  if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.accentGold));
                  }

                  final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                  final players = data['players'] as Map<dynamic, dynamic>? ?? {};
                  final status = data['status'];
                  
                  // If status changed to playing, we should navigate to game
                  if (status == 'playing') {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      String opponentUid = '';
                      for (var uid in players.keys) {
                        if (uid != FirebaseAuth.instance.currentUser?.uid) {
                          opponentUid = uid;
                          break;
                        }
                      }
                      
                      if (widget.gameName == '٤ في صف') {
                        connect4Screen.loadLibrary().then((_) {
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => connect4Screen.Connect4Screen(
                                roomCode: widget.roomCode,
                              )),
                            );
                          }
                        });
                      } else if (widget.gameName == 'ليدو') {
                        ludoScreen.loadLibrary().then((_) {
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => ludoScreen.LudoScreen(
                                roomCode: widget.roomCode,
                              )),
                            );
                          }
                        });
                      } else {
                        gameScreen.loadLibrary().then((_) {
                          if (mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => gameScreen.GameScreen(
                                roomCode: widget.roomCode,
                                opponentUid: opponentUid,
                              )),
                            );
                          }
                        });
                      }
                    });
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.lg24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.md16),
                            // Premium Room Code Card
                            _buildRoomCodeCard(),
                            
                            const SizedBox(height: AppSpacing.xxl48),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'اللاعبين المُنضمين (${players.length}/2)',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg24),
                            
                            // Players List
                            ...players.entries.map((e) {
                              final player = e.value as Map<dynamic, dynamic>;
                              final uid = e.key;
                              final isMe = uid == FirebaseAuth.instance.currentUser?.uid;
                              final isHost = uid == data['hostUid'];
                              
                              return _buildPlayerCard(
                                name: player['name'] ?? 'لاعب',
                                photoUrl: player['photo'],
                                isHost: isHost,
                                isMe: isMe,
                              );
                            }),
                            
                            if (players.length < 2)
                              _buildWaitingCard(),
                              
                            const SizedBox(height: AppSpacing.xxl48),
                            if (widget.isHost && players.length == 2 && status == 'waiting')
                              _AnimatedStartButton(
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  String guestUid = '';
                                  for (var uid in players.keys) {
                                    if (uid != FirebaseAuth.instance.currentUser?.uid) {
                                      guestUid = uid;
                                      break;
                                    }
                                  }
                                  if (widget.gameName == '٤ في صف') {
                                    _connect4Service.initializeGame(
                                      widget.roomCode,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      guestUid,
                                    );
                                  } else if (widget.gameName == 'ليدو') {
                                    _ludoService.initGame(
                                      widget.roomCode,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      guestUid,
                                    );
                                  } else {
                                    _gameService.initializeGame(
                                      widget.roomCode,
                                      FirebaseAuth.instance.currentUser!.uid,
                                      guestUid,
                                    );
                                  }
                                },
                              ),
                              
                            if (!widget.isHost && players.length == 2 && status == 'waiting')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl32, vertical: AppSpacing.md16),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentTeal.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.accentTeal.withOpacity(0.3)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20, 
                                      height: 20, 
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentTeal)
                                    ),
                                    SizedBox(width: AppSpacing.md16),
                                    Text(
                                      'في انتظار الـ Host لبدء اللعبة...',
                                      style: TextStyle(color: AppTheme.accentTeal, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl32, horizontal: AppSpacing.lg24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.15),
            blurRadius: 50,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('كود الغرفة', style: TextStyle(color: AppTheme.textSecondary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppSpacing.lg24),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.roomCode,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 12,
                  color: AppTheme.textPrimary,
                  shadows: [Shadow(color: AppTheme.accentGold, blurRadius: 30)],
                ),
              ),
              const SizedBox(width: AppSpacing.md16),
              _CopyButton(onPressed: _copyRoomCode),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({required String name, String? photoUrl, required bool isHost, required bool isMe}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md16),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accentGold.withOpacity(0.1) : AppTheme.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isHost 
              ? AppTheme.accentGold.withOpacity(0.6) 
              : AppTheme.borderTransparent,
          width: isHost ? 2 : 1,
        ),
        boxShadow: isHost ? [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: -5,
          )
        ] : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24, vertical: AppSpacing.md16),
        leading: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isHost ? const LinearGradient(
              colors: [AppTheme.accentGold, AppTheme.accentRed],
            ) : null,
            color: isHost ? null : AppTheme.bgPanel,
          ),
          child: CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.bgDeep,
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person_rounded, color: AppTheme.textSecondary) : null,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
        ),
        trailing: isHost
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md16, vertical: AppSpacing.sm8),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: AppTheme.accentGold, size: 18),
                    SizedBox(width: 4),
                    Text('المضيف', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            : const Icon(Icons.check_circle_rounded, color: AppTheme.accentTeal, size: 28),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderTransparent, style: BorderStyle.solid),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24, vertical: AppSpacing.md16),
        leading: Container(
          width: 58, // Match leading size
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.bgPanel,
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.textMuted),
            ),
          ),
        ),
        title: const Text(
          'في انتظار انضمام صديق...',
          style: TextStyle(fontSize: 18, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _CopyButton({required this.onPressed});

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.90,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.animateTo(1.0, curve: Curves.elasticOut);
    widget.onPressed();
  }

  void _onTapCancel() {
    _scaleController.animateTo(1.0, curve: Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.accentGold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentGold.withOpacity(0.5)),
          ),
          child: const Icon(Icons.content_copy_rounded, color: AppTheme.accentGold, size: 32),
        ),
      ),
    );
  }
}

class _AnimatedStartButton extends StatefulWidget {
  final VoidCallback onPressed;

  const _AnimatedStartButton({required this.onPressed});

  @override
  State<_AnimatedStartButton> createState() => _AnimatedStartButtonState();
}

class _AnimatedStartButtonState extends State<_AnimatedStartButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
    HapticFeedback.lightImpact();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.animateTo(1.0, curve: Curves.elasticOut);
    widget.onPressed();
  }

  void _onTapCancel() {
    _scaleController.animateTo(1.0, curve: Curves.elasticOut);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleController,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg24),
          decoration: BoxDecoration(
            color: AppTheme.accentRed,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentRed.withOpacity(0.4),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_fill_rounded, size: 36, color: Colors.white),
              SizedBox(width: AppSpacing.md16),
              Text(
                'ابدأ اللعبة!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

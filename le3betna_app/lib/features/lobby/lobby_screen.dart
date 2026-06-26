import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
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
    Clipboard.setData(ClipboardData(text: widget.roomCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ كود الغرفة! ابعته لصاحبك')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: AppTheme.background.withOpacity(0.8),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'غرفة الانتظار',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
            ),
            centerTitle: true,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Positioned(
                top: -150 + (_bgController.value * 100),
                left: -100 - (_bgController.value * 50),
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentSecondary.withOpacity(0.2),
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
                  return const Center(child: Text('حدث خطأ في الاتصال!'));
                }

                if (!snapshot.hasData || snapshot.data?.snapshot.value == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final players = data['players'] as Map<dynamic, dynamic>? ?? {};
                final status = data['status'];
                
                // If status changed to playing, we should navigate to game (Phase 3)
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
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Room Code Card
                      _buildRoomCodeCard(),
                      
                      const SizedBox(height: 48),
                      Text(
                        'اللاعبين المُنضمين (${players.length}/2)',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 24),
                      
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
                        
                      const SizedBox(height: 48),
                      if (widget.isHost && players.length == 2 && status == 'waiting')
                        ElevatedButton.icon(
                          onPressed: () {
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
                          icon: const Icon(Icons.play_arrow, size: 28),
                          label: const Text('ابدأ اللعبة!', style: TextStyle(fontSize: 20)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 10,
                            shadowColor: AppTheme.accentPrimary.withOpacity(0.5),
                          ),
                        ),
                        
                      if (!widget.isHost && players.length == 2 && status == 'waiting')
                        const Text(
                          'في انتظار الـ Host لبدء اللعبة...',
                          style: TextStyle(color: Colors.amberAccent, fontSize: 18),
                        ),
                    ],
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCodeCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.accentPrimary.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentPrimary.withOpacity(0.1),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          const Text('كود الغرفة', style: TextStyle(color: Colors.white70, fontSize: 18)),
          const SizedBox(height: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.roomCode,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                  color: Colors.white,
                  shadows: [Shadow(color: AppTheme.accentPrimary, blurRadius: 20)],
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: _copyRoomCode,
                icon: const Icon(Icons.copy, color: AppTheme.accentPrimary, size: 28),
                tooltip: 'نسخ الكود',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({required String name, String? photoUrl, required bool isHost, required bool isMe}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.accentPrimary.withOpacity(0.1) : AppTheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? AppTheme.accentPrimary.withOpacity(0.5) : Colors.white12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: AppTheme.background,
          backgroundImage: photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: (photoUrl == null || photoUrl.isEmpty) ? const Icon(Icons.person, color: Colors.white) : null,
        ),
        title: Text(
          name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        trailing: isHost
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber),
                ),
                child: const Text('المضيف', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              )
            : const Icon(Icons.check_circle, color: Colors.greenAccent),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12, style: BorderStyle.solid),
      ),
      child: const ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54)),
        ),
        title: Text(
          'في انتظار انضمام صديق...',
          style: TextStyle(fontSize: 18, color: Colors.white54, fontStyle: FontStyle.italic),
        ),
      ),
    );
  }
}

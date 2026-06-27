import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../services/dashboard_service.dart';
import '../../../core/services/room_service.dart' as import_room_service;
import '../../lobby/lobby_screen.dart' as import_lobby_screen;

class ActiveRoomsList extends StatelessWidget {
  final DashboardService service;

  const ActiveRoomsList({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
          child: Text(
            'غرف بانتظار لاعبين',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md16),
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: service.getActiveRooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final rooms = snapshot.data ?? [];
            if (rooms.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg24),
                  child: Text(
                    'لا يوجد غرف متاحة حالياً.\nكن أول من ينشئ غرفة!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
              itemCount: rooms.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md16),
              itemBuilder: (context, index) {
                final room = rooms[index];
                return _RoomCard(room: room);
              },
            );
          },
        ),
      ],
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Map<String, dynamic> room;

  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderTransparent),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bgDeep,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.videogame_asset, color: AppTheme.accentTeal),
          ),
          const SizedBox(width: AppSpacing.md16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'غرفة: ${room['id']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16),
                ),
                Text(
                  'في انتظار الخصم...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Replace snackbar with actual join logic
              final roomService = import_room_service.RoomService();
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              roomService.joinRoom(room['id']).then((success) {
                Navigator.pop(context); // close loading
                if (success) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => import_lobby_screen.LobbyScreen(
                        roomCode: room['id'], 
                        isHost: false, 
                        gameName: room['gameName'] ?? 'دومينو'
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('فشل الانضمام. الغرفة ممتلئة أو غير موجودة.'),
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.bgPanel,
              foregroundColor: AppTheme.accentTeal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24, vertical: 0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('انضمام'),
          )
        ],
      ),
    );
  }
}

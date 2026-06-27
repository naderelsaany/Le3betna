import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../services/dashboard_service.dart';

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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('جاري الدخول لغرفة ${room['id']}...'),
                  backgroundColor: AppTheme.accentTeal,
                  behavior: SnackBarBehavior.floating,
                ),
              );
              // TODO: Wire up actual join room logic
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

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/user_profile.dart';

class PlayerStatsGrid extends StatelessWidget {
  final UserProfile profile;

  const PlayerStatsGrid({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
          child: Text(
            'إحصائياتك',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
          child: Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'إجمالي الألعاب',
                  value: '${profile.gamesPlayed}',
                  icon: Icons.games,
                  color: AppTheme.accentTeal,
                ),
              ),
              const SizedBox(width: AppSpacing.md16),
              Expanded(
                child: _StatCard(
                  title: 'الانتصارات',
                  value: '${profile.wins}',
                  icon: Icons.emoji_events,
                  color: AppTheme.accentGold,
                ),
              ),
              const SizedBox(width: AppSpacing.md16),
              Expanded(
                child: _StatCard(
                  title: 'نسبة الفوز',
                  value: '${profile.winRate.toStringAsFixed(1)}%',
                  icon: Icons.pie_chart,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderTransparent),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

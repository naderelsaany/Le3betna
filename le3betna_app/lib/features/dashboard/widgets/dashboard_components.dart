import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/user_profile.dart';

// 1. Home App Bar (Sliver)
class HomeAppBar extends StatelessWidget {
  final VoidCallback onSettingsTap;

  const HomeAppBar({super.key, required this.onSettingsTap});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      expandedHeight: 70,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.bgDeep.withOpacity(0.7),
              border: const Border(bottom: BorderSide(color: AppTheme.borderTransparent)),
            ),
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videogame_asset, color: AppTheme.accentRed, size: 28),
          const SizedBox(width: AppSpacing.sm8),
          Text(
            'لعبتنا',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: const Icon(Icons.notifications_none, color: AppTheme.textSecondary),
        onPressed: () {},
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.people_outline, color: AppTheme.textSecondary),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
          onPressed: onSettingsTap,
        ),
      ],
    );
  }
}

// 2. Welcome Section
class WelcomeSection extends StatelessWidget {
  final UserProfile profile;

  const WelcomeSection({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg24),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.bgCard,
                backgroundImage: profile.avatarUrl.isNotEmpty ? NetworkImage(profile.avatarUrl) : null,
                child: profile.avatarUrl.isEmpty ? const Icon(Icons.person, size: 28, color: Colors.white) : null,
              ),
              Positioned(
                bottom: 0,
                right: -4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.greenAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.bgDeep, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مساء الخير،',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
                ),
                Text(
                  '${profile.name} 👋',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // XP & Coins Badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBadge(Icons.star, AppTheme.accentGold, 'مستوى ${profile.level}'),
              const SizedBox(height: AppSpacing.xs4),
              _buildBadge(Icons.monetization_on, Colors.amber, '${profile.coins}'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm8, vertical: AppSpacing.xs4),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderTransparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs4),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }
}

// 3. Hero Play Card
class HeroPlayCard extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;

  const HeroPlayCard({super.key, required this.onCreateRoom, required this.onJoinRoom});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
      padding: const EdgeInsets.all(AppSpacing.lg24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.accentRed.withOpacity(0.8),
            const Color(0xFF8B5CF6).withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentRed.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gamepad, color: Colors.white, size: 32),
              SizedBox(width: AppSpacing.md16),
              Text(
                'العب الآن',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm8),
          const Text(
            'ابدأ اللعب فوراً مع أصدقائك أو انضم لغرفة.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: AppSpacing.lg24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCreateRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.accentRed,
                  ),
                  child: const Text('إنشاء غرفة'),
                ),
              ),
              const SizedBox(width: AppSpacing.md16),
              Expanded(
                child: OutlinedButton(
                  onPressed: onJoinRoom,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('انضمام لغرفة', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

// 4. Quick Actions Grid
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24, vertical: AppSpacing.lg24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionCard(
            icon: Icons.bolt, 
            title: 'لعب سريع', 
            color: AppTheme.accentGold, 
            onTap: () => _showComingSoon(context, 'لعب سريع'),
          ),
          _ActionCard(
            icon: Icons.people, 
            title: 'الأصدقاء', 
            color: AppTheme.accentTeal, 
            onTap: () => _showComingSoon(context, 'الأصدقاء'),
          ),
          _ActionCard(
            icon: Icons.emoji_events, 
            title: 'المتصدرين', 
            color: const Color(0xFF8B5CF6), 
            onTap: () => _showComingSoon(context, 'المتصدرين'),
          ),
          _ActionCard(
            icon: Icons.card_giftcard, 
            title: 'مكافآت', 
            color: const Color(0xFFEC4899), 
            onTap: () => _showComingSoon(context, 'مكافآت'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature هتكون متاحة قريب جداً! 🚀'),
        backgroundColor: AppTheme.accentRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.borderTransparent),
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm8),
          Text(title, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}

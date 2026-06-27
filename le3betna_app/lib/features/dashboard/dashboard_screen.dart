import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../lobby/room_options_dialog.dart';
import 'profile_settings_dialog.dart';

import 'services/dashboard_service.dart';
import 'models/user_profile.dart';
import 'widgets/dashboard_components.dart';
import 'widgets/dashboard_carousel.dart';
import 'widgets/active_rooms_list.dart';
import 'widgets/player_stats_grid.dart';
import 'widgets/bottom_nav_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  final DashboardService _dashboardService = DashboardService();
  final String _uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // Initialize user if missing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _dashboardService.initializeUserIfNeeded(user.uid, user.displayName ?? '', user.photoURL);
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  void _showGameOptions(String gameName) {
    if (gameName == 'دومينو' || gameName == '٤ في صف' || gameName == 'لودو') {
      showDialog(
        context: context,
        builder: (context) => RoomOptionsDialog(gameName: gameName),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      extendBody: true,
      body: Stack(
        children: [
          // 1. Soft Glowing Animated Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Positioned(
                top: -150 + (_bgController.value * 100),
                right: -100 - (_bgController.value * 50),
                child: Container(
                  width: 600,
                  height: 600,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentRed.withOpacity(0.12),
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
                bottom: -200 - (_bgController.value * 80),
                left: -150 + (_bgController.value * 60),
                child: Container(
                  width: 700,
                  height: 700,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 2. Main Scrollable Content
          StreamBuilder<UserProfile>(
            stream: _dashboardService.getUserProfile(_uid),
            builder: (context, snapshot) {
              final profile = snapshot.data ?? UserProfile(
                uid: _uid, name: '...', avatarUrl: '', coins: 0, xp: 0, gamesPlayed: 0, wins: 0, currentRank: ''
              );

              return CustomScrollView(
                slivers: [
                  HomeAppBar(
                    onSettingsTap: () async {
                      HapticFeedback.lightImpact();
                      await showDialog(
                        context: context,
                        builder: (context) => const ProfileSettingsDialog(),
                      );
                    },
                  ),
                  SliverToBoxAdapter(child: WelcomeSection(profile: profile)),
                  SliverToBoxAdapter(
                    child: HeroPlayCard(
                      onCreateRoom: () => _showGameOptions('دومينو'), // Defaulting to Domino for quick play
                      onJoinRoom: () {
                        // TODO: Open Join Room dialog or scroll to active rooms
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: QuickActionsGrid()),
                  SliverToBoxAdapter(
                    child: PopularGamesCarousel(
                      onGameSelected: _showGameOptions,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg24)),
                  SliverToBoxAdapter(child: ActiveRoomsList(service: _dashboardService)),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg24)),
                  SliverToBoxAdapter(child: PlayerStatsGrid(profile: profile)),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for Bottom Nav & FAB
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MainBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != 2) {
            setState(() => _currentIndex = index);
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGameOptions('دومينو'),
        backgroundColor: AppTheme.accentRed,
        foregroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const Icon(Icons.play_arrow_rounded, size: 36),
      ),
    );
  }
}

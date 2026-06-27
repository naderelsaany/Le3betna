import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../lobby/room_options_dialog.dart';
import 'profile_settings_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
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

  Future<void> _signOut() async {
    HapticFeedback.mediumImpact();
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
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
              'لعبتنا',
              style: GoogleFonts.cairo(
                textStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: AppTheme.accentRed.withOpacity(0.6), blurRadius: 15),
                  ],
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppTheme.accentRed, AppTheme.accentGold],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(left: AppSpacing.md16),
                decoration: BoxDecoration(
                  color: AppTheme.bgPanel,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderTransparent),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout_rounded, color: AppTheme.textSecondary),
                  onPressed: _signOut,
                  tooltip: 'تسجيل الخروج',
                ),
              ),
            ],
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Animated Dynamic Background (Indigo & Purple)
            AnimatedBuilder(
              animation: _bgController,
              builder: (context, child) {
                return Positioned(
                  top: -100 + (_bgController.value * 50),
                  right: -100 - (_bgController.value * 50),
                  child: Container(
                    width: 500,
                    height: 500,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentRed.withOpacity(0.15),
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
                  bottom: -150 - (_bgController.value * 50),
                  left: -100 + (_bgController.value * 50),
                  child: Container(
                    width: 600,
                    height: 600,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF8B5CF6).withOpacity(0.1), // Secondary Purple
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Premium Glassmorphic User Profile Card
                    Center(
                      child: TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOutBack,
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(
                              opacity: value.clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: GestureDetector(
                          onTap: () async {
                            HapticFeedback.lightImpact();
                            final updated = await showDialog(
                              context: context,
                              builder: (context) => const ProfileSettingsDialog(),
                            );
                            if (updated == true) {
                              setState(() {}); // Refresh UI with new profile info
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxWidth: 600),
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl32, vertical: AppSpacing.lg24),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCard.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppTheme.borderTransparent),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(
                                      colors: [AppTheme.accentRed, AppTheme.accentGold],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentRed.withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundColor: AppTheme.bgCard,
                                    backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                                    child: user?.photoURL == null 
                                        ? const Icon(Icons.person_rounded, size: 35, color: Colors.white) 
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.lg24),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'أهلاً بك يا بطل،',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: AppTheme.textSecondary,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.xs4),
                                      Text(
                                        user?.displayName ?? 'لاعب مجهول',
                                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.settings_rounded, color: AppTheme.textMuted),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Game Modes Title
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(color: AppTheme.accentRed.withOpacity(0.5), blurRadius: 10),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md16),
                        Text(
                          'اختر لعبتك المفضلة',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg24),
                    
                    // Game Selection Grid
                    Center(
                      child: Wrap(
                        spacing: AppSpacing.lg24,
                        runSpacing: AppSpacing.lg24,
                        alignment: WrapAlignment.center,
                        children: [
                          _PremiumGameCard(title: 'دومينو', imagePath: 'assets/images/domino.webp', glowColor: AppTheme.accentRed),
                          _PremiumGameCard(title: 'ليدو', imagePath: 'assets/images/ludo.webp', glowColor: AppTheme.accentGold),
                          _PremiumGameCard(title: '٤ في صف', imagePath: 'assets/images/connect4.webp', glowColor: AppTheme.accentTeal),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumGameCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color glowColor;

  const _PremiumGameCard({
    required this.title,
    required this.imagePath,
    required this.glowColor,
  });

  @override
  State<_PremiumGameCard> createState() => _PremiumGameCardState();
}

class _PremiumGameCardState extends State<_PremiumGameCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isHovered = false;

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
    HapticFeedback.heavyImpact();
    _handlePress();
  }

  void _onTapCancel() {
    _scaleController.animateTo(1.0, curve: Curves.elasticOut);
  }
  
  void _handlePress() {
    if (widget.title == 'دومينو' || widget.title == '٤ في صف' || widget.title == 'ليدو') {
      showDialog(
        context: context,
        builder: (context) => RoomOptionsDialog(gameName: widget.title),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('لعبة ${widget.title} هتنزل قريب جداً في التحديث الجاي! 🚀'),
          backgroundColor: widget.glowColor.withOpacity(0.8),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        HapticFeedback.selectionClick();
      },
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: ScaleTransition(
          scale: _scaleController,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 320,
            height: 200,
            transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0), // Hover Lift
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.4),
                  blurRadius: 40,
                  spreadRadius: 5,
                  offset: const Offset(0, 15),
                )
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Hero(
                    tag: widget.title,
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  // Gradient overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.95),
                          Colors.black.withOpacity(_isHovered ? 0.3 : 0.6),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  
                  // Subtle glowing border on hover
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: widget.glowColor.withOpacity(0.6), width: 2),
                      ),
                    ),
                  ),
                    
                  // Title Text
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg24),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: _isHovered ? 30 : 28,
                          letterSpacing: 1.5,
                          color: AppTheme.textPrimary,
                          shadows: [
                            Shadow(
                              color: widget.glowColor.withOpacity(_isHovered ? 0.9 : 0.5),
                              blurRadius: _isHovered ? 20 : 10,
                            ),
                            const Shadow(
                              color: Colors.black,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ]
                        ),
                        child: Text(widget.title, textAlign: TextAlign.center),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

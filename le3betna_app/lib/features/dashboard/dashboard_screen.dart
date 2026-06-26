import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
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
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          color: AppTheme.bgCard.withOpacity(0.8), // Fixed deprecated background
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'لعبتنا',
              style: GoogleFonts.arefRuqaa(
                textStyle: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: AppTheme.accentRed.withOpacity(0.8),
                      blurRadius: 15,
                    ),
                  ],
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppTheme.accentRed, Colors.purpleAccent],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0))
                ),
              ),
            ),
            centerTitle: true,
            actions: [
              Container(
                margin: const EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white70),
                  onPressed: _signOut,
                  tooltip: 'تسجيل الخروج',
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated Dynamic Background
          AnimatedBuilder(
            animation: _bgController,
            builder: (context, child) {
              return Positioned(
                top: -100 + (_bgController.value * 50),
                right: -100 - (_bgController.value * 50),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.accentRed.withOpacity(0.3),
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
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.purpleAccent.withOpacity(0.2),
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium Glassmorphic User Profile Card
                  Align(
                    alignment: Alignment.centerRight,
                    child: IntrinsicWidth(
                      child: GestureDetector(
                        onTap: () async {
                          final updated = await showDialog(
                            context: context,
                            builder: (context) => const ProfileSettingsDialog(),
                          );
                          if (updated == true) {
                            setState(() {}); // Refresh UI with new profile info
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCard.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [AppTheme.accentRed, Colors.purpleAccent],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentRed.withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundColor: AppTheme.bgCard, // Fixed deprecated background
                                  backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                                  child: user?.photoURL == null 
                                      ? const Icon(Icons.person, size: 35, color: Colors.white) 
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'أهلاً بك يا بطل،',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white70,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user?.displayName ?? 'لاعب مجهول',
                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
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
                        width: 4,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(color: AppTheme.accentRed.withOpacity(0.5), blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'اختر لعبتك المفضلة',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Game Selection Grid
                  Center(
                    child: Wrap(
                      spacing: 24,
                      runSpacing: 24,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildPremiumGameCard(context, 'دومينو', 'assets/images/domino.webp', AppTheme.accentRed),
                        _buildPremiumGameCard(context, 'ليدو', 'assets/images/ludo.webp', AppTheme.accentGold),
                        _buildPremiumGameCard(context, '٤ في صف', 'assets/images/connect4.webp', Colors.tealAccent),
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
    );
  }

  Widget _buildPremiumGameCard(BuildContext context, String title, String imagePath, Color glowColor) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isHovered = false;
        
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              if (title == 'دومينو' || title == '٤ في صف' || title == 'ليدو') {
                showDialog(
                  context: context,
                  builder: (context) => RoomOptionsDialog(gameName: title),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('لعبة $title هتنزل قريب جداً في التحديث الجاي! 🚀'),
                    backgroundColor: glowColor.withOpacity(0.8),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuart,
              width: 320,
              height: 200,
              transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: isHovered ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.4),
                    blurRadius: 40,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  )
                ] : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
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
                    // Background Image filling the card
                    Hero(
                      tag: title,
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    
                    // Gradient overlay for text readability and hover effect
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.black.withOpacity(isHovered ? 0.3 : 0.6),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    
                    // Subtle glowing border on hover
                    if (isHovered)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: glowColor.withOpacity(0.5), width: 2),
                        ),
                      ),
                      
                    // Title Text
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            letterSpacing: 1,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: glowColor.withOpacity(0.8),
                                blurRadius: 15,
                              ),
                              const Shadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ]
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}

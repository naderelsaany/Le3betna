import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';

// -- Custom Local Palette based on the PRD --
const Color _bgColor = Color(0xFF0B1120);
const Color _surfaceColor = Color(0xFF111827);
const Color _primaryColor = Color(0xFF6366F1);
const Color _secondaryColor = Color(0xFF8B5CF6);
const Color _textSecondaryColor = Color(0xFF94A3B8);
const Color _borderColor = Color(0x14FFFFFF); // rgba(255,255,255,0.08)

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isLoading = false;
  String? _errorMessage;
  
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Entrance Animations
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );

    // Pulse Animation for Logo
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } catch (e) {
      HapticFeedback.vibrate();
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى.';
      });
      debugPrint('Login Error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            // Background Gradients
            Positioned(
              top: -200,
              right: -150,
              child: Container(
                width: 600,
                height: 600,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _primaryColor.withOpacity(0.15),
                      _bgColor.withOpacity(0.0),
                    ],
                    stops: const [0.1, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -250,
              left: -150,
              child: Container(
                width: 700,
                height: 700,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _secondaryColor.withOpacity(0.12),
                      _bgColor.withOpacity(0.0),
                    ],
                    stops: const [0.1, 1.0],
                  ),
                ),
              ),
            ),
            
            // Subtle Noise Overlay (Optional fallback using grid lines to simulate texture)
            Positioned.fill(
              child: CustomPaint(
                painter: _NoisePainter(),
              ),
            ),
            
            // Main Content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24, vertical: AppSpacing.xl40),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _surfaceColor,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: _borderColor, width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    blurRadius: 40,
                                    spreadRadius: -10,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl40),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Animated Logo
                                    ScaleTransition(
                                      scale: _pulseAnimation,
                                      child: Container(
                                        width: 88,
                                        height: 88,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _surfaceColor,
                                          border: Border.all(color: _primaryColor.withOpacity(0.3), width: 2),
                                          boxShadow: [
                                            BoxShadow(
                                              color: _primaryColor.withOpacity(0.4),
                                              blurRadius: 30,
                                              spreadRadius: 5,
                                            )
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.sports_esports_rounded,
                                            size: 40,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xl32),
                                    
                                    // Typography
                                    Text(
                                      'لعبتنا',
                                      style: AppTypography.textTheme.displayMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -1.0,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm8),
                                    Text(
                                      'العب مع أصحابك في أي وقت',
                                      style: AppTypography.textTheme.bodyLarge?.copyWith(
                                        color: _textSecondaryColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AppSpacing.lg24),
                                    
                                    // Feature Tags
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _FeatureChip(icon: '🎲', label: 'مجاني بالكامل'),
                                        _FeatureChip(icon: '⚡', label: 'بدون تحميل'),
                                        _FeatureChip(icon: '👥', label: 'مع أصحابك'),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: AppSpacing.xl40),
                                    
                                    // Error Message
                                    if (_errorMessage != null) ...[
                                      Container(
                                        padding: const EdgeInsets.all(AppSpacing.md16),
                                        decoration: BoxDecoration(
                                          color: AppColors.error.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.error.withOpacity(0.3)),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                                            const SizedBox(width: AppSpacing.sm12),
                                            Expanded(
                                              child: Text(
                                                _errorMessage!,
                                                style: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.error),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg24),
                                    ],

                                    // CTA Button
                                    _GoogleLoginButton(
                                      isLoading: _isLoading,
                                      onPressed: _signInWithGoogle,
                                    ),
                                    
                                    const SizedBox(height: AppSpacing.lg24),
                                    
                                    // Secondary Text
                                    Text(
                                      'بتسجيل الدخول فإنك توافق على شروط الاستخدام وسياسة الخصوصية',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: _textSecondaryColor.withOpacity(0.8),
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          // Version
                          const SizedBox(height: AppSpacing.xl40),
                          Text(
                            'v1.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.2),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String icon;
  final String label;

  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleLoginButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  State<_GoogleLoginButton> createState() => _GoogleLoginButtonState();
}

class _GoogleLoginButtonState extends State<_GoogleLoginButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.98,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isHovered = true);
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.isLoading) {
            _scaleController.reverse();
          }
        },
        onTapUp: (_) {
          if (!widget.isLoading) {
            _scaleController.forward();
            HapticFeedback.lightImpact();
            widget.onPressed();
          }
        },
        onTapCancel: () {
          if (!widget.isLoading) {
            _scaleController.forward();
          }
        },
        child: ScaleTransition(
          scale: _scaleController,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isHovered && !widget.isLoading
                  ? [BoxShadow(color: Colors.white.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 5))]
                  : [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: widget.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: _bgColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Classic Google G colors
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CustomPaint(painter: _GoogleIconPainter()),
                      ),
                      const SizedBox(width: AppSpacing.md16),
                      const Text(
                        'المتابعة باستخدام جوجل',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _bgColor, // Dark text
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Simple custom drawing of a 'G' using Google Colors for standard look without assets
    final Paint blue = Paint()..color = const Color(0xFF4285F4)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    final Paint red = Paint()..color = const Color(0xFFEA4335)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    final Paint yellow = Paint()..color = const Color(0xFFFBBC05)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;
    final Paint green = Paint()..color = const Color(0xFF34A853)..style = PaintingStyle.stroke..strokeWidth = 3..strokeCap = StrokeCap.round;

    final Rect rect = Rect.fromLTWH(2, 2, size.width - 4, size.height - 4);
    
    // Simplistic representation for demo (Using sweep arcs)
    canvas.drawArc(rect, 2.5, 2.0, false, red);
    canvas.drawArc(rect, 1.0, 1.5, false, yellow);
    canvas.drawArc(rect, 0.0, 1.0, false, green);
    canvas.drawArc(rect, -1.0, 1.0, false, blue);
    
    canvas.drawLine(Offset(size.width / 2, size.height / 2), Offset(size.width, size.height / 2), blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // A very subtle texture pattern (dots)
    final Paint paint = Paint()..color = Colors.white.withOpacity(0.015);
    for (double i = 0; i < size.width; i += 4) {
      for (double j = 0; j < size.height; j += 4) {
        if ((i + j) % 3 == 0) {
          canvas.drawRect(Rect.fromLTWH(i, j, 1, 1), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

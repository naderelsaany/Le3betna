import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';

class AnimatedLudoDice extends StatefulWidget {
  final int value;
  final bool isRolling;
  final VoidCallback? onTap;

  const AnimatedLudoDice({
    super.key,
    required this.value,
    this.isRolling = false,
    this.onTap,
  });

  @override
  State<AnimatedLudoDice> createState() => _AnimatedLudoDiceState();
}

class _AnimatedLudoDiceState extends State<AnimatedLudoDice> with SingleTickerProviderStateMixin {
  late AnimationController _rollController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _rollController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _rotationAnimation = Tween<double>(begin: 0, end: math.pi * 4).animate(
      CurvedAnimation(parent: _rollController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0).chain(CurveTween(curve: Curves.bounceOut)), weight: 50),
    ]).animate(_rollController);
  }

  @override
  void didUpdateWidget(covariant AnimatedLudoDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRolling && !oldWidget.isRolling) {
      _rollController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _rollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isRolling ? null : widget.onTap,
      child: AnimatedBuilder(
        animation: _rollController,
        builder: (context, child) {
          final isRollingNow = _rollController.isAnimating;
          final displayValue = isRollingNow ? (math.Random().nextInt(6) + 1) : widget.value;

          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.rotate(
              angle: _rotationAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Floating Shadow
                  Positioned(
                    bottom: -10,
                    child: Container(
                      width: 40,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentGold.withOpacity(0.3),
                            blurRadius: 15,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                    ),
                  ),
                  
                  // Dice Body
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.grey.shade200,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black26, offset: const Offset(2, 4), blurRadius: 6),
                        BoxShadow(color: Colors.white, offset: const Offset(-2, -2), blurRadius: 4),
                      ],
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: _buildDots(displayValue == 0 ? 6 : displayValue),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDots(int count) {
    const double dotSize = 12.0;
    Widget dot = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: AppTheme.bgDeep,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Colors.black54, offset: Offset(0, 1), blurRadius: 2, inset: true),
        ],
      ),
    );

    List<Widget> dots = [];

    if (count == 1) {
      dots.add(Center(child: dot));
    } else if (count == 2) {
      dots.addAll([
        Positioned(top: 8, left: 8, child: dot),
        Positioned(bottom: 8, right: 8, child: dot),
      ]);
    } else if (count == 3) {
      dots.addAll([
        Positioned(top: 8, left: 8, child: dot),
        Center(child: dot),
        Positioned(bottom: 8, right: 8, child: dot),
      ]);
    } else if (count == 4) {
      dots.addAll([
        Positioned(top: 8, left: 8, child: dot),
        Positioned(top: 8, right: 8, child: dot),
        Positioned(bottom: 8, left: 8, child: dot),
        Positioned(bottom: 8, right: 8, child: dot),
      ]);
    } else if (count == 5) {
      dots.addAll([
        Positioned(top: 8, left: 8, child: dot),
        Positioned(top: 8, right: 8, child: dot),
        Center(child: dot),
        Positioned(bottom: 8, left: 8, child: dot),
        Positioned(bottom: 8, right: 8, child: dot),
      ]);
    } else if (count == 6) {
      dots.addAll([
        Positioned(top: 8, left: 8, child: dot),
        Positioned(top: 8, right: 8, child: dot),
        Positioned(top: 24, left: 8, child: dot),
        Positioned(top: 24, right: 8, child: dot),
        Positioned(bottom: 8, left: 8, child: dot),
        Positioned(bottom: 8, right: 8, child: dot),
      ]);
    }

    return Stack(children: dots);
  }
}

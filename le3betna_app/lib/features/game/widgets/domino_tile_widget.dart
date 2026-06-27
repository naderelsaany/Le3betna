import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/domino_models.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class DominoTileWidget extends StatefulWidget {
  final DominoTile? tile; // if null, draw face down
  final bool isPlayable;
  final bool isSelected;
  final bool isIllegal; // triggers shake
  final bool faceDown;
  final double size; // width of the tile (height will be size * 2 for vertical)
  final VoidCallback? onTap;
  final bool isHorizontal; // for board placement

  const DominoTileWidget({
    super.key,
    this.tile,
    this.isPlayable = false,
    this.isSelected = false,
    this.isIllegal = false,
    this.faceDown = false,
    this.size = 50,
    this.onTap,
    this.isHorizontal = false,
  });

  @override
  State<DominoTileWidget> createState() => _DominoTileWidgetState();
}

class _DominoTileWidgetState extends State<DominoTileWidget> with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _shakeAnimation = Tween<double>(begin: 0, end: 10).chain(CurveTween(curve: Curves.elasticIn)).animate(_shakeController)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _shakeController.reset();
        }
      });
  }

  @override
  void didUpdateWidget(covariant DominoTileWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isIllegal && !oldWidget.isIllegal) {
      _shakeController.forward();
      HapticFeedback.heavyImpact(); // feedback for wrong move
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.size;
    final double height = widget.size * 2.0;
    
    // Scale for selected tile
    final double scale = widget.isSelected ? 1.08 : 1.0;
    // Lift for selected tile
    final double lift = widget.isSelected ? -10.0 : 0.0;
    // Opacity for non-playable tiles (if we are considering turns, non-playable in hand dims)
    final double opacity = (!widget.isPlayable && !widget.faceDown && widget.onTap != null) ? 0.6 : 1.0;

    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        // Shake logic (translation X)
        final double shake = math.sin(_shakeAnimation.value * math.pi) * 8;
        return Transform.translate(
          offset: Offset(shake, lift),
          child: Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (widget.isPlayable && widget.onTap != null) {
            widget.onTap!();
          } else if (!widget.isPlayable && widget.onTap != null) {
             _shakeController.forward();
             HapticFeedback.vibrate();
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.isHorizontal ? height : width,
          height: widget.isHorizontal ? width : height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(width * 0.2),
            boxShadow: [
              // Premium soft shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: widget.isSelected ? 15 : 8,
                offset: Offset(0, widget.isSelected ? 8 : 4),
              ),
              // Glow if playable
              if (widget.isPlayable && widget.onTap != null)
                BoxShadow(
                  color: AppTheme.accentTeal.withOpacity(widget.isSelected ? 0.8 : 0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: CustomPaint(
            painter: _DominoPainter(
              tile: widget.tile,
              faceDown: widget.faceDown,
              isHorizontal: widget.isHorizontal,
              isPlayable: widget.isPlayable,
            ),
          ),
        ),
      ),
    );
  }
}

class _DominoPainter extends CustomPainter {
  final DominoTile? tile;
  final bool faceDown;
  final bool isHorizontal;
  final bool isPlayable;

  _DominoPainter({
    this.tile,
    required this.faceDown,
    required this.isHorizontal,
    required this.isPlayable,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background color: Ivory white
    final Paint bgPaint = Paint()
      ..color = const Color(0xFFF3F2EB) // Ivory
      ..style = PaintingStyle.fill;
    
    // Backside color if faceDown
    if (faceDown) {
      bgPaint.color = const Color(0xFF1E293B); // Dark slate for back
    }

    // Border/Bevel
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(math.min(size.width, size.height) * 0.2));
    
    canvas.drawRRect(rrect, bgPaint);

    // Bevel effect (inner shadow)
    final Paint bevelPaint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, bevelPaint);
    
    // Draw back pattern if face down
    if (faceDown) {
      final Paint logoPaint = Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(size.width/2, size.height/2), size.width * 0.25, logoPaint);
      return;
    }

    if (tile == null) return;

    // Divider line
    final Paint dividerPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    if (isHorizontal) {
      canvas.drawLine(
        Offset(size.width / 2, size.height * 0.1),
        Offset(size.width / 2, size.height * 0.9),
        dividerPaint,
      );
    } else {
      canvas.drawLine(
        Offset(size.width * 0.1, size.height / 2),
        Offset(size.width * 0.9, size.height / 2),
        dividerPaint,
      );
    }

    // Draw dots
    final double dotRadius = math.min(size.width, size.height) * 0.08;
    final Paint dotPaint = Paint()..color = const Color(0xFF1A1A1A);

    if (isHorizontal) {
       _drawDots(canvas, tile!.value1, Rect.fromLTWH(0, 0, size.width/2, size.height), dotRadius, dotPaint);
       _drawDots(canvas, tile!.value2, Rect.fromLTWH(size.width/2, 0, size.width/2, size.height), dotRadius, dotPaint);
    } else {
       _drawDots(canvas, tile!.value1, Rect.fromLTWH(0, 0, size.width, size.height/2), dotRadius, dotPaint);
       _drawDots(canvas, tile!.value2, Rect.fromLTWH(0, size.height/2, size.width, size.height/2), dotRadius, dotPaint);
    }
    
    // If playable, slight blue tint overlay
    if (isPlayable) {
      canvas.drawRRect(rrect, Paint()..color = AppTheme.accentTeal.withOpacity(0.05)..style = PaintingStyle.fill);
    }
  }

  void _drawDots(Canvas canvas, int value, Rect bounds, double radius, Paint paint) {
    if (value == 0) return;

    final double cx = bounds.center.dx;
    final double cy = bounds.center.dy;
    final double qx = bounds.width * 0.25;
    final double qy = bounds.height * 0.25;

    // Standard dice dot layouts
    List<Offset> centers = [];
    
    switch (value) {
      case 1:
        centers = [Offset(cx, cy)];
        break;
      case 2:
        centers = [Offset(cx - qx, cy - qy), Offset(cx + qx, cy + qy)];
        break;
      case 3:
        centers = [Offset(cx - qx, cy - qy), Offset(cx, cy), Offset(cx + qx, cy + qy)];
        break;
      case 4:
        centers = [
          Offset(cx - qx, cy - qy), Offset(cx + qx, cy - qy),
          Offset(cx - qx, cy + qy), Offset(cx + qx, cy + qy),
        ];
        break;
      case 5:
        centers = [
          Offset(cx - qx, cy - qy), Offset(cx + qx, cy - qy),
          Offset(cx, cy),
          Offset(cx - qx, cy + qy), Offset(cx + qx, cy + qy),
        ];
        break;
      case 6:
        centers = [
          Offset(cx - qx, cy - qy), Offset(cx + qx, cy - qy),
          Offset(cx - qx, cy),      Offset(cx + qx, cy),
          Offset(cx - qx, cy + qy), Offset(cx + qx, cy + qy),
        ];
        break;
    }

    for (final offset in centers) {
      canvas.drawCircle(offset, radius, paint);
      // Small highlight on the dot for 3D effect
      canvas.drawCircle(Offset(offset.dx - radius*0.3, offset.dy - radius*0.3), radius*0.2, Paint()..color=Colors.white.withOpacity(0.3));
    }
  }

  @override
  bool shouldRepaint(covariant _DominoPainter oldDelegate) {
    return oldDelegate.tile != tile ||
           oldDelegate.faceDown != faceDown ||
           oldDelegate.isHorizontal != isHorizontal ||
           oldDelegate.isPlayable != isPlayable;
  }
}

import 'package:flutter/material.dart';
import 'dart:math' as math;

class LudoBoardPainter extends CustomPainter {
  final List<dynamic> tokens;

  LudoBoardPainter({required this.tokens});

  static const List<Offset> _basePath = [
    Offset(1, 6), Offset(2, 6), Offset(3, 6), Offset(4, 6), Offset(5, 6),
    Offset(6, 5), Offset(6, 4), Offset(6, 3), Offset(6, 2), Offset(6, 1), Offset(6, 0),
    Offset(7, 0),
    Offset(8, 0), Offset(8, 1), Offset(8, 2), Offset(8, 3), Offset(8, 4), Offset(8, 5),
    Offset(9, 6), Offset(10, 6), Offset(11, 6), Offset(12, 6), Offset(13, 6), Offset(14, 6),
    Offset(14, 7),
    Offset(14, 8), Offset(13, 8), Offset(12, 8), Offset(11, 8), Offset(10, 8), Offset(9, 8),
    Offset(8, 9), Offset(8, 10), Offset(8, 11), Offset(8, 12), Offset(8, 13), Offset(8, 14),
    Offset(7, 14),
    Offset(6, 14), Offset(6, 13), Offset(6, 12), Offset(6, 11), Offset(6, 10), Offset(6, 9),
    Offset(5, 8), Offset(4, 8), Offset(3, 8), Offset(2, 8), Offset(1, 8), Offset(0, 8),
    Offset(0, 7), Offset(0, 6)
  ];

  static const List<Offset> _redHomePath = [Offset(1, 7), Offset(2, 7), Offset(3, 7), Offset(4, 7), Offset(5, 7), Offset(6, 7)];
  static const List<Offset> _blueHomePath = [Offset(7, 1), Offset(7, 2), Offset(7, 3), Offset(7, 4), Offset(7, 5), Offset(7, 6)];
  static const List<Offset> _yellowHomePath = [Offset(13, 7), Offset(12, 7), Offset(11, 7), Offset(10, 7), Offset(9, 7), Offset(8, 7)];
  static const List<Offset> _greenHomePath = [Offset(7, 13), Offset(7, 12), Offset(7, 11), Offset(7, 10), Offset(7, 9), Offset(7, 8)];

  // Colors
  static const Color redColor = Color(0xFFFF4B4B);
  static const Color blueColor = Color(0xFF4B7BFF);
  static const Color yellowColor = Color(0xFFFFD14B);
  static const Color greenColor = Color(0xFF4BFF8C);
  static const Color pathColor = Color(0xFF1E2128);
  static const Color gridLineColor = Color(0x33FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 15;

    _drawBackground(canvas, size);
    _drawPathTiles(canvas, cellSize);
    _drawHomeColumns(canvas, cellSize);
    
    // Draw Homes
    _drawHomeBase(canvas, cellSize, 0, 0, redColor);
    _drawHomeBase(canvas, cellSize, 9, 0, blueColor);
    _drawHomeBase(canvas, cellSize, 9, 9, yellowColor);
    _drawHomeBase(canvas, cellSize, 0, 9, greenColor);

    // Draw Center
    _drawCenterTriangle(canvas, cellSize);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
        center: Alignment.center,
        radius: 1.0,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(32)),
      bgPaint,
    );
    
    // Ambient Light Glow in the center
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.4,
      Paint()
        ..color = Colors.white.withOpacity(0.03)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50),
    );
  }

  void _drawPathTiles(Canvas canvas, double cellSize) {
    final Paint tilePaint = Paint()
      ..color = pathColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < _basePath.length; i++) {
      final pos = _basePath[i];
      final rect = Rect.fromLTWH(pos.dx * cellSize, pos.dy * cellSize, cellSize, cellSize).deflate(2);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      
      bool isStart = i == 0 || i == 13 || i == 26 || i == 39;
      bool isStar = i == 8 || i == 21 || i == 34 || i == 47;

      // Base tile shadow
      canvas.drawRRect(rrect.shift(const Offset(0, 2)), Paint()..color = Colors.black26);

      if (isStart) {
        Color c = i == 0 ? redColor : (i == 13 ? blueColor : (i == 26 ? yellowColor : greenColor));
        canvas.drawRRect(
          rrect, 
          Paint()..shader = LinearGradient(colors: [c.withOpacity(0.6), c.withOpacity(0.3)]).createShader(rect)
        );
        _drawStar(canvas, rect.center, cellSize * 0.35, c, glowing: true);
      } else if (isStar) {
        canvas.drawRRect(rrect, Paint()..color = Colors.white.withOpacity(0.05));
        _drawStar(canvas, rect.center, cellSize * 0.35, Colors.white54, glowing: true);
      } else {
        canvas.drawRRect(rrect, tilePaint);
      }
      
      // Top Glass Highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.3), const Radius.circular(8)),
        Paint()..color = Colors.white.withOpacity(0.05)
      );
    }
  }

  void _drawHomeColumns(Canvas canvas, double cellSize) {
    _drawColumn(canvas, cellSize, _redHomePath, redColor);
    _drawColumn(canvas, cellSize, _blueHomePath, blueColor);
    _drawColumn(canvas, cellSize, _yellowHomePath, yellowColor);
    _drawColumn(canvas, cellSize, _greenHomePath, greenColor);
  }

  void _drawColumn(Canvas canvas, double cellSize, List<Offset> path, Color color) {
    for (int i = 0; i < path.length - 1; i++) {
      final pos = path[i];
      final rect = Rect.fromLTWH(pos.dx * cellSize, pos.dy * cellSize, cellSize, cellSize).deflate(2);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      
      canvas.drawRRect(rrect.shift(const Offset(0, 2)), Paint()..color = Colors.black26);
      canvas.drawRRect(
        rrect, 
        Paint()..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.7), color.withOpacity(0.3)]
        ).createShader(rect)
      );
      
      // Top Glass Highlight
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height * 0.3), const Radius.circular(8)),
        Paint()..color = Colors.white.withOpacity(0.1)
      );
    }
  }

  void _drawCenterTriangle(Canvas canvas, double cellSize) {
    final Offset center = Offset(7.5 * cellSize, 7.5 * cellSize);
    
    _drawTriangle(canvas, center, Offset(6 * cellSize, 6 * cellSize), Offset(6 * cellSize, 9 * cellSize), redColor);
    _drawTriangle(canvas, center, Offset(6 * cellSize, 6 * cellSize), Offset(9 * cellSize, 6 * cellSize), blueColor);
    _drawTriangle(canvas, center, Offset(9 * cellSize, 6 * cellSize), Offset(9 * cellSize, 9 * cellSize), yellowColor);
    _drawTriangle(canvas, center, Offset(6 * cellSize, 9 * cellSize), Offset(9 * cellSize, 9 * cellSize), greenColor);
  }

  void _drawTriangle(Canvas canvas, Offset p1, Offset p2, Offset p3, Color color) {
    final Path path = Path()..moveTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
    canvas.drawPath(path, Paint()..color = color.withOpacity(0.8));
    canvas.drawPath(path, Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color, {bool glowing = false}) {
    if (glowing) {
      canvas.drawCircle(center, radius * 1.5, Paint()..color = color.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    }
    final Path path = Path();
    const int points = 5;
    final double innerRadius = radius * 0.4;
    
    for (int i = 0; i < points * 2; i++) {
      double r = (i % 2 == 0) ? radius : innerRadius;
      double angle = i * math.pi / points - math.pi / 2;
      Offset pt = Offset(center.dx + r * math.cos(angle), center.dy + r * math.sin(angle));
      if (i == 0) path.moveTo(pt.dx, pt.dy);
      else path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawHomeBase(Canvas canvas, double cellSize, int startCol, int startRow, Color color) {
    final Rect homeRect = Rect.fromLTWH(startCol * cellSize, startRow * cellSize, 6 * cellSize, 6 * cellSize);
    final RRect outerRRect = RRect.fromRectAndRadius(homeRect.deflate(cellSize * 0.2), Radius.circular(cellSize * 0.8));
    
    // Outer Shadow
    canvas.drawRRect(outerRRect.shift(const Offset(0, 10)), Paint()..color = Colors.black38..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15));
    
    // Glass Base
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.1)],
          center: Alignment.topLeft,
          radius: 1.5,
        ).createShader(homeRect)
    );
    
    // Glass Border
    canvas.drawRRect(
      outerRRect,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Inner base (Soft Panel)
    final Rect innerRect = Rect.fromLTWH((startCol + 1.2) * cellSize, (startRow + 1.2) * cellSize, 3.6 * cellSize, 3.6 * cellSize);
    final RRect innerRRect = RRect.fromRectAndRadius(innerRect, Radius.circular(cellSize * 0.6));
    
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
    );
    
    // Inner Border Highlight
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // 4 Token Spots (Inset look)
    _drawSpot(canvas, Offset((startCol + 2.1) * cellSize, (startRow + 2.1) * cellSize), cellSize * 0.5, color);
    _drawSpot(canvas, Offset((startCol + 3.9) * cellSize, (startRow + 2.1) * cellSize), cellSize * 0.5, color);
    _drawSpot(canvas, Offset((startCol + 2.1) * cellSize, (startRow + 3.9) * cellSize), cellSize * 0.5, color);
    _drawSpot(canvas, Offset((startCol + 3.9) * cellSize, (startRow + 3.9) * cellSize), cellSize * 0.5, color);
  }

  void _drawSpot(Canvas canvas, Offset center, double radius, Color color) {
    // Inset Shadow
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.black26..style = PaintingStyle.fill,
    );
    // Spot Color
    canvas.drawCircle(
      center,
      radius * 0.9,
      Paint()..color = color.withOpacity(0.15)..style = PaintingStyle.fill,
    );
    // Border
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
  }

  static Offset getTokenOffset(int localPos, String colorStr, double cellSize, int tokenId) {
    if (localPos == -1) {
      // Return to base spot
      int startCol = 0, startRow = 0;
      if (colorStr == 'blue') { startCol = 9; startRow = 0; }
      if (colorStr == 'yellow') { startCol = 9; startRow = 9; }
      if (colorStr == 'green') { startCol = 0; startRow = 9; }
      
      int spotIdx = tokenId % 4;
      double dx = 2.1;
      double dy = 2.1;
      if (spotIdx == 1) dx = 3.9;
      if (spotIdx == 2) { dx = 2.1; dy = 3.9; }
      if (spotIdx == 3) { dx = 3.9; dy = 3.9; }
      
      return Offset((startCol + dx) * cellSize, (startRow + dy) * cellSize);
    }
    
    // Normal track mapping
    int globalPos = 0;
    List<Offset> homePath = [];
    
    if (colorStr == 'red') {
      globalPos = localPos % 52;
      homePath = _redHomePath;
    } else if (colorStr == 'blue') {
      globalPos = (localPos + 13) % 52;
      homePath = _blueHomePath;
    } else if (colorStr == 'yellow') {
      globalPos = (localPos + 26) % 52;
      homePath = _yellowHomePath;
    } else if (colorStr == 'green') {
      globalPos = (localPos + 39) % 52;
      homePath = _greenHomePath;
    }

    Offset pt;
    if (localPos < 52) {
      pt = _basePath[globalPos];
    } else {
      int homeIdx = localPos - 52;
      if (homeIdx < homePath.length) {
        pt = homePath[homeIdx];
      } else {
        pt = homePath.last;
      }
    }
    
    return Offset(pt.dx * cellSize + cellSize / 2, pt.dy * cellSize + cellSize / 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

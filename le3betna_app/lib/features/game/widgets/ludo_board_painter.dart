import 'package:flutter/material.dart';

class LudoBoardPainter extends CustomPainter {
  final List<dynamic> tokens; // List of LudoToken

  LudoBoardPainter({required this.tokens});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / 15;
    final Paint linePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;

    // Draw base board 15x15
    for (int r = 0; r < 15; r++) {
      for (int c = 0; c < 15; c++) {
        Rect rect = Rect.fromLTWH(c * cellSize, r * cellSize, cellSize, cellSize);
        canvas.drawRect(rect, linePaint);
      }
    }

    // Draw Homes
    _drawHome(canvas, cellSize, 0, 0, Colors.redAccent); // Top Left (Red)
    _drawHome(canvas, cellSize, 9, 0, Colors.blueAccent); // Top Right (Blue)
    _drawHome(canvas, cellSize, 9, 9, Colors.yellowAccent); // Bottom Right
    _drawHome(canvas, cellSize, 0, 9, Colors.greenAccent); // Bottom Left

    // Draw Center
    fillPaint.color = Colors.white12;
    canvas.drawRect(Rect.fromLTWH(6 * cellSize, 6 * cellSize, 3 * cellSize, 3 * cellSize), fillPaint);

    // Draw Safe Zones
    _drawSafeZone(canvas, cellSize, 6, 1, Colors.redAccent); // Red Start
    _drawSafeZone(canvas, cellSize, 8, 2, Colors.white30); // Red Star

    _drawSafeZone(canvas, cellSize, 13, 6, Colors.blueAccent); // Blue Start
    _drawSafeZone(canvas, cellSize, 12, 8, Colors.white30); // Blue Star

    _drawSafeZone(canvas, cellSize, 8, 13, Colors.yellowAccent); // Yellow Start
    _drawSafeZone(canvas, cellSize, 6, 12, Colors.white30); // Yellow Star

    _drawSafeZone(canvas, cellSize, 1, 8, Colors.greenAccent); // Green Start
    _drawSafeZone(canvas, cellSize, 2, 6, Colors.white30); // Green Star

    // Draw tokens
    for (var t in tokens) {
      String colorStr = t['color'];
      int localPos = t['localPosition'];
      Color tColor = Colors.red;
      if (colorStr == 'blue') tColor = Colors.blue;
      
      Offset pos = _getTokenOffset(localPos, colorStr, cellSize);
      final tokenPaint = Paint()..color = tColor;
      canvas.drawCircle(pos, cellSize * 0.4, tokenPaint);
      canvas.drawCircle(pos, cellSize * 0.4, Paint()..color = Colors.white..style=PaintingStyle.stroke..strokeWidth=2);
    }
  }

  void _drawHome(Canvas canvas, double cellSize, int startCol, int startRow, Color color) {
    final Paint fill = Paint()..color = color.withOpacity(0.2);
    final Paint border = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2;
    
    Rect homeRect = Rect.fromLTWH(startCol * cellSize, startRow * cellSize, 6 * cellSize, 6 * cellSize);
    canvas.drawRect(homeRect, fill);
    canvas.drawRect(homeRect, border);

    // Inner white box
    Rect innerRect = Rect.fromLTWH((startCol + 1) * cellSize, (startRow + 1) * cellSize, 4 * cellSize, 4 * cellSize);
    canvas.drawRect(innerRect, Paint()..color = Colors.white.withOpacity(0.1));
  }

  void _drawSafeZone(Canvas canvas, double cellSize, int col, int row, Color color) {
    Rect rect = Rect.fromLTWH(col * cellSize, row * cellSize, cellSize, cellSize);
    canvas.drawRect(rect, Paint()..color = color.withOpacity(0.5));
  }

  final List<List<int>> _path = const [
    [6, 1], [6, 2], [6, 3], [6, 4], [6, 5], [5, 6], [4, 6], [3, 6], [2, 6], [1, 6],
    [0, 7], [1, 8], [2, 8], [3, 8], [4, 8], [5, 8], [6, 9], [6, 10], [6, 11], [6, 12],
    [6, 13], [7, 14], [8, 13], [8, 12], [8, 11], [8, 10], [8, 9], [9, 8], [10, 8], [11, 8],
    [12, 8], [13, 8], [14, 7], [13, 6], [12, 6], [11, 6], [10, 6], [9, 6], [8, 5], [8, 4],
    [8, 3], [8, 2], [8, 1], [7, 0]
  ];

  Offset _getTokenOffset(int localPos, String color, double cellSize) {
    if (localPos == -1) {
      if (color == 'red') return Offset(3 * cellSize, 3 * cellSize);
      if (color == 'blue') return Offset(12 * cellSize, 3 * cellSize);
      if (color == 'yellow') return Offset(12 * cellSize, 12 * cellSize);
      if (color == 'green') return Offset(3 * cellSize, 12 * cellSize);
    }
    
    // Map position
    int index = localPos % _path.length;
    final pt = _path[index];
    
    // add an offset so it is in center of the cell
    return Offset(pt[0] * cellSize + cellSize / 2, pt[1] * cellSize + cellSize / 2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';

class DominoPiece extends StatelessWidget {
  final int value1;
  final int value2;
  final bool isHorizontal;
  final bool isPlayable;
  final bool isDouble;

  const DominoPiece({
    super.key,
    required this.value1,
    required this.value2,
    this.isHorizontal = false,
    this.isPlayable = false,
  }) : isDouble = value1 == value2;

  @override
  Widget build(BuildContext context) {
    // Size config
    final double width = isHorizontal ? (isDouble ? 40 : 80) : 50;
    final double height = isHorizontal ? (isDouble ? 80 : 40) : 100;
    final double dotSize = isHorizontal ? 6 : 8;

    return Opacity(
      opacity: isPlayable ? 1.0 : 0.5,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0), // Ivory white
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isPlayable ? Colors.blueAccent : Colors.black87,
            width: isPlayable ? 3 : 2,
          ),
          boxShadow: isPlayable
              ? [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [
                  const BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 4),
                    blurRadius: 4,
                  )
                ],
        ),
        child: isHorizontal
            ? Row(
                children: [
                  Expanded(child: _buildHalf(value1, dotSize)),
                  Container(width: 2, color: Colors.black),
                  Expanded(child: _buildHalf(value2, dotSize)),
                ],
              )
            : Column(
                children: [
                  Expanded(child: _buildHalf(value1, dotSize)),
                  Container(height: 2, color: Colors.black),
                  Expanded(child: _buildHalf(value2, dotSize)),
                ],
              ),
      ),
    );
  }

  Widget _buildHalf(int value, double dotSize) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _DominoDotsPainter(value, dotSize),
          );
        },
      ),
    );
  }
}

class _DominoDotsPainter extends CustomPainter {
  final int value;
  final double dotSize;

  _DominoDotsPainter(this.value, this.dotSize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final double w = size.width;
    final double h = size.height;
    final double r = dotSize / 2;

    void drawDot(double x, double y) {
      canvas.drawCircle(Offset(x, y), r, paint);
    }

    final double cx = w / 2;
    final double cy = h / 2;
    final double left = w * 0.25;
    final double right = w * 0.75;
    final double top = h * 0.25;
    final double bottom = h * 0.75;

    switch (value) {
      case 1:
        drawDot(cx, cy);
        break;
      case 2:
        drawDot(left, top);
        drawDot(right, bottom);
        break;
      case 3:
        drawDot(left, top);
        drawDot(cx, cy);
        drawDot(right, bottom);
        break;
      case 4:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
      case 5:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(cx, cy);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
      case 6:
        drawDot(left, top);
        drawDot(right, top);
        drawDot(left, cy);
        drawDot(right, cy);
        drawDot(left, bottom);
        drawDot(right, bottom);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

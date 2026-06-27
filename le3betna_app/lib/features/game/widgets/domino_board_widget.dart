import 'package:flutter/material.dart';
import '../../../core/models/domino_models.dart';
import '../../../core/theme/app_theme.dart';
import 'domino_tile_widget.dart';

class DominoBoardWidget extends StatelessWidget {
  final List<PlayedTile> board;
  final Function(bool isLeft) onDrop;
  final bool highlightLeft;
  final bool highlightRight;

  const DominoBoardWidget({
    super.key,
    required this.board,
    required this.onDrop,
    this.highlightLeft = false,
    this.highlightRight = false,
  });

  @override
  Widget build(BuildContext context) {
    // InteractiveViewer allows us to pan and zoom if the board gets too large.
    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(1000),
      minScale: 0.1,
      maxScale: 2.0,
      constrained: false, // allows infinite panning
      child: Center(
        child: SizedBox(
          width: 2000,
          height: 2000,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Draw connecting glowing lines or drop targets if needed
              if (highlightLeft || highlightRight)
                 _buildDropTargets(),

              // 2. Draw all played tiles
              ..._buildTilesLayout(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropTargets() {
    // In a real app, we'd calculate exactly where the ends of the board are.
    // For this prototype, we'll place large glowing drop zones on the left and right.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (highlightLeft)
          DragTarget<DominoTile>(
            onAcceptWithDetails: (details) => onDrop(true),
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.accentTeal.withOpacity(0.5), blurRadius: 30),
                  ]
                ),
                child: const Icon(Icons.arrow_downward, color: AppTheme.accentTeal, size: 40),
              );
            },
          ),
        const SizedBox(width: 800), // spacing between left/right targets based on board size
        if (highlightRight)
          DragTarget<DominoTile>(
            onAcceptWithDetails: (details) => onDrop(false),
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppTheme.accentTeal.withOpacity(0.5), blurRadius: 30),
                  ]
                ),
                child: const Icon(Icons.arrow_downward, color: AppTheme.accentTeal, size: 40),
              );
            },
          )
      ],
    );
  }

  List<Widget> _buildTilesLayout() {
    if (board.isEmpty) return [];

    final List<Widget> widgets = [];
    
    // Simplistic linear layout algorithm for prototype
    // Center is (0,0) in our logical coordinates.
    // X goes left (negative) and right (positive).
    
    double currentLeftX = -30.0;
    double currentRightX = 30.0;
    
    for (int i = 0; i < board.length; i++) {
      final playedTile = board[i];
      final isDouble = playedTile.tile.isDouble;
      final bool isFirst = i == 0;
      
      // Calculate dimensions based on our DominoTileWidget size 50
      final double width = isDouble ? 50.0 : 100.0; // horizontal tile is 100 wide
      final double height = isDouble ? 100.0 : 50.0;
      
      double xOffset = 0;
      double yOffset = 0;

      if (isFirst) {
        xOffset = 0;
      } else {
        // Find if this tile connects to left or right
        // For this UI mockup, we will just alternate or guess based on a property, 
        // but normally the GameService would specify coordinates or 'side' (Left/Right).
        // Since we don't have side in PlayedTile currently, we'll simulate by checking if it matches left/right.
        // Assuming the list is ordered and we know which side it was added to.
        // For now, let's just lay them out linearly outwards.
        if (i % 2 != 0) { // arbitrary left
          currentLeftX -= width;
          xOffset = currentLeftX;
        } else { // arbitrary right
          xOffset = currentRightX;
          currentRightX += width;
        }
      }

      widgets.add(
        Positioned(
          left: 1000 + xOffset - (width / 2),
          top: 1000 + yOffset - (height / 2),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: child,
              );
            },
            child: DominoTileWidget(
              tile: playedTile.tile,
              size: 50,
              isHorizontal: !isDouble,
            ),
          ),
        )
      );
    }
    
    return widgets;
  }
}

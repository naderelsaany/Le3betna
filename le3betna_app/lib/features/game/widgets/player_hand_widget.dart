import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/domino_models.dart';
import 'domino_tile_widget.dart';
import 'dart:math' as math;

class PlayerHandWidget extends StatelessWidget {
  final List<DominoTile> hand;
  final DominoTile? selectedTile;
  final DominoTile? illegalTile;
  final Function(DominoTile) onTileTap;
  final Function(DominoTile) onTileDragStarted;
  final List<DominoTile> playableTiles;

  const PlayerHandWidget({
    super.key,
    required this.hand,
    required this.selectedTile,
    required this.illegalTile,
    required this.onTileTap,
    required this.onTileDragStarted,
    required this.playableTiles,
  });

  @override
  Widget build(BuildContext context) {
    if (hand.isEmpty) return const SizedBox.shrink();

    final double screenWidth = MediaQuery.of(context).size.width;
    final int count = hand.length;
    
    // We want the tiles to spread nicely.
    // If we have 7 tiles, we spread them across the screen.
    // We use a Stack to overlap them slightly in an arc.
    
    final double maxSpread = math.min(screenWidth * 0.8, 400.0);
    final double step = count > 1 ? maxSpread / (count - 1) : 0;
    final double startX = -(maxSpread / 2);

    return SizedBox(
      height: 140,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: List.generate(count, (index) {
          final tile = hand[index];
          final bool isSelected = tile == selectedTile;
          final bool isIllegal = tile == illegalTile;
          final bool isPlayable = playableTiles.contains(tile);
          
          // Calculate Arc (Fan shape)
          final double currentX = startX + (index * step);
          // Parabola for Y (lower at edges, higher in middle)
          final double normalizedX = count > 1 ? (index / (count - 1)) * 2 - 1 : 0; // -1 to 1
          final double yOffset = (normalizedX * normalizedX) * 20; // 0 at center, 20 at edges
          
          // Rotation (tilt tiles slightly based on position)
          final double rotation = normalizedX * 0.2; // roughly -11 degrees to +11 degrees

          return Positioned(
            bottom: isSelected ? 30 - yOffset : 10 - yOffset,
            left: (screenWidth / 2) + currentX - 25, // 25 is half tile width
            child: Transform.rotate(
              angle: isSelected ? 0 : rotation,
              child: Draggable<DominoTile>(
                data: tile,
                onDragStarted: () {
                  HapticFeedback.lightImpact();
                  onTileDragStarted(tile);
                },
                feedback: Transform.scale(
                  scale: 1.2,
                  child: DominoTileWidget(
                    tile: tile,
                    isPlayable: isPlayable,
                    isSelected: true,
                    size: 50,
                  ),
                ),
                childWhenDragging: Opacity(
                  opacity: 0.2,
                  child: DominoTileWidget(
                    tile: tile,
                    isPlayable: false,
                    size: 50,
                  ),
                ),
                child: DominoTileWidget(
                  tile: tile,
                  isPlayable: isPlayable,
                  isSelected: isSelected,
                  isIllegal: isIllegal,
                  size: 50,
                  onTap: () => onTileTap(tile),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

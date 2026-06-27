import 'package:flutter/material.dart';
import '../../../core/models/domino_models.dart';
import '../../../core/theme/app_theme.dart';
import 'domino_tile_widget.dart';

class DominoBoardWidget extends StatefulWidget {
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
  State<DominoBoardWidget> createState() => _DominoBoardWidgetState();
}

class _DominoBoardWidgetState extends State<DominoBoardWidget> {
  final TransformationController _transformationController = TransformationController();
  bool _initialized = false;

  // Tile dimensions (matches DominoTileWidget size: width=size, height=size*2)
  static const double _tileSize = 50.0;
  static const double _hTileWidth = _tileSize * 2;   // 100
  static const double _hTileHeight = _tileSize;       // 50
  static const double _vTileWidth = _tileSize;        // 50
  static const double _vTileHeight = _tileSize * 2;   // 100
  static const double _tileGap = 2.0;                 // tight chain look

  double _tileHorizontalExtent(PlayedTile t) =>
      t.tile.isDouble ? _vTileWidth : _hTileWidth;

  DominoTile _toVisualTile(PlayedTile p) {
    if (!p.reversed) return p.tile;
    return DominoTile(
      value1: p.tile.value2,
      value2: p.tile.value1,
      id: p.tile.id,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_initialized) {
          _initialized = true;
          // Center the 4000x4000 board in the viewport
          final dx = constraints.maxWidth / 2 - 2000;
          final dy = constraints.maxHeight / 2 - 2000;
          _transformationController.value = Matrix4.identity()..translate(dx, dy);
        }
        
        return InteractiveViewer(
          transformationController: _transformationController,
          boundaryMargin: const EdgeInsets.all(2000),
          minScale: 0.1,
          maxScale: 2.0,
          constrained: false,
          child: SizedBox(
            width: 4000,
            height: 4000,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (widget.highlightLeft || widget.highlightRight) _buildDropTargets(),
                ..._buildTilesLayout(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropTargets() {
    // Position drop targets just outside the actual leftmost / rightmost tile.
    final double leftEdge = _boardLeftEdge();
    final double rightEdge = _boardRightEdge();
    const double targetSize = 90.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (widget.highlightLeft)
          Positioned(
            left: leftEdge - targetSize - 4,
            top: 2000 - targetSize / 2,
            child: DragTarget<DominoTile>(
              onAcceptWithDetails: (_) => widget.onDrop(true),
              builder: (context, _, __) => Container(
                width: targetSize,
                height: targetSize,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentTeal.withOpacity(0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: AppTheme.accentTeal,
                  size: 36,
                ),
              ),
            ),
          ),
        if (widget.highlightRight)
          Positioned(
            left: rightEdge + 4,
            top: 2000 - targetSize / 2,
            child: DragTarget<DominoTile>(
              onAcceptWithDetails: (_) => widget.onDrop(false),
              builder: (context, _, __) => Container(
                width: targetSize,
                height: targetSize,
                decoration: BoxDecoration(
                  color: AppTheme.accentTeal.withOpacity(0.2),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentTeal.withOpacity(0.5),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: AppTheme.accentTeal,
                  size: 36,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildTilesLayout() {
    if (widget.board.isEmpty) return [];

    // Total width of the chain in local coords (centered around 0)
    double totalWidth = 0;
    for (final t in widget.board) {
      totalWidth += _tileHorizontalExtent(t) + _tileGap;
    }
    totalWidth -= _tileGap;

    // Start at the leftmost x in local coords (centered around 0)
    double currentX = -totalWidth / 2;

    final List<Widget> widgets = [];
    for (int i = 0; i < widget.board.length; i++) {
      final playedTile = widget.board[i];
      final isDouble = playedTile.tile.isDouble;
      final double tileWidth = isDouble ? _vTileWidth : _hTileWidth;
      final double tileHeight = isDouble ? _vTileHeight : _hTileHeight;
      final DominoTile visualTile = _toVisualTile(playedTile);

      widgets.add(
        Positioned(
          key: ValueKey('board_tile_${visualTile.id}'),
          left: 2000 + currentX,
          top: 2000 - tileHeight / 2,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: DominoTileWidget(
              tile: visualTile,
              size: _tileSize,
              isHorizontal: !isDouble,
            ),
          ),
        ),
      );

      currentX += tileWidth + _tileGap;
    }
    return widgets;
  }

  /// X coordinate of the LEFT edge of the first (leftmost) tile, in Stack
  /// pixel coordinates. Returns 0 for empty board.
  double _boardLeftEdge() {
    if (widget.board.isEmpty) return 0;
    double totalWidth = 0;
    for (final t in widget.board) {
      totalWidth += _tileHorizontalExtent(t) + _tileGap;
    }
    totalWidth -= _tileGap;
    return 2000 - totalWidth / 2;
  }

  /// X coordinate of the RIGHT edge of the last (rightmost) tile, in Stack
  /// pixel coordinates. Returns 0 for empty board.
  double _boardRightEdge() {
    if (widget.board.isEmpty) return 0;
    double totalWidth = 0;
    for (final t in widget.board) {
      totalWidth += _tileHorizontalExtent(t) + _tileGap;
    }
    totalWidth -= _tileGap;
    return 2000 + totalWidth / 2;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';

class PopularGamesCarousel extends StatelessWidget {
  final Function(String) onGameSelected;

  const PopularGamesCarousel({super.key, required this.onGameSelected});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الألعاب المتاحة',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'عرض الكل',
                style: TextStyle(color: AppTheme.accentRed, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md16),
        SizedBox(
          height: 220,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg24),
            children: [
              _GameCarouselCard(
                title: 'دومينو مصري',
                imagePath: 'assets/images/domino.webp',
                glowColor: AppTheme.accentRed,
                playersOnline: 'جاهزة للعب',
                onTap: () => onGameSelected('دومينو'),
              ),
              const SizedBox(width: AppSpacing.md16),
              _GameCarouselCard(
                title: 'لودو',
                imagePath: 'assets/images/ludo.webp',
                glowColor: AppTheme.accentGold,
                playersOnline: 'جاهزة للعب',
                onTap: () => onGameSelected('لودو'),
              ),
              const SizedBox(width: AppSpacing.md16),
              _GameCarouselCard(
                title: 'أربعة في صف',
                imagePath: 'assets/images/connect4.webp',
                glowColor: AppTheme.accentTeal,
                playersOnline: 'جاهزة للعب',
                onTap: () => onGameSelected('٤ في صف'),
              ),
              const SizedBox(width: AppSpacing.md16),
              _GameCarouselCard(
                title: '🧪 اختبار',
                imagePath: 'assets/images/connect4.webp', // We reuse connect4 image for testing
                glowColor: Colors.deepPurpleAccent,
                playersOnline: 'تجربة المطور',
                onTap: () => onGameSelected('test_game'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GameCarouselCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final Color glowColor;
  final String playersOnline;
  final VoidCallback onTap;

  const _GameCarouselCard({
    required this.title,
    required this.imagePath,
    required this.glowColor,
    required this.playersOnline,
    required this.onTap,
  });

  @override
  State<_GameCarouselCard> createState() => _GameCarouselCardState();
}

class _GameCarouselCardState extends State<_GameCarouselCard> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
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
        setState(() => _isHovered = true);
        HapticFeedback.selectionClick();
      },
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: (_) => _scaleController.reverse(),
        onTapUp: (_) {
          _scaleController.animateTo(1.0, curve: Curves.elasticOut);
          HapticFeedback.heavyImpact();
          widget.onTap();
        },
        onTapCancel: () => _scaleController.animateTo(1.0, curve: Curves.elasticOut),
        child: ScaleTransition(
          scale: _scaleController,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 160,
            transform: Matrix4.identity()..translate(0.0, _isHovered ? -8.0 : 0.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: _isHovered ? [
                BoxShadow(
                  color: widget.glowColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                )
              ] : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(widget.imagePath, fit: BoxFit.cover),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.9),
                          Colors.black.withOpacity(_isHovered ? 0.2 : 0.5),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: widget.glowColor.withOpacity(0.6), width: 2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                            shadows: [
                              Shadow(color: widget.glowColor, blurRadius: 10),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.circle, color: Colors.greenAccent, size: 8),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.playersOnline,
                                style: const TextStyle(color: Colors.white70, fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

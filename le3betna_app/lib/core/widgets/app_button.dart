import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/animation_constants.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AppAnimations.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null || widget.isLoading;

    // Determine colors based on variant
    Color bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow>? shadows;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        bgColor = AppTheme.accentRed;
        textColor = Colors.white;
        if (!isDisabled) {
          // Subtle glow
          shadows = [
            BoxShadow(
              color: AppTheme.accentRed.withOpacity(0.25),
              blurRadius: 32,
              offset: const Offset(0, 8),
            )
          ];
        }
        break;
      case AppButtonVariant.secondary:
        bgColor = Colors.transparent;
        textColor = AppTheme.accentRed;
        border = Border.all(color: AppTheme.accentRed, width: 1.5);
        break;
      case AppButtonVariant.ghost:
        bgColor = _isHovered ? AppTheme.bgPanel : Colors.transparent;
        textColor = Colors.white;
        break;
    }

    Widget content = widget.isLoading
        ? const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppTheme.accentGold,
              strokeWidth: 2.5,
            ),
          )
        : Text(
            widget.text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: isDisabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: AnimatedOpacity(
            duration: AppAnimations.fast,
            opacity: isDisabled ? 0.5 : 1.0,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              curve: AppAnimations.easeOut,
              height: 52,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
                border: border,
                boxShadow: shadows,
              ),
              alignment: Alignment.center,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

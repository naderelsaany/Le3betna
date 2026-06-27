import 'package:flutter/material.dart';

class TransientWidget extends StatefulWidget {
  final String emoji;
  final VoidCallback onComplete;

  const TransientWidget({super.key, required this.emoji, required this.onComplete});

  @override
  State<TransientWidget> createState() => _TransientWidgetState();
}

class _TransientWidgetState extends State<TransientWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));

    _positionAnimation = Tween<Offset>(
      begin: const Offset(0, -2), // Start from opponent side (top)
      end: const Offset(0, 1),    // End near my hand (bottom)
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInQuad));

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 2.0).chain(CurveTween(curve: Curves.easeOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 2.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 70),
    ]).animate(_controller);

    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller);

    _controller.forward().then((_) {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _positionAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Text(widget.emoji, style: const TextStyle(fontSize: 80)),
        ),
      ),
    );
  }
}

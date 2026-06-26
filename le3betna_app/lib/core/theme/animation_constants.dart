import 'package:flutter/animation.dart';

/// Animation System for Le3betna
class AppAnimations {
  // Timing (Durations)
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration dramatic = Duration(milliseconds: 1000);

  // Curves
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve gravity = Curves.easeIn;
  static const Curve spring = Curves.fastOutSlowIn;
}

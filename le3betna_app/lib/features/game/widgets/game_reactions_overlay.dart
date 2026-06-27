import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import 'dart:math' as math;

class GameReactionsOverlay extends StatefulWidget {
  final Widget child;
  final Stream<ReactionEvent>? reactionStream;
  final Function(String emoji, String targetUid)? onReactionSent;
  final Function(String message)? onChatSent;

  const GameReactionsOverlay({
    super.key,
    required this.child,
    this.reactionStream,
    this.onReactionSent,
    this.onChatSent,
  });

  @override
  State<GameReactionsOverlay> createState() => _GameReactionsOverlayState();
}

class _GameReactionsOverlayState extends State<GameReactionsOverlay> with TickerProviderStateMixin {
  final List<_ActiveReaction> _activeReactions = [];
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    widget.reactionStream?.listen((event) {
      _triggerReaction(event.emoji);
    });
  }

  void _triggerReaction(String emoji) {
    HapticFeedback.lightImpact();
    final controller = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    final reaction = _ActiveReaction(emoji: emoji, controller: controller);
    
    setState(() => _activeReactions.add(reaction));
    
    controller.forward().then((_) {
      if (mounted) {
        setState(() => _activeReactions.remove(reaction));
        controller.dispose();
      }
    });
  }

  void _toggleMenu() {
    HapticFeedback.selectionClick();
    setState(() => _showMenu = !_showMenu);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Flying Reactions
        ..._activeReactions.map((reaction) {
          return AnimatedBuilder(
            animation: reaction.controller,
            builder: (context, child) {
              final double progress = reaction.controller.value;
              // Parabolic path upwards
              final double dx = math.sin(progress * math.pi) * 100;
              final double dy = -progress * 500;
              final double scale = math.sin(progress * math.pi) * 2; // scale up then down
              final double opacity = (1.0 - progress).clamp(0.0, 1.0);

              return Positioned(
                bottom: 200 + dy,
                left: MediaQuery.of(context).size.width / 2 + dx - 50,
                child: Transform.scale(
                  scale: scale,
                  child: Opacity(
                    opacity: opacity,
                    child: Text(reaction.emoji, style: const TextStyle(fontSize: 50)),
                  ),
                ),
              );
            },
          );
        }),

        // Reaction & Chat Menu Button
        Positioned(
          bottom: 180,
          right: AppSpacing.md16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_showMenu) ...[
                _buildReactionMenu(),
                const SizedBox(height: AppSpacing.md16),
              ],
              FloatingActionButton(
                heroTag: 'reaction_fab',
                mini: true,
                backgroundColor: AppTheme.bgPanel,
                child: Icon(_showMenu ? Icons.close : Icons.emoji_emotions, color: AppTheme.accentGold),
                onPressed: _toggleMenu,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReactionMenu() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm8),
      decoration: BoxDecoration(
        color: AppTheme.bgCard.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderTransparent),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ReactionButton(emoji: '🍅', onTap: () => _sendReaction('🍅')),
              _ReactionButton(emoji: '🩴', onTap: () => _sendReaction('🩴')),
              _ReactionButton(emoji: '😂', onTap: () => _sendReaction('😂')),
              _ReactionButton(emoji: '🔥', onTap: () => _sendReaction('🔥')),
              _ReactionButton(emoji: '❤️', onTap: () => _sendReaction('❤️')),
            ],
          ),
          const Divider(color: AppTheme.borderTransparent),
          Wrap(
            spacing: 8,
            children: [
              _ChatButton(text: 'يلا', onTap: () => _sendChat('يلا')),
              _ChatButton(text: 'دورك', onTap: () => _sendChat('دورك')),
              _ChatButton(text: 'هاتها', onTap: () => _sendChat('هاتها')),
            ],
          )
        ],
      ),
    );
  }

  void _sendReaction(String emoji) {
    _toggleMenu();
    widget.onReactionSent?.call(emoji, 'all');
    _triggerReaction(emoji); // show locally immediately
  }
  
  void _sendChat(String text) {
    _toggleMenu();
    widget.onChatSent?.call(text);
    // In a real app, this would show up as a speech bubble next to the avatar
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('أنت: $text'),
      backgroundColor: AppTheme.accentTeal,
      duration: const Duration(seconds: 1),
    ));
  }
}

class _ReactionButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _ReactionButton({required this.emoji, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
      onPressed: onTap,
    );
  }
}

class _ChatButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _ChatButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      backgroundColor: AppTheme.bgDeep,
      side: const BorderSide(color: AppTheme.borderTransparent),
      onPressed: onTap,
    );
  }
}

class ReactionEvent {
  final String emoji;
  final String senderUid;
  ReactionEvent(this.emoji, this.senderUid);
}

class _ActiveReaction {
  final String emoji;
  final AnimationController controller;
  _ActiveReaction({required this.emoji, required this.controller});
}

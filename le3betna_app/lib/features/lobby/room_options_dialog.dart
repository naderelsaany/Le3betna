import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/room_service.dart';
import 'lobby_screen.dart';

class RoomOptionsDialog extends StatefulWidget {
  final String gameName;
  const RoomOptionsDialog({super.key, required this.gameName});

  @override
  State<RoomOptionsDialog> createState() => _RoomOptionsDialogState();
}

class _RoomOptionsDialogState extends State<RoomOptionsDialog> with SingleTickerProviderStateMixin {
  final _roomService = RoomService();
  bool _isCreating = false;
  bool _isJoining = false;
  final _codeController = TextEditingController();
  late AnimationController _appearController;

  @override
  void initState() {
    super.initState();
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _appearController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    HapticFeedback.heavyImpact();
    setState(() => _isCreating = true);
    try {
      final roomCode = await _roomService.createRoom(widget.gameName);
      if (mounted) {
        setState(() => _isCreating = false);
        if (roomCode != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم إنشاء الغرفة بنجاح!'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppTheme.accentTeal.withOpacity(0.9),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LobbyScreen(roomCode: roomCode, isHost: true, gameName: widget.gameName)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  Future<void> _joinRoom() async {
    HapticFeedback.heavyImpact();
    final code = _codeController.text.trim();
    if (code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('الكود يجب أن يتكون من 4 أرقام'),
          backgroundColor: AppTheme.accentRed.withOpacity(0.9),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isJoining = true);
    try {
      final success = await _roomService.joinRoom(code);
      if (mounted) {
        setState(() => _isJoining = false);
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم الانضمام بنجاح!'),
              backgroundColor: AppTheme.accentTeal.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LobbyScreen(roomCode: code, isHost: false, gameName: widget.gameName)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('لم يتم العثور على الغرفة أو أنها ممتلئة'),
              backgroundColor: AppTheme.accentGold.withOpacity(0.9),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}'), backgroundColor: AppTheme.accentRed),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBusy = _isCreating || _isJoining;
    
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ScaleTransition(
          scale: CurvedAnimation(parent: _appearController, curve: Curves.elasticOut),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl32),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.borderTransparent),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        widget.gameName,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: AppTheme.accentRed.withOpacity(0.6), blurRadius: 15),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl32),
                      
                      // Create Room Button
                      _AnimatedButton(
                        onPressed: isBusy ? null : _createRoom,
                        color: AppTheme.accentRed,
                        icon: _isCreating 
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                            : const Icon(Icons.add_circle_rounded, size: 28, color: Colors.white),
                        label: 'إنشاء غرفة جديدة',
                      ),
                      
                      const SizedBox(height: AppSpacing.lg24),
                      const Row(
                        children: [
                          Expanded(child: Divider(color: AppTheme.borderTransparent)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md16),
                            child: Text('أو الانضمام لغرفة', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold)),
                          ),
                          Expanded(child: Divider(color: AppTheme.borderTransparent)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg24),
                      
                      // Join Room Input
                      TextField(
                        controller: _codeController,
                        decoration: InputDecoration(
                          labelText: 'كود الغرفة',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppTheme.accentGold.withOpacity(0.8), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.password_rounded, color: AppTheme.accentGold),
                        ),
                        style: const TextStyle(
                          fontSize: 24, 
                          letterSpacing: 8, 
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      
                      // Join Room Button
                      _AnimatedButton(
                        onPressed: isBusy ? null : _joinRoom,
                        color: AppTheme.accentGold,
                        icon: _isJoining
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.group_add_rounded, size: 28, color: Colors.white),
                        label: 'انضمام',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Color color;
  final Widget icon;
  final String label;

  const _AnimatedButton({
    required this.onPressed,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;

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

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _scaleController.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _scaleController.animateTo(1.0, curve: Curves.elasticOut);
      widget.onPressed!();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null) {
      _scaleController.animateTo(1.0, curve: Curves.elasticOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleController,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md16),
          decoration: BoxDecoration(
            color: isDisabled ? widget.color.withOpacity(0.5) : widget.color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled ? [] : [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.icon,
              const SizedBox(width: AppSpacing.sm8),
              Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

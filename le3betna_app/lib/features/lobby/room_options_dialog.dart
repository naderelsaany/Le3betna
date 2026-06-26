import 'package:flutter/material.dart';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/services/room_service.dart';
import 'lobby_screen.dart';

class RoomOptionsDialog extends StatefulWidget {
  final String gameName;
  const RoomOptionsDialog({super.key, required this.gameName});

  @override
  State<RoomOptionsDialog> createState() => _RoomOptionsDialogState();
}

class _RoomOptionsDialogState extends State<RoomOptionsDialog> {
  final _roomService = RoomService();
  bool _isCreating = false;
  bool _isJoining = false;
  final _codeController = TextEditingController();

  Future<void> _createRoom() async {
    setState(() => _isCreating = true);
    try {
      final roomCode = await _roomService.createRoom(widget.gameName);
      if (mounted) {
        setState(() => _isCreating = false);
        if (roomCode != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم إنشاء الغرفة بنجاح!')),
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
          SnackBar(content: Text('خطأ: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _joinRoom() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الكود يجب أن يتكون من 6 أرقام')),
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
            const SnackBar(content: Text('تم الانضمام بنجاح!')),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LobbyScreen(roomCode: code, isHost: false, gameName: widget.gameName)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم العثور على الغرفة أو أنها ممتلئة')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isJoining = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isBusy = _isCreating || _isJoining;
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withOpacity(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.gameName,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: AppTheme.accentRed, blurRadius: 10)],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: isBusy ? null : _createRoom,
                icon: _isCreating 
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
                    : const Icon(Icons.add_circle_outline, size: 24),
                label: const Text('إنشاء غرفة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppTheme.accentRed.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('أو الانضمام لغرفة', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'كود الغرفة',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.accentGold, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.password, color: AppTheme.accentGold),
                ),
                style: const TextStyle(fontSize: 20, letterSpacing: 4, fontWeight: FontWeight.bold),
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isBusy ? null : _joinRoom,
                icon: _isJoining
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.group_add),
                label: const Text('انضمام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentGold,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                  shadowColor: AppTheme.accentGold.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

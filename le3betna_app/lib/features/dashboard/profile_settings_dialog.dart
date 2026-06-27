import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:ui';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/avatar_utils.dart' as import_avatar_utils;

class ProfileSettingsDialog extends StatefulWidget {
  const ProfileSettingsDialog({super.key});

  @override
  State<ProfileSettingsDialog> createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _newPhotoUrl;
  late AnimationController _appearController;

  @override
  void initState() {
    super.initState();
    _nameController.text = _auth.currentUser?.displayName ?? '';
    _newPhotoUrl = _auth.currentUser?.photoURL;
    
    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    HapticFeedback.mediumImpact();
  }
  
  @override
  void dispose() {
    _appearController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickAndCompressImage() async {
    HapticFeedback.lightImpact();
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 150,
      maxHeight: 150,
      imageQuality: 20, // أقصى ضغط عشان المساحة
    );

    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final bytes = await pickedFile.readAsBytes();
        final base64String = base64Encode(bytes);
        final dataUri = 'data:image/jpeg;base64,$base64String';
        setState(() {
          _newPhotoUrl = dataUri;
        });
        HapticFeedback.selectionClick();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('حدث خطأ أثناء معالجة الصورة'), backgroundColor: AppTheme.accentRed)
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    HapticFeedback.heavyImpact();
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        
        // Save to Firebase Realtime Database to ensure Dashboard sees it
        final dbRef = FirebaseDatabase.instance.ref().child('users/${user.uid}/stats');
        await dbRef.update({
          'name': newName,
          if (_newPhotoUrl != null && _newPhotoUrl != user.photoURL) 'avatarUrl': _newPhotoUrl,
        });

        // Also try to update Auth Photo URL (might fail if base64 is too long, but we try)
        if (_newPhotoUrl != null && _newPhotoUrl != user.photoURL && _newPhotoUrl!.length < 8000) {
          try {
             await user.updatePhotoURL(_newPhotoUrl);
          } catch (e) {
             // Ignore if Auth fails to save long base64
          }
        }
      }
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('فشل تحديث الملف الشخصي'), backgroundColor: AppTheme.accentRed)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    children: [
                      Text(
                        'تعديل الحساب',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          shadows: [
                            Shadow(color: AppTheme.accentRed.withOpacity(0.6), blurRadius: 15),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl32),
                      
                      // Avatar Section
                      GestureDetector(
                        onTap: _isLoading ? null : _pickAndCompressImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [AppTheme.accentRed, AppTheme.accentGold],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.accentRed.withOpacity(0.3), 
                                    blurRadius: 20,
                                    spreadRadius: 2
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 45,
                                backgroundColor: AppTheme.bgDeep,
                                backgroundImage: _newPhotoUrl != null ? import_avatar_utils.AvatarUtils.getImageProvider(_newPhotoUrl) : null,
                                child: _newPhotoUrl == null 
                                    ? const Icon(Icons.person_rounded, size: 45, color: Colors.white) 
                                    : null,
                              ),
                            ),
                            if (_isLoading)
                              const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                            else
                              Positioned(
                                bottom: 0,
                                left: 0, // Left in RTL means visually right
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 5),
                                    ]
                                  ),
                                  child: const Icon(Icons.add_a_photo_rounded, size: 18, color: Colors.white),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm8),
                      const Text('اضغط لتغيير صورتك', style: TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.bold)),
                      
                      const SizedBox(height: AppSpacing.xl32),
                      
                      // Name TextField
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'اسم اللاعب',
                          labelStyle: const TextStyle(color: AppTheme.textSecondary),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppTheme.accentRed.withOpacity(0.8), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.edit_rounded, color: AppTheme.accentRed),
                        ),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: AppSpacing.xl32),
                      
                      // Save Button
                      _AnimatedSaveButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: AppSpacing.md16),
                      
                      // Logout Button
                      TextButton.icon(
                        onPressed: () async {
                          HapticFeedback.heavyImpact();
                          await FirebaseAuth.instance.signOut();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                        icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                        label: const Text('تسجيل خروج', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                          backgroundColor: Colors.white.withOpacity(0.05),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
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

class _AnimatedSaveButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AnimatedSaveButton({required this.onPressed, required this.isLoading});

  @override
  State<_AnimatedSaveButton> createState() => _AnimatedSaveButtonState();
}

class _AnimatedSaveButtonState extends State<_AnimatedSaveButton> with SingleTickerProviderStateMixin {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md16),
          decoration: BoxDecoration(
            color: isDisabled ? AppTheme.accentRed.withOpacity(0.5) : AppTheme.accentRed,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDisabled ? [] : [
              BoxShadow(
                color: AppTheme.accentRed.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isLoading)
                const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              else
                const Icon(Icons.save_rounded, color: Colors.white, size: 24),
              if (!widget.isLoading) const SizedBox(width: AppSpacing.sm8),
              if (!widget.isLoading)
                const Text(
                  'حفظ التعديلات',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

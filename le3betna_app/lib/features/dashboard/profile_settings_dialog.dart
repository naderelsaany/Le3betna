import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../../core/theme/app_theme.dart';

class ProfileSettingsDialog extends StatefulWidget {
  const ProfileSettingsDialog({super.key});

  @override
  State<ProfileSettingsDialog> createState() => _ProfileSettingsDialogState();
}

class _ProfileSettingsDialogState extends State<ProfileSettingsDialog> {
  final _nameController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  String? _newPhotoUrl;

  @override
  void initState() {
    super.initState();
    _nameController.text = _auth.currentUser?.displayName ?? '';
    _newPhotoUrl = _auth.currentUser?.photoURL;
  }

  Future<void> _pickAndCompressImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 200,
      maxHeight: 200,
      imageQuality: 50, 
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
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء معالجة الصورة')));
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        if (_newPhotoUrl != null && _newPhotoUrl != user.photoURL) {
          await user.updatePhotoURL(_newPhotoUrl);
        }
      }
      if (mounted) {
        Navigator.pop(context, true); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل تحديث الملف الشخصي')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            children: [
              Text(
                'تعديل الحساب',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [const Shadow(color: AppTheme.accentRed, blurRadius: 10)],
                ),
              ),
              const SizedBox(height: 24),
              
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
                          colors: [AppTheme.accentRed, Colors.purpleAccent],
                        ),
                        boxShadow: [
                          BoxShadow(color: AppTheme.accentRed.withOpacity(0.3), blurRadius: 15),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 45,
                        backgroundColor: AppTheme.bgDeep,
                        backgroundImage: _newPhotoUrl != null ? NetworkImage(_newPhotoUrl!) : null,
                        child: _newPhotoUrl == null 
                            ? const Icon(Icons.person, size: 45, color: Colors.white) 
                            : null,
                      ),
                    ),
                    if (_isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text('اضغط لتغيير الصورة (مضغوطة تلقائياً)', style: TextStyle(color: Colors.white54, fontSize: 12)),
              
              const SizedBox(height: 24),
              
              // Name TextField
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'اسم اللاعب',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppTheme.accentRed, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.edit, color: AppTheme.accentRed),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text('حفظ التعديلات', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppTheme.accentRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

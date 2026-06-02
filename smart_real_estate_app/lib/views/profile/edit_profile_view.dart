import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/api_service.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _saving = false;
  Uint8List? _pickedImageBytes;

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    XFile? image;
    try {
      if (!kIsWeb) {
        final source = await showModalBottomSheet<ImageSource>(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('الكاميرا'),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('المعرض'),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
        if (source != null) {
          image = await picker.pickImage(source: source, imageQuality: 70, maxWidth: 400, maxHeight: 400);
        }
      } else {
        image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 400, maxHeight: 400);
      }
    } catch (_) {
      image = null;
    }
    if (image != null && mounted) {
      final bytes = await image.readAsBytes();
      setState(() => _pickedImageBytes = bytes);
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Widget _buildAvatarWidget(AuthProvider auth, List<Color> gradient) {
    final user = auth.currentUser;
    final name = user?.name ?? 'U';

    Widget avatarContent;
    if (_pickedImageBytes != null) {
      avatarContent = Image.memory(
        _pickedImageBytes!,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
      );
    } else if (user?.avatar != null && user!.avatar!.startsWith('data:image')) {
      try {
        final base64Str = user.avatar!.split(',')[1];
        avatarContent = Image.memory(
          base64Decode(base64Str),
          fit: BoxFit.cover,
          width: 110,
          height: 110,
        );
      } catch (_) {
        avatarContent = _initialAvatar(name);
      }
    } else if (user?.avatar != null && user!.avatar!.startsWith('http')) {
      avatarContent = Image.network(
        user.avatar!,
        fit: BoxFit.cover,
        width: 110,
        height: 110,
        errorBuilder: (_, __, ___) => _initialAvatar(name),
      );
    } else {
      avatarContent = _initialAvatar(name);
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: _pickProfileImage,
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradient.first.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(child: avatarContent),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickProfileImage,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _initialAvatar(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 42,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final primary = themeProvider.currentScheme.primary;
    final secondary = themeProvider.currentScheme.secondary;
    final gradient = [primary, secondary];

    return Scaffold(
      appBar: AppBar(title: Text(l.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(child: _buildAvatarWidget(auth, gradient)),
              const SizedBox(height: 8),
              Text(
                l.isArabic ? 'اضغط لتغيير الصورة' : 'Tap to change photo',
                style: GoogleFonts.cairo(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l.fullName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (v) => v == null || v.isEmpty ? l.enterName : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(
                  labelText: l.isArabic ? 'نبذة عنك' : 'About you',
                  prefixIcon: const Icon(Icons.info_outline),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saving ? null : () async {
                    if (!_formKey.currentState!.validate()) return;
                    final user = auth.currentUser;
                    if (user == null) return;
                    setState(() => _saving = true);

                    String? avatarData = user.avatar;
                    if (_pickedImageBytes != null) {
                      avatarData = 'data:image/jpeg;base64,${base64Encode(_pickedImageBytes!)}';
                    }

                    final updatedUser = user.copyWith(
                      name: _nameController.text,
                      phone: _phoneController.text,
                      bio: _bioController.text,
                      avatar: avatarData,
                    );
                    await auth.updateUser(updatedUser);
                    ApiService.updateUser({
                      'id': user.id,
                      'name': _nameController.text,
                      'phone': _phoneController.text,
                      'bio': _bioController.text,
                      if (avatarData != null) 'avatar': avatarData,
                    }, saveToSession: false);
                    if (!mounted) return;
                    setState(() => _saving = false);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l.isArabic
                            ? 'تم تحديث الملف الشخصي بنجاح'
                            : 'Profile updated successfully'),
                        backgroundColor: const Color(0xFF2ECC71),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: _saving
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(l.save, style: const TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

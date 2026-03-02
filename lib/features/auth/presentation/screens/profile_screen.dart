import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/auth_providers.dart';
import '../notifier/profile_state.dart';
import '../../../../core/widgets/custom_button.dart';
import 'login_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  final _passwordController = TextEditingController();
  File? _imageFile;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _handleUpdate() {
    if (_formKey.currentState!.validate()) {
      final user = ref.read(currentUserProvider);
      if (user == null || user.token == null) {
        return;
      }

      ref.read(profileNotifierProvider.notifier).updateProfile(
            token: user.token!,
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.isNotEmpty
                ? _passwordController.text
                : null,
            profilePicFile: _imageFile,
          );
    }
  }

  void _handleLogout() {
    // Basic logout - in a real app you'd clear secure storage too
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profileState = ref.watch(profileNotifierProvider);

    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      if (next is ProfileSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prfeofile updated successfully!')),
        );
        _passwordController.clear();
      } else if (next is ProfileError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    final isLoading = profileState is ProfileLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.1),
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (user?.profilePic != null &&
                                  user!.profilePic!.isNotEmpty
                              ? NetworkImage(
                                  'http://192.168.31.240:5000${user.profilePic}')
                              : null) as ImageProvider?,
                      child: _imageFile == null &&
                              (user?.profilePic == null ||
                                  user!.profilePic!.isEmpty)
                          ? Text(
                              (user?.username.isNotEmpty == true
                                      ? user!.username[0]
                                      : '?')
                                  .toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 40, fontWeight: FontWeight.bold),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 3) return 'Username too short';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  if (!value.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'New Password (Optional)',
                  prefixIcon: Icon(Icons.lock_outline),
                  helperText: 'Leave blank to keep current password',
                ),
                obscureText: true,
              ),
              const SizedBox(height: 40),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomButton(
                      text: 'Save Changes',
                      onPressed: _handleUpdate,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/profile_store.dart';
import '../../widgets/auth_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _agreed = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _register() async {
    if (_loading || !_formKey.currentState!.validate()) return;

    if (!_agreed) {
      _message('Please accept the Terms & Conditions');
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.instance.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      await ProfileStore.instance.save(
        name: _nameController.text,
        goal: ProfileStore.instance.goal,
      );
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (mounted) _message(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      header: SizedBox(
        height: 240,
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Image.asset(
                'assets/images/register_illustration.png',
                height: 210,
              ),
            ),
            Positioned(
              left: 16,
              top: 8,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 18,
                      color: AppColors.dark,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              top: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Let's get you started ✨",
                    style: TextStyle(color: AppColors.grey, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      card: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthField(
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person_outline,
              controller: _nameController,
              validator: (v) =>
                  (v ?? '').trim().isEmpty ? 'Please enter your name' : null,
            ),
            AuthField(
              label: 'Email',
              hint: 'Enter your email',
              icon: Icons.mail_outline,
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                final value = (v ?? '').trim();
                if (value.isEmpty) return 'Please enter your email';
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            AuthField(
              label: 'Password',
              hint: 'Create a password',
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Please create a password';
                if (v!.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            AuthField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline,
              controller: _confirmController,
              isPassword: true,
              validator: (v) =>
                  v != _passwordController.text ? 'Passwords do not match' : null,
            ),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                ),
                const Expanded(
                  child: Text('I agree to the Terms & Conditions'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AuthButton(
              label: _loading ? 'Please wait...' : 'Create Account',
              onPressed: _register,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(color: AppColors.grey),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Login →'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
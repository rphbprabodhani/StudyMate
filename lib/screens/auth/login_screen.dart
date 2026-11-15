import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/profile_store.dart';
import '../../widgets/auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _comingSoon(String feature) => _message('$feature is coming soon');

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _message('Enter your email first');
      return;
    }
    try {
      await AuthService.instance.sendPasswordReset(email);
      if (mounted) _message('Password reset email sent');
    } catch (e) {
      if (mounted) _message(AuthService.friendlyError(e));
    }
  }

  Future<void> _login() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.instance.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final name = AuthService.instance.currentUser?.displayName;
      if (name != null && name.isNotEmpty) {
        await ProfileStore.instance.save(
          name: name,
          goal: ProfileStore.instance.goal,
        );
      }
    } catch (e) {
      if (mounted) _message(AuthService.friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      header: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Study',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  'Mate',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.school, color: AppColors.primary, size: 26),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Your study partner\nfor a better tomorrow. 💜',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Image.asset('assets/images/login_illustration.png', height: 210),
          ],
        ),
      ),
      card: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back! 👋',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Login to continue your learning journey.',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 22),
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
              hint: 'Enter your password',
              icon: Icons.lock_outline,
              controller: _passwordController,
              isPassword: true,
              validator: (v) {
                if ((v ?? '').isEmpty) return 'Please enter your password';
                if (v!.length < 6) return 'At least 6 characters';
                return null;
              },
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgotPassword,
                child: const Text('Forgot Password?'),
              ),
            ),
            const SizedBox(height: 4),
            AuthButton(
              label: _loading ? 'Please wait...' : 'Login',
              onPressed: _login,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SocialButton(
                    icon: const Text(
                      'G',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                    label: 'Google',
                    onPressed: () => _comingSoon('Google sign-in'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SocialButton(
                    icon: const Icon(Icons.apple, size: 22),
                    label: 'Apple',
                    onPressed: () => _comingSoon('Apple sign-in'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account?",
                  style: TextStyle(color: AppColors.grey),
                ),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text('Sign Up →'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
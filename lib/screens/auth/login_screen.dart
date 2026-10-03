import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intario_ai/theme/app_theme.dart';
import 'package:intario_ai/widgets/gradient_button.dart';
import 'package:intario_ai/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    await ref.read(authProvider.notifier).login(email, password);
    
    final authState = ref.read(authProvider);
    if (authState.error != null) {
      _showSnackBar(authState.error!);
    } else if (authState.isAuthenticated) {
      context.go('/');
    }
  }

  void _showSnackBar(String msg) {
    final isDark = AppTheme.isDark(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark ? AppTheme.dSecondaryBg : AppTheme.lTextPrimary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isDark = AppTheme.isDark(context);

    return Scaffold(
      backgroundColor: AppTheme.background(context),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient135(context),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: AppTheme.shadowLG(context),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text('Intario AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                      Text('AI-Powered Interior Design', style: TextStyle(fontSize: 15, color: AppTheme.textSecondary(context))),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.card(context),
                    borderRadius: AppTheme.cardRadius,
                    border: Border.all(color: AppTheme.border(context)),
                    boxShadow: AppTheme.shadowLG(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary(context))),
                      Text('Sign in to continue', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary(context))),
                      const SizedBox(height: 24),
                      _buildTextField(
                        label: 'Email',
                        controller: _emailController,
                        hint: 'your@email.com',
                        icon: Icons.mail_outline_rounded,
                        keyboard: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        label: 'Password',
                        controller: _passwordController,
                        hint: '••••••••',
                        icon: Icons.lock_outline_rounded,
                        obscure: !_isPasswordVisible,
                        trailing: IconButton(
                          icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppTheme.textSecondary(context)),
                          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => _showSnackBar('Reset link sent to your email!'),
                          child: Text('Forgot password?', style: TextStyle(color: AppTheme.primary(context), fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      GradientButton(
                        label: 'Sign In',
                        isLoading: authState.isLoading,
                        onTap: _handleLogin,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Don't have an account?", style: TextStyle(color: AppTheme.textSecondary(context))),
                      TextButton(
                        onPressed: () => _showSnackBar('Registration coming soon!'),
                        child: Text('Sign up', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary(context))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? trailing,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppTheme.textSecondary(context))),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.background(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border(context)),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            style: TextStyle(color: AppTheme.textPrimary(context)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppTheme.textSecondary(context)),
              prefixIcon: Icon(icon, size: 20, color: AppTheme.textSecondary(context)),
              suffixIcon: trailing,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              fillColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}

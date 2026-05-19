import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/glass_container.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _isLoginMode = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.status == AuthStatus.authenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/home');
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 80),

              // Logo
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.coral],
                  ),
                ),
                child: const Center(
                  child: Text('🌙', style: TextStyle(fontSize: 44)),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Moodiary',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '用AI读懂你的每一天',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 48),

              // Form
              GlassContainer(
                child: Column(
                  children: [
                    if (!_isLoginMode) ...[
                      TextField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(
                          hintText: '昵称',
                          prefixIcon: Icon(Icons.person_outline, size: 22),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: '邮箱',
                        prefixIcon: Icon(Icons.email_outlined, size: 22),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '密码',
                        prefixIcon: Icon(Icons.lock_outlined, size: 22),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Error message
                    if (authState.error != null) ...[
                      Text(
                        authState.error!,
                        style: const TextStyle(color: AppColors.coral, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: authState.status == AuthStatus.authenticating
                            ? null
                            : _handleSubmit,
                        child: authState.status == AuthStatus.authenticating
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(_isLoginMode ? '登录' : '注册'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Toggle mode
              TextButton(
                onPressed: () {
                  setState(() => _isLoginMode = !_isLoginMode);
                },
                child: Text(
                  _isLoginMode ? '还没有账号？注册' : '已有账号？登录',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) return;

    if (_isLoginMode) {
      ref.read(authProvider.notifier).signIn(email, password);
    } else {
      final nickname =
          _nicknameController.text.trim().isNotEmpty ? _nicknameController.text.trim() : email.split('@').first;
      ref.read(authProvider.notifier).signUp(email, password, nickname);
    }
  }
}

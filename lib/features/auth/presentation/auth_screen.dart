import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import 'providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isLogin = !_isLogin;
      _confirmPasswordController.clear();
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) return;
    
    if (!_isLogin && password != confirmPassword) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      if (_isLogin) {
        await authRepo.signInWithEmail(email, password);
      } else {
        await authRepo.signUpWithEmail(email, password);
      }
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitGoogle() async {
    setState(() => _isLoading = true);
    
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signInWithGoogle();
      
      if (mounted) {
        context.go('/dashboard');
      }
    } catch (e) {
      if (mounted) {
        if (!e.toString().contains('aborted')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/FlashMind.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              
              const SizedBox(height: 32),
              
              Text(
                _isLogin ? 'Welcome back' : 'Create an account',
                style: Theme.of(context).textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 8),
              
              Text(
                _isLogin 
                  ? 'Sign in to access your flashcards' 
                  : 'Start mastering new subjects today',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 48),
              
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Email address',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),
              
              const SizedBox(height: 16),
              
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  hintText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),
              
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                
                TextField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    hintText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ).animate().fadeIn(delay: 450.ms, duration: 600.ms).slideX(begin: -0.1, end: 0),
              ],
              
              const SizedBox(height: 32),
              
              PrimaryButton(
                text: _isLogin ? 'Sign In' : 'Sign Up',
                onPressed: _submit,
                isLoading: _isLoading,
              ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: TextStyle(color: Colors.grey.withValues(alpha: 0.5))),
                  ),
                  Expanded(child: Divider(color: Colors.grey.withValues(alpha: 0.3))),
                ],
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              
              const SizedBox(height: 24),
              
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _submitGoogle,
                icon: Image.asset('assets/google.png', height: 24),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ).animate().fadeIn(delay: 700.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: _toggleMode,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: Text(
                  _isLogin 
                    ? "Don't have an account? Sign up" 
                    : "Already have an account? Sign in",
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}

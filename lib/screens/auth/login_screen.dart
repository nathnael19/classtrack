import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:classtrack/screens/auth/register_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
import 'package:classtrack/screens/student/student_dashboard_screen.dart';
import 'package:classtrack/widgets/glass_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            const DynamicBackground(),
            LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final dynamicScale = (h / 844.0).clamp(0.85, 1.1);

                return SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60 * dynamicScale),
                          // Logo & Header
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Icon(
                                      Icons.school_rounded,
                                      size: 48,
                                      color: ClassTrackTheme.primaryBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'ClassTrack',
                                    style: theme.textTheme.displayLarge?.copyWith(
                                      fontSize: 32 * dynamicScale,
                                      fontWeight: FontWeight.w900,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Welcome back, Student!',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                      fontSize: 16 * dynamicScale,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 48 * dynamicScale),

                          // Login Bento Card
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: GlassCard(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'University Email',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GlassTextField(
                                      controller: _emailController,
                                      hintText: 'name@university.edu.et',
                                      prefixIcon: Icons.email_outlined,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                      scale: dynamicScale,
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'Password',
                                      style: theme.textTheme.labelLarge?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark ? Colors.white : const Color(0xFF334155),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    GlassTextField(
                                      controller: _passwordController,
                                      hintText: '••••••••',
                                      prefixIcon: Icons.lock_outline_rounded,
                                      obscureText: !_isPasswordVisible,
                                      suffixIcon: _isPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      onSuffixIconPressed: () {
                                        setState(() {
                                          _isPasswordVisible = !_isPasswordVisible;
                                        });
                                      },
                                      textInputAction: TextInputAction.done,
                                      scale: dynamicScale,
                                      onSubmitted: (_) => _handleLogin(),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {},
                                        child: Text(
                                          'Forgot Password?',
                                          style: theme.textTheme.labelMedium?.copyWith(
                                            color: ClassTrackTheme.primaryBlue,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    BlocConsumer<AuthCubit, AuthState>(
                                      listener: (context, state) {
                                        if (state.status == AuthStatus.authenticated) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => const StudentDashboardScreen(),
                                            ),
                                          );
                                        } else if (state.error != null) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(state.error!),
                                              backgroundColor: Colors.redAccent,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      },
                                      builder: (context, state) {
                                        return GlassButton(
                                          onPressed: _handleLogin,
                                          label: 'Login',
                                          isLoading: state.status == AuthStatus.loading,
                                          scale: dynamicScale,
                                          width: double.infinity,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Footer
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: ClassTrackTheme.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin() {
    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().login(
          _emailController.text.trim(),
          _passwordController.text,
          UserRole.student,
        );
  }
}

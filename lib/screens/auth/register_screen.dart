import 'package:classtrack/logic/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
import 'package:classtrack/screens/student/student_dashboard_screen.dart';
import 'package:classtrack/widgets/glass_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  bool _isPasswordVisible = false;
  final _nameController = TextEditingController();
  final _idController = TextEditingController();
  final _emailController = TextEditingController();
  final _sectionController = TextEditingController();
  final _passwordController = TextEditingController();
  List<dynamic> _departments = [];
  int? _selectedDepartmentId;
  bool _isLoadingDepts = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
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

  Future<void> _fetchDepartments() async {
    try {
      final api = ApiService();
      final depts = await api.getDepartments();
      setState(() {
        _departments = depts;
        if (_departments.isNotEmpty) {
          _selectedDepartmentId = _departments.first['id'];
        }
        _isLoadingDepts = false;
      });
    } catch (e) {
      debugPrint('Error fetching departments: $e');
      setState(() => _isLoadingDepts = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _emailController.dispose();
    _sectionController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    final name = _nameController.text.trim();
    final studentId = _idController.text.trim();
    final email = _emailController.text.trim();
    final section = _sectionController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty ||
        studentId.isEmpty ||
        email.isEmpty ||
        section.isEmpty ||
        password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    HapticFeedback.mediumImpact();
    context.read<AuthCubit>().register(
      name: name,
      email: email,
      password: password,
      studentId: studentId,
      section: section,
      departmentId: _selectedDepartmentId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.authenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
            (route) => false,
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
      child: GestureDetector(
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
                    child: Column(
                      children: [
                        // Custom App Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                onPressed: () => Navigator.pop(context),
                              ),
                              const Spacer(),
                              Text(
                                'Create Account',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(width: 48), // Balancing
                            ],
                          ),
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 16 * dynamicScale),
                                // Header
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: const Icon(
                                            Icons.qr_code_scanner_rounded,
                                            size: 32,
                                            color: ClassTrackTheme.primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Join Class Track',
                                          style: theme.textTheme.displaySmall?.copyWith(
                                            fontSize: 24 * dynamicScale,
                                            fontWeight: FontWeight.w900,
                                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Start your smart attendance journey',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: isDark ? Colors.white70 : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 32 * dynamicScale),

                                // Personal Section
                                _buildSectionTitle('Personal Information', isDark, theme),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          GlassTextField(
                                            controller: _nameController,
                                            hintText: 'Full Name',
                                            prefixIcon: Icons.person_outline_rounded,
                                            scale: dynamicScale,
                                          ),
                                          const SizedBox(height: 16),
                                          GlassTextField(
                                            controller: _idController,
                                            hintText: 'University ID (e.g. 202401)',
                                            prefixIcon: Icons.badge_outlined,
                                            scale: dynamicScale,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Academic Section
                                _buildSectionTitle('Academic Details', isDark, theme),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          _isLoadingDepts
                                              ? const Center(child: CircularProgressIndicator())
                                              : GlassDropdown<int>(
                                                  value: _selectedDepartmentId,
                                                  hintText: 'Select Department',
                                                  prefixIcon: Icons.account_balance_outlined,
                                                  items: _departments.map((dept) {
                                                    return DropdownMenuItem<int>(
                                                      value: dept['id'],
                                                      child: Text(dept['name']),
                                                    );
                                                  }).toList(),
                                                  onChanged: (val) => setState(() => _selectedDepartmentId = val),
                                                  scale: dynamicScale,
                                                ),
                                          const SizedBox(height: 16),
                                          GlassTextField(
                                            controller: _sectionController,
                                            hintText: 'Section (e.g. A1)',
                                            prefixIcon: Icons.groups_outlined,
                                            scale: dynamicScale,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Account Section
                                _buildSectionTitle('Account Setup', isDark, theme),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: SlideTransition(
                                    position: _slideAnimation,
                                    child: GlassCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          GlassTextField(
                                            controller: _emailController,
                                            hintText: 'University Email',
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType: TextInputType.emailAddress,
                                            scale: dynamicScale,
                                          ),
                                          const SizedBox(height: 16),
                                          GlassTextField(
                                            controller: _passwordController,
                                            hintText: 'Password',
                                            prefixIcon: Icons.lock_outline_rounded,
                                            obscureText: !_isPasswordVisible,
                                            suffixIcon: _isPasswordVisible
                                                ? Icons.visibility_outlined
                                                : Icons.visibility_off_outlined,
                                            onSuffixIconPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                            scale: dynamicScale,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),

                                // Terms
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Text(
                                      'By registering, you agree to our Terms of Service and Privacy Policy.',
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Register Button
                                BlocBuilder<AuthCubit, AuthState>(
                                  builder: (context, state) {
                                    return GlassButton(
                                      onPressed: _handleRegister,
                                      label: 'Create Account',
                                      isLoading: state.status == AuthStatus.loading,
                                      scale: dynamicScale,
                                      width: double.infinity,
                                    );
                                  },
                                ),
                                const SizedBox(height: 32),

                                // Footer
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Already have an account? ",
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          'Login',
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
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:classtrack/screens/auth/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/onboarding/onboarding_cubit.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
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
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'No More Manual Roll Calls',
      description:
          'Say goodbye to paper sheets and long queues. Experience a seamless, automated attendance system powered by QR codes and Geofencing.',
      imagePath: 'assets/Overlay.png',
    ),
    OnboardingData(
      title: 'Scan. Verify. Done.',
      description:
          'Just aim your camera at the class QR code. Our smart scanning technology does the rest in seconds.',
      imagePath: 'assets/Overlay (1).png',
    ),
    OnboardingData(
      title: 'Secure with Location Validation',
      description:
          'Geofencing ensures you are physically present in the classroom, keeping attendance fair and accurate for everyone.',
      imagePath: 'assets/Overlay (2).png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const DynamicBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final isSmall = h < 700;
              final dynamicScale = (h / 844.0).clamp(0.8, 1.2); // Based on iPhone 12/13 height

              return SafeArea(
                child: Column(
                  children: [
                    // Top Header (Skip Button)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: isSmall ? 8 : 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (_currentPage < _pages.length - 1)
                            _buildGlassButton(
                              onPressed: () async {
                                HapticFeedback.lightImpact();
                                final onboardingCubit = context.read<OnboardingCubit>();
                                await onboardingCubit.completeOnboarding();
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                );
                              },
                              label: 'Skip',
                              isSecondary: true,
                              scale: dynamicScale,
                            ),
                        ],
                      ),
                    ),

                    // PageView Content
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                          _animationController.reset();
                          _animationController.forward();
                        },
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: constraints.maxHeight - (isSmall ? 250 : 350),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Glass Illustration Wrapper
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: GlassCard(
                                          padding: EdgeInsets.all(isSmall ? 16 : 32),
                                          child: Center(
                                            child: Image.asset(
                                              _pages[index].imagePath,
                                              fit: BoxFit.contain,
                                              height: isSmall ? 180 : 260,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: isSmall ? 32 : 48),
                                    // Text Bento
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: Column(
                                          children: [
                                            Text(
                                              _pages[index].title,
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.displayLarge?.copyWith(
                                                fontSize: 28 * dynamicScale,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                            SizedBox(height: 16 * dynamicScale),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Text(
                                                _pages[index].description,
                                                textAlign: TextAlign.center,
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  height: 1.6,
                                                  fontSize: 16 * dynamicScale,
                                                  color: isDark ? Colors.white70 : const Color(0xFF475569),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Controls (Bento Style)
                    Padding(
                      padding: EdgeInsets.all(isSmall ? 16 : 24.0),
                      child: Column(
                        children: [
                          // Liquid Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              _pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.elasticOut,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 32 : 12,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? ClassTrackTheme.primaryBlue
                                      : ClassTrackTheme.primaryBlue.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(5),
                                  boxShadow: _currentPage == index
                                      ? [
                                          BoxShadow(
                                            color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: isSmall ? 24 : 40),
                          // Action Buttons Bento
                          Row(
                            children: [
                              if (_currentPage > 0)
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: _buildGlassButton(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        _pageController.previousPage(
                                          duration: const Duration(milliseconds: 600),
                                          curve: Curves.easeOutQuart,
                                        );
                                      },
                                      icon: Icons.arrow_back_rounded,
                                      isSecondary: true,
                                      scale: dynamicScale,
                                    ),
                                  ),
                                ),
                              Expanded(
                                flex: 3,
                                child: _buildGlassButton(
                                  onPressed: () async {
                                    HapticFeedback.mediumImpact();
                                    if (_currentPage < _pages.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(milliseconds: 600),
                                        curve: Curves.easeOutQuart,
                                      );
                                    } else {
                                      final onboardingCubit = context.read<OnboardingCubit>();
                                      await onboardingCubit.completeOnboarding();
                                      if (!context.mounted) return;
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                                      );
                                    }
                                  },
                                  label: _currentPage == _pages.length - 1 ? 'Start Learning' : 'Continue',
                                  icon: _currentPage == _pages.length - 1 ? Icons.school_rounded : Icons.arrow_forward_rounded,
                                  scale: dynamicScale,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    String? label,
    IconData? icon,
    bool isSecondary = false,
    double scale = 1.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 64 * scale.clamp(0.85, 1.0),
      decoration: BoxDecoration(
        color: isSecondary
            ? Colors.transparent
            : ClassTrackTheme.primaryBlue,
        borderRadius: BorderRadius.circular(20),
        border: isSecondary
            ? Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (label != null)
                  Text(
                    label,
                    style: TextStyle(
                      color: isSecondary 
                          ? (isDark ? Colors.white : Colors.black87) 
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (label != null && icon != null) const SizedBox(width: 8),
                if (icon != null)
                  Icon(
                    icon,
                    color: isSecondary 
                        ? (isDark ? Colors.white : Colors.black87) 
                        : Colors.white,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const GlassCard({super.key, required this.child, required this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(ClassTrackTheme.bentoRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(ClassTrackTheme.bentoRadius),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class DynamicBackground extends StatelessWidget {
  const DynamicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: _BlurredCircle(
            size: 300,
            color: ClassTrackTheme.primaryBlue.withValues(alpha: isDark ? 0.15 : 0.1),
          ),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: _BlurredCircle(
            size: 400,
            color: const Color(0xFF10B981).withValues(alpha: isDark ? 0.1 : 0.05),
          ),
        ),
      ],
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurredCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String imagePath;

  OnboardingData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

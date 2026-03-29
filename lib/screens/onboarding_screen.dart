import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:classtrack/screens/auth/login_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/onboarding/onboarding_cubit.dart';
import 'package:classtrack/widgets/glass_widgets.dart';

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
              final dynamicScale = (h / 844.0).clamp(0.8, 1.2);

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
                            GlassButton(
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
                              width: 80,
                              height: 48,
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

                    // Bottom Controls
                    Padding(
                      padding: EdgeInsets.all(isSmall ? 16 : 24.0),
                      child: Column(
                        children: [
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
                          Row(
                            children: [
                              if (_currentPage > 0)
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: GlassButton(
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
                                child: GlassButton(
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

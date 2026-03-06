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

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

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
    return Scaffold(
      backgroundColor: ClassTrackTheme.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      },
                      child: Text(
                        'Back',
                        style: ClassTrackTheme.lightTheme.textTheme.bodyLarge
                            ?.copyWith(
                              color: const Color(0xff64748B),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        final currentContext = context;
                        final onboardingCubit = currentContext
                            .read<OnboardingCubit>();
                        await onboardingCubit.completeOnboarding();
                        if (!currentContext.mounted) return;

                        Navigator.pushReplacement(
                          currentContext,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Skip',
                        style: ClassTrackTheme.lightTheme.textTheme.bodyLarge
                            ?.copyWith(
                              color: const Color(0xff64748B),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    )
                  else
                    const SizedBox(width: 60),
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
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Container
                        Expanded(
                          flex: 3,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F4FF),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 30,
                                  offset: const Offset(0, 20),
                                ),
                                BoxShadow(
                                  color: Colors.blue.withValues(alpha: 0.05),
                                  blurRadius: 30,
                                  offset: const Offset(0, 20),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Image.asset(
                                _pages[index].imagePath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: ClassTrackTheme
                              .lightTheme
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            _pages[index].description,
                            textAlign: TextAlign.center,
                            style: ClassTrackTheme
                                .lightTheme
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: const Color(0xFF475569),
                                  height: 1.6,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bottom Section: Indicators and Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? ClassTrackTheme.primaryBlue
                              : ClassTrackTheme.primaryBlue.withValues(
                                  alpha: 0.2,
                                ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 52),
                  // Action Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: ClassTrackTheme.primaryBlue.withValues(
                            alpha: 0.3,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          final currentContext = context;
                          final onboardingCubit = currentContext
                              .read<OnboardingCubit>();
                          await onboardingCubit.completeOnboarding();
                          if (!currentContext.mounted) return;

                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage == _pages.length - 1
                                ? Icons.check_circle_outline
                                : Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
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

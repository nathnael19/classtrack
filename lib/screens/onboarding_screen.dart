import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';

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
          'Just aim your camera at the lecturer\'s QR code. Our smart scanning technology does the rest in seconds.',
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
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
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
                      onPressed: () {
                        // Logic to skip onboarding (connected to Auth later)
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
                        Container(
                          height: 350,
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Image.asset(
                              width: 350,
                              _pages[index].imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 54),
                        Text(
                          _pages[index].title,
                          textAlign: TextAlign.center,
                          style: ClassTrackTheme
                              .lightTheme
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                        ),
                        const SizedBox(height: 24),
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
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Final Navigation Logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Get Started clicked!'),
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

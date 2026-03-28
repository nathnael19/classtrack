import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:classtrack/theme/design_theme.dart';

class AttendanceStatusCard extends StatelessWidget {
  final double percent;
  final String status;
  final String message;

  const AttendanceStatusCard({
    super.key,
    required this.percent,
    required this.status,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        children: [
          // Glass Background
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark 
                    ? Colors.white.withOpacity(0.05) 
                    : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.white.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  CircularPercentIndicator(
                    radius: 42.0,
                    lineWidth: 8.0,
                    percent: percent,
                    animation: true,
                    animationDuration: 1200,
                    curve: Curves.easeOutQuart,
                    center: Text(
                      "${(percent * 100).toInt()}%",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 18.0,
                        letterSpacing: -0.5,
                      ),
                    ),
                    progressColor: ClassTrackTheme.primaryBlue,
                    backgroundColor: isDark 
                        ? Colors.white.withOpacity(0.05) 
                        : Colors.black.withOpacity(0.05),
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OVERALL ATTENDANCE',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white54 : Colors.black45,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.3,
                            color: isDark ? Colors.white38 : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Subtle Iridescent Glow
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    ClassTrackTheme.primaryBlue.withOpacity(0.15),
                    ClassTrackTheme.primaryBlue.withOpacity(0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

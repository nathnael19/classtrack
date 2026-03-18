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
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircularPercentIndicator(
              radius: 46.0,
              lineWidth: 8.0,
              percent: percent,
              center: Text(
                "${(percent * 100).toInt()}%",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20.0,
                ),
              ),
              progressColor: ClassTrackTheme.primaryBlue,
              backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              circularStrokeCap: CircularStrokeCap.round,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATTENDANCE STATUS',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    status,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: ClassTrackTheme.primaryBlue,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

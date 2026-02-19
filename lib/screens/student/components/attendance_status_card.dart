import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 46.0,
            lineWidth: 8.0,
            percent: percent,
            center: Text(
              "${(percent * 100).toInt()}%",
              style: GoogleFonts.lexend(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: const Color(0xFF0F172A),
              ),
            ),
            progressColor: ClassTrackTheme.primaryBlue,
            backgroundColor: const Color(0xFFF1F5F9),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ATTENDANCE STATUS',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF94A3B8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: ClassTrackTheme.primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

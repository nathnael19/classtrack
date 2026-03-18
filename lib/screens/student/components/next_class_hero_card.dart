import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';

class NextClassHeroCard extends StatelessWidget {
  final String title;
  final String time;
  final String location;
  final String geofenceStatus;
  final bool isPresent;
  final VoidCallback onViewMap;

  const NextClassHeroCard({
    super.key,
    required this.title,
    required this.time,
    required this.location,
    required this.geofenceStatus,
    this.isPresent = false,
    required this.onViewMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ClassTrackTheme.primaryBlue,
            ClassTrackTheme.primaryBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'NEXT CLASS',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
                Icon(
                  isPresent ? Icons.verified_rounded : Icons.school_outlined,
                  color: Colors.white.withValues(alpha: isPresent ? 0.9 : 0.3),
                  size: 40,
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: theme.textTheme.displayLarge?.copyWith(
              color: Colors.white,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                time,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                location,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.15), height: 1),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4ADE80),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isPresent ? 'Attendance Marked' : geofenceStatus,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
                TextButton(
                  onPressed: onViewMap,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'View Map',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

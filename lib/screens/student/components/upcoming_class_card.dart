import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';

class UpcomingClassCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String? section;
  final String time;
  final String location;
  final bool isOnline;

  const UpcomingClassCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    this.section,
    required this.time,
    required this.location,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isOnline ? const Color(0xFF10B981) : ClassTrackTheme.primaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isOnline ? const Color(0xFF10B981) : ClassTrackTheme.primaryBlue).withOpacity(0.3),
                    width: 4,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (isOnline ? const Color(0xFF10B981) : ClassTrackTheme.primaryBlue).withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark 
                        ? Colors.white.withOpacity(0.03) 
                        : Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (isOnline ? const Color(0xFF10B981) : ClassTrackTheme.primaryBlue).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isOnline ? Icons.videocam_rounded : Icons.location_on_rounded,
                          color: isOnline ? const Color(0xFF10B981) : ClassTrackTheme.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  time,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: isDark ? Colors.white54 : Colors.black54,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (section != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '•',
                                    style: TextStyle(color: isDark ? Colors.white24 : Colors.black12),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SEC $section',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: ClassTrackTheme.accentEmerald,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isOnline)
                         const Icon(Icons.bolt_rounded, color: Color(0xFFFFB800), size: 18)
                      else
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

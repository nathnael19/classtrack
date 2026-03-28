import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter/material.dart';

class DashboardHeader extends StatelessWidget {
  final String date;
  final String greeting;
  final String? avatarUrl;

  const DashboardHeader({
    super.key,
    required this.date,
    required this.greeting,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  date.toUpperCase(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  greeting,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    color: isDark ? Colors.white : ClassTrackTheme.textDark,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer Glow
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      ClassTrackTheme.primaryBlue.withValues(alpha: 0.0),
                      ClassTrackTheme.primaryBlue.withValues(alpha: 0.5),
                      ClassTrackTheme.accentEmerald.withValues(alpha: 0.5),
                      ClassTrackTheme.primaryBlue.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              // Inner Border
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    avatarUrl ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.person, size: 28),
                  ),
                ),
              ),
              Positioned(
                right: 4,
                bottom: 4,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(color: isDark ? const Color(0xFF0F172B) : Colors.white, width: 2),
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

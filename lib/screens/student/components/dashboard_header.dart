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

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                date,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                greeting,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Stack(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : Colors.white,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  avatarUrl ??
                      'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person,
                        color: ClassTrackTheme.primaryBlue,
                        size: 26,
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E), // Online Green
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark ? const Color(0xFF0F172B) : Colors.white,
                    width: 2.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

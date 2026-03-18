import 'package:flutter/material.dart';
import '../../../theme/design_theme.dart';

class HistoryStatsCard extends StatelessWidget {
  final String averagePercentage;
  final String improvementText;
  final List<Offset> chartPoints;

  const HistoryStatsCard({
    super.key,
    required this.averagePercentage,
    required this.improvementText,
    required this.chartPoints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Average',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      averagePercentage,
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: ClassTrackTheme.primaryBlue,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7).withValues(alpha: isDark ? 0.2 : 1.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    improvementText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              width: double.infinity,
              child: CustomPaint(
                painter: AttendanceTrendChart(points: chartPoints, isDark: isDark),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (index) {
                return Text(
                  'W${index + 1}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceTrendChart extends CustomPainter {
  final List<Offset> points;
  final bool isDark;

  AttendanceTrendChart({required this.points, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ClassTrackTheme.primaryBlue
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
          ClassTrackTheme.primaryBlue.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final List<Offset> pixelPoints = points.map((p) {
      return Offset(p.dx * size.width, p.dy * size.height);
    }).toList();

    if (pixelPoints.isEmpty) return;

    path.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);
    fillPath.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (var i = 1; i < pixelPoints.length; i++) {
      path.lineTo(pixelPoints[i].dx, pixelPoints[i].dy);
      fillPath.lineTo(pixelPoints[i].dx, pixelPoints[i].dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = ClassTrackTheme.primaryBlue
      ..style = PaintingStyle.fill;

    for (var point in pixelPoints) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 2, Paint()..color = isDark ? const Color(0xFF1E293B) : Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant AttendanceTrendChart oldDelegate) => oldDelegate.points != points;
}

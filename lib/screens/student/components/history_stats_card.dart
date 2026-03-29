import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/glass_widgets.dart';

class HistoryStatsCard extends StatelessWidget {
  final String averagePercentage;
  final String improvementText;
  final List<Offset> chartPoints;
  final int totalClasses;
  final int absences;

  const HistoryStatsCard({
    super.key,
    required this.averagePercentage,
    required this.improvementText,
    required this.chartPoints,
    required this.totalClasses,
    required this.absences,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Main Trend Bento
        GlassCard(
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
                        'ATTENDANCE RATE',
                        style: GoogleFonts.firaCode(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white38 : Colors.black38,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        averagePercentage,
                        style: GoogleFonts.firaCode(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF6366F1),
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.2)),
                    ),
                    child: Text(
                      'STABLE',
                      style: GoogleFonts.firaCode(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF22C55E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 80,
                width: double.infinity,
                child: CustomPaint(
                  painter: AttendanceTrendChart(points: chartPoints, isDark: isDark),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Mini Info Bento Row
        Row(
          children: [
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.calendar_month_rounded, size: 20, color: isDark ? Colors.white24 : Colors.black26),
                    const SizedBox(height: 12),
                    Text(
                      totalClasses.toString(),
                      style: GoogleFonts.firaCode(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'TOTAL CLASSES',
                      style: GoogleFonts.firaCode(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white38 : Colors.black38,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.event_busy_rounded, size: 20, color: const Color(0xFFEF4444).withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text(
                      absences.toString(),
                      style: GoogleFonts.firaCode(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'MISSING DAYS',
                      style: GoogleFonts.firaCode(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white38 : Colors.black38,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AttendanceTrendChart extends CustomPainter {
  final List<Offset> points;
  final bool isDark;

  AttendanceTrendChart({required this.points, this.isDark = false});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF6366F1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF6366F1).withOpacity(0.3),
          const Color(0xFF6366F1).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    final List<Offset> pixelPoints = points.map((p) {
      return Offset(p.dx * size.width, p.dy * size.height);
    }).toList();

    path.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);
    fillPath.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (var i = 1; i < pixelPoints.length; i++) {
      // Use cubic curves for a smooth "liquid" look
      final previousPoint = pixelPoints[i - 1];
      final currentPoint = pixelPoints[i];
      final controlPoint1 = Offset(previousPoint.dx + (currentPoint.dx - previousPoint.dx) / 2, previousPoint.dy);
      final controlPoint2 = Offset(previousPoint.dx + (currentPoint.dx - previousPoint.dx) / 2, currentPoint.dy);
      
      path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, currentPoint.dx, currentPoint.dy);
      fillPath.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, currentPoint.dx, currentPoint.dy);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    final dotPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.fill;

    for (var point in pixelPoints) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 2, Paint()..color = isDark ? const Color(0xFF0F172B) : Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant AttendanceTrendChart oldDelegate) => oldDelegate.points != points;
}

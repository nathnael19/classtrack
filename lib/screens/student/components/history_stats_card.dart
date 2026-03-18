import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Average',
                    style: GoogleFonts.lexend(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    averagePercentage,
                    style: GoogleFonts.lexend(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: ClassTrackTheme.primaryBlue,
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
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  improvementText,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF16A34A),
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
              painter: AttendanceTrendChart(points: chartPoints),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Text(
                'W${index + 1}',
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF94A3B8),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class AttendanceTrendChart extends CustomPainter {
  final List<Offset> points;

  AttendanceTrendChart({required this.points});

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
          ClassTrackTheme.primaryBlue.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    final fillPath = Path();

    // Transform relative points (0-1) to pixel points
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

    // Draw dots
    final dotPaint = Paint()
      ..color = ClassTrackTheme.primaryBlue
      ..style = PaintingStyle.fill;

    for (var point in pixelPoints) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant AttendanceTrendChart oldDelegate) => oldDelegate.points != points;
}

import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class LecturerAnalyticsScreen extends StatelessWidget {
  const LecturerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildTopMetrics(),
              const SizedBox(height: 24),
              _buildCoursePerformance(),
              const SizedBox(height: 32),
              _buildFrequentAbsentees(),
              const SizedBox(height: 32),
              _buildExportActions(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFBFBFB),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF0F172A),
        ),
        onPressed: () {}, // Handled by parent dashboard usually or navigator
      ),
      title: Column(
        children: [
          Text(
            'Analytics',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          Text(
            'FALL SEMESTER 2023',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(
                Icons.calendar_month_rounded,
                color: ClassTrackTheme.primaryBlue,
                size: 20,
              ),
              onPressed: () {},
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopMetrics() {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            icon: Icons.bar_chart_rounded,
            label: 'AVG. RATE',
            value: '84.2%',
            trend: '+2.5%',
            isPositive: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildMetricCard(
            icon: Icons.checklist_rtl_rounded,
            label: 'SESSIONS',
            value: '42',
            trend: '— On track',
            isPositive: false,
            trendColor: const Color(0xFFEF4444),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required String label,
    required String value,
    required String trend,
    required bool isPositive,
    Color? trendColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ClassTrackTheme.primaryBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.lexend(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF94A3B8),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isPositive)
                const Icon(
                  Icons.trending_up_rounded,
                  color: Color(0xFF22C55E),
                  size: 14,
                ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color:
                      trendColor ??
                      (isPositive
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoursePerformance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Performance',
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          _buildPerformanceItem('CS101 Intro to CS', 0.92, '92%'),
          const SizedBox(height: 20),
          _buildPerformanceItem('CS102 Data Structures', 0.78, '78%'),
          const SizedBox(height: 20),
          _buildPerformanceItem('MAT201 Calculus II', 0.65, '65%'),
          const SizedBox(height: 20),
          _buildPerformanceItem('PHY101 Physics', 0.88, '88%'),
        ],
      ),
    );
  }

  Widget _buildPerformanceItem(
    String title,
    double progress,
    String percentage,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            Text(
              percentage,
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ClassTrackTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(
              ClassTrackTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrequentAbsentees() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Frequent Absentees',
              style: GoogleFonts.lexend(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'View All',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ClassTrackTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAbsenteeCard(
          name: 'Alex Johnson',
          id: 'STU-88219',
          absences: 12,
          alertLevel: 'CRITICAL ALERT',
          alertColor: const Color(0xFFEF4444),
        ),
        const SizedBox(height: 12),
        _buildAbsenteeCard(
          name: 'Sarah Williams',
          id: 'STU-44120',
          absences: 8,
          alertLevel: 'WARNING',
          alertColor: const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _buildAbsenteeCard({
    required String name,
    required String id,
    required int absences,
    required String alertLevel,
    required Color alertColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFF1F5F9),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'ID: $id',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$absences Absences',
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: alertColor,
                ),
              ),
              Text(
                alertLevel,
                style: GoogleFonts.lexend(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFCBD5E1),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.picture_as_pdf_outlined,
            label: 'Export PDF',
            color: const Color(0xFF0F172A),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.table_view_outlined,
            label: 'Export Excel',
            color: ClassTrackTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

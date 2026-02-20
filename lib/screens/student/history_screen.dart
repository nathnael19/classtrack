import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/history_filter_dropdowns.dart';
import 'components/history_stats_card.dart';
import 'components/history_session_item.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _selectedCourse = 'All Courses';
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    HistoryFilterDropdowns(
                      selectedCourse: _selectedCourse,
                      selectedPeriod: _selectedPeriod,
                      courses: const [
                        'All Courses',
                        'CS 101',
                        'Math 402',
                        'Design 201',
                      ],
                      periods: const [
                        'This Month',
                        'Last Month',
                        'This Semester',
                      ],
                      onCourseChanged: (val) =>
                          setState(() => _selectedCourse = val!),
                      onPeriodChanged: (val) =>
                          setState(() => _selectedPeriod = val!),
                    ),
                    const SizedBox(height: 24),
                    const HistoryStatsCard(
                      averagePercentage: '94%',
                      improvementText: '+2.4% vs last mo',
                      chartPoints: [
                        Offset(0, 0.6),
                        Offset(0.25, 0.75),
                        Offset(0.5, 0.3),
                        Offset(0.75, 0.45),
                        Offset(1.0, 0.1),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Recent Sessions',
                      style: GoogleFonts.lexend(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const HistorySessionItem(
                      course: 'Computer Science 101',
                      dateTime: 'Oct 24, 2023 • 09:00 AM',
                      status: 'PRESENT',
                      icon: Icons.code,
                      statusColor: Color(0xFF22C55E),
                    ),
                    const HistorySessionItem(
                      course: 'Advanced Mathematics',
                      dateTime: 'Oct 23, 2023 • 11:30 AM',
                      status: 'LATE',
                      icon: Icons.functions,
                      statusColor: Color(0xFFF97316),
                    ),
                    const HistorySessionItem(
                      course: 'Digital Design Theory',
                      dateTime: 'Oct 22, 2023 • 02:00 PM',
                      status: 'ABSENT',
                      icon: Icons.palette,
                      statusColor: Color(0xFFEF4444),
                    ),
                    const HistorySessionItem(
                      course: 'Computer Science 101',
                      dateTime: 'Oct 20, 2023 • 09:00 AM',
                      status: 'PRESENT',
                      icon: Icons.code,
                      statusColor: Color(0xFF22C55E),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              'Attendance History',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

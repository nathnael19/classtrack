import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/design_theme.dart';
import 'components/history_filter_dropdowns.dart';
import 'components/history_stats_card.dart';
import 'components/history_session_item.dart';
import 'package:intl/intl.dart';
import '../../logic/api_service.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  String _selectedCourse = 'All Courses';
  String _selectedPeriod = 'This Month';
  DateTime? _selectedDate;
  List<dynamic> _history = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final api = ApiService();
      final results = await Future.wait([
        api.getAttendanceHistory(),
        api.getAttendanceSummary(),
      ]);
      if (mounted) {
        setState(() {
          _history = results[0] as List<dynamic>;
          _summary = results[1] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching history: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ClassTrackTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF0F172A),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: ClassTrackTheme.primaryBlue,
              headerForegroundColor: Colors.white,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              dayStyle: GoogleFonts.lexend(fontWeight: FontWeight.w500),
              weekdayStyle: GoogleFonts.lexend(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
              yearStyle: GoogleFonts.lexend(),
              headerHeadlineStyle: GoogleFonts.lexend(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              headerHelpStyle: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // TODO: Filter history list based on selected date
      debugPrint('Selected date: ${picked.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
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
                      courses: ['All Courses', ..._history.map((e) => e['course_name'] as String).toSet()],
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
                    HistoryStatsCard(
                      averagePercentage: _summary != null
                          ? '${(_summary!['percent'] * 100).toInt()}%'
                          : '--%',
                      improvementText: 'Total classes: ${_summary?['total_classes'] ?? 0}',
                      chartPoints: const [
                        Offset(0, 0.6),
                        Offset(0.25, 0.75),
                        Offset(0.5, 0.3),
                        Offset(0.75, 0.45),
                        Offset(1.0, 0.1),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Sessions',
                          style: GoogleFonts.lexend(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        if (_selectedDate != null)
                          TextButton(
                            onPressed: () =>
                                setState(() => _selectedDate = null),
                            child: Text(
                              'Clear Date',
                              style: GoogleFonts.lexend(
                                color: ClassTrackTheme.primaryBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_history.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Text(
                            'No attendance history found.',
                            style: GoogleFonts.lexend(color: const Color(0xFF64748B)),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: _history.where((record) {
                          if (_selectedCourse != 'All Courses' && record['course_name'] != _selectedCourse) return false;
                          if (_selectedDate != null) {
                            final ts = DateTime.parse(record['timestamp']).toLocal();
                            if (ts.year != _selectedDate!.year || ts.month != _selectedDate!.month || ts.day != _selectedDate!.day) return false;
                          }
                          return true;
                        }).map((record) {
                          final timestamp = DateTime.parse(record['timestamp']).toLocal();
                          final status = record['status']?.toString().toUpperCase() ?? 'PRESENT';
                          Color statusColor;
                          switch (status) {
                            case 'PRESENT':
                              statusColor = const Color(0xFF22C55E);
                              break;
                            case 'LATE':
                              statusColor = const Color(0xFFF97316);
                              break;
                            default:
                              statusColor = const Color(0xFFEF4444);
                          }

                          return HistorySessionItem(
                            course: record['course_name'] ?? 'Unknown Course',
                            dateTime: DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                            status: status,
                            icon: Icons.class_outlined,
                            statusColor: statusColor,
                          );
                        }).toList(),
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

  Widget _buildHeader(BuildContext context) {
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
            onPressed: () => _selectDate(context),
            icon: Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: _selectedDate != null
                  ? ClassTrackTheme.primaryBlue
                  : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/design_theme.dart';
import 'components/history_filter_dropdowns.dart';
import 'components/history_stats_card.dart';
import 'components/history_session_item.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/attendance/attendance_cubit.dart';
import 'request_leave_screen.dart';

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

  Future<void> _selectDate(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: ClassTrackTheme.primaryBlue,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1E293B) : Colors.white,
              onSurface: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
            datePickerTheme: DatePickerThemeData(
              headerBackgroundColor: ClassTrackTheme.primaryBlue,
              headerForegroundColor: Colors.white,
              backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              dayStyle: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              weekdayStyle: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w900,
              ),
              yearStyle: theme.textTheme.bodyMedium,
              headerHeadlineStyle: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
              headerHelpStyle: theme.textTheme.labelMedium?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w700,
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
      debugPrint('Selected date: ${picked.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        final history = state.history;
        final summary = state.summary;
        final isLoading = state.status == AttendanceStatus.loading;

        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => context.read<AttendanceCubit>().refresh(),
                    color: ClassTrackTheme.primaryBlue,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          HistoryFilterDropdowns(
                            selectedCourse: _selectedCourse,
                            selectedPeriod: _selectedPeriod,
                            courses: ['All Courses', ...history.map((e) => e['course_name'] as String).toSet()],
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
                            averagePercentage: summary != null
                                ? '${(summary['percent'] * 100).toInt()}%'
                                : '--%',
                            improvementText: 'Total classes: ${summary?['total_classes'] ?? 0}',
                            chartPoints: summary != null && summary['weekly_stats'] != null
                                ? (summary['weekly_stats'] as List).asMap().entries.map((e) {
                                    return Offset(e.key / 4.0, 1.0 - (e.value as double));
                                  }).toList()
                                : const [
                                    Offset(0, 1.0),
                                    Offset(0.25, 1.0),
                                    Offset(0.5, 1.0),
                                    Offset(0.75, 1.0),
                                    Offset(1.0, 1.0),
                                  ],
                          ),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Recent Sessions',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (_selectedDate != null)
                                TextButton(
                                  onPressed: () =>
                                      setState(() => _selectedDate = null),
                                  child: Text(
                                    'Clear Date',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: ClassTrackTheme.primaryBlue,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (history.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 32.0),
                                child: Text(
                                  'No attendance history found.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: history.where((record) {
                                if (_selectedCourse != 'All Courses' && record['course_name'] != _selectedCourse) return false;
                                if (_selectedDate != null) {
                                  final ts = DateTime.parse(record['timestamp']).toLocal();
                                  if (ts.year != _selectedDate!.year || ts.month != _selectedDate!.month || ts.day != _selectedDate!.day) return false;
                                }
                                return true;
                              }).map<Widget>((record) {
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
                                  section: record['section'],
                                  dateTime: DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                                  status: status,
                                  icon: Icons.class_outlined,
                                  statusColor: statusColor,
                                  onTap: () => _showSessionOptions(context, record),
                                );
                              }).toList(),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSessionOptions(BuildContext context, Map<String, dynamic> record) {
    final theme = Theme.of(context);
    final isAbsent = record['status']?.toString().toUpperCase() == 'ABSENT';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              record['course_name'] ?? 'Class Session',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24),
            if (isAbsent)
              ListTile(
                leading: const Icon(Icons.edit_calendar_rounded, color: ClassTrackTheme.primaryBlue),
                title: const Text('Request Leave'),
                subtitle: const Text('Explain your absence for this session'),
                onTap: () {
                  Navigator.pop(ctx);
                  
                  // Construct session-like object for RequestLeaveScreen
                  final session = {
                    'id': record['session_id'],
                    'course_name': record['course_name'],
                    'section': record['section'],
                    'room': record['room'],
                  };
  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RequestLeaveScreen(session: session),
                    ),
                  ).then((result) {
                    if (result == true && context.mounted) {
                      context.read<AttendanceCubit>().refresh();
                    }
                  });
                },
              ),
            if (!isAbsent)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Leave requests are only available for absent sessions.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              ),
              const SizedBox(width: 4),
              Text(
                'Attendance History',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(
              Icons.calendar_today_outlined,
              size: 20,
              color: _selectedDate != null
                  ? ClassTrackTheme.primaryBlue
                  : theme.iconTheme.color?.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

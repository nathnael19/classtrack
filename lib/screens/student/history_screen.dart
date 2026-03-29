import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/history_filter_dropdowns.dart';
import 'components/history_stats_card.dart';
import 'components/history_session_item.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/cubits/attendance/attendance_cubit.dart';
import '../../widgets/glass_widgets.dart';
import 'request_leave_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen>
    with TickerProviderStateMixin {
  String _selectedCourse = 'All Courses';
  String _selectedPeriod = 'This Month';
  DateTime? _selectedDate;

  late AnimationController _fadeController;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeController.forward();
    _staggerController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: const Color(0xFF6366F1),
              surface: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      HapticFeedback.lightImpact();
      setState(() => _selectedDate = picked);
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

        // --- Filtering and Sorting Logic ---
        final now = DateTime.now();
        final filteredHistory = history.where((record) {
          // 1. Course Filter
          if (_selectedCourse != 'All Courses' && record['course_name'] != _selectedCourse) {
            return false;
          }

          // 2. Date/Period Filter
          final recordDate = DateTime.parse(record['timestamp']).toLocal();

          if (_selectedDate != null) {
            // Calendar date overrides period
            if (recordDate.year != _selectedDate!.year ||
                recordDate.month != _selectedDate!.month ||
                recordDate.day != _selectedDate!.day) {
              return false;
            }
          } else {
            // Use Period dropdown
            switch (_selectedPeriod) {
              case 'This Month':
                if (recordDate.month != now.month || recordDate.year != now.year) return false;
                break;
              case 'Last Month':
                final lastMonth = DateTime(now.year, now.month - 1);
                if (recordDate.month != lastMonth.month || recordDate.year != lastMonth.year) return false;
                break;
              case 'This Semester':
                // Simple semester logic: last 5 months
                final semesterStart = now.subtract(const Duration(days: 150));
                if (recordDate.isBefore(semesterStart)) return false;
                break;
              default:
                break;
            }
          }
          return true;
        }).toList();

        // Sort by newest first
        filteredHistory.sort((a, b) =>
            DateTime.parse(b['timestamp']).compareTo(DateTime.parse(a['timestamp'])));
        // ------------------------------------

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Stack(
            children: [
              const DynamicBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(context, isDark),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<AttendanceCubit>().refresh();
                          _staggerController.reset();
                          _staggerController.forward();
                        },
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                        color: const Color(0xFF6366F1),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              _buildTransitionItem(
                                index: 0,
                                child: HistoryFilterDropdowns(
                                  selectedCourse: _selectedCourse,
                                  selectedPeriod: _selectedPeriod,
                                  courses: [
                                    'All Courses',
                                    ...history.map((e) => e['course_name'] as String).toSet(),
                                  ]..sort(),
                                  periods: const ['This Month', 'Last Month', 'This Semester'],
                                  onCourseChanged: (val) => setState(() => _selectedCourse = val!),
                                  onPeriodChanged: (val) => setState(() => _selectedPeriod = val!),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _buildTransitionItem(
                                index: 1,
                                child: HistoryStatsCard(
                                  averagePercentage: summary != null ? '${(summary['percent'] * 100).toInt()}%' : '--%',
                                  totalClasses: summary?['total_classes'] ?? 0,
                                  absences: summary?['absent_count'] ?? 0,
                                  improvementText: 'Active',
                                  chartPoints: summary != null && summary['weekly_stats'] != null
                                      ? (summary['weekly_stats'] as List).asMap().entries.map((e) {
                                          return Offset(e.key / 4.0, 1.0 - (e.value as double));
                                        }).toList()
                                      : const [Offset(0, 1), Offset(0.25, 0.8), Offset(0.5, 0.9), Offset(0.75, 0.6), Offset(1, 0.7)],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _buildTransitionItem(
                                index: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'RECENT RECORDS',
                                      style: GoogleFonts.firaCode(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? Colors.white38 : Colors.black38,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    if (_selectedDate != null)
                                      GestureDetector(
                                        onTap: () => setState(() => _selectedDate = null),
                                        child: Text(
                                          'CLEAR DATE',
                                          style: GoogleFonts.firaCode(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF6366F1),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              if (isLoading)
                                const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                              else if (filteredHistory.isEmpty)
                                _buildEmptyState(isDark)
                              else
                                ...filteredHistory.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final record = entry.value;
                                  final timestamp = DateTime.parse(record['timestamp']).toLocal();
                                  final status = record['status']?.toString().toUpperCase() ?? 'PRESENT';

                                  Color statusColor;
                                  switch (status) {
                                    case 'PRESENT': statusColor = const Color(0xFF22C55E); break;
                                    case 'LATE': statusColor = const Color(0xFFF97316); break;
                                    default: statusColor = const Color(0xFFEF4444);
                                  }

                                  return _buildTransitionItem(
                                    index: index + 3,
                                    child: HistorySessionItem(
                                      course: record['course_name'] ?? 'Unknown Course',
                                      section: record['section'],
                                      dateTime: DateFormat('MMM d, yyyy • h:mm a').format(timestamp),
                                      timestamp: timestamp,
                                      status: status,
                                      icon: Icons.class_outlined,
                                      statusColor: statusColor,
                                      onTap: status == 'PRESENT'
                                          ? null
                                          : () => _showSessionOptions(context, record, isDark),
                                    ),
                                  );
                                }),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'History',
                  style: GoogleFonts.firaCode(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'ATTENDANCE LOGS',
                  style: GoogleFonts.firaCode(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _buildGlassActionButton(
              icon: Icons.calendar_today_rounded,
              onPressed: () => _selectDate(context),
              isDark: isDark,
              isActive: _selectedDate != null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onPressed();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFF6366F1).withOpacity(0.1)
                  : (isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF6366F1).withOpacity(0.3)
                    : (isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.05)),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(
            Icons.history_toggle_off_rounded,
            size: 64,
            color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
          ),
          const SizedBox(height: 20),
          Text(
            'No records found.',
            style: GoogleFonts.firaCode(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white24 : Colors.black26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransitionItem({required int index, required Widget child}) {
    final start = (index * 0.05).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);

    return AnimatedBuilder(
      animation: _staggerController,
      builder: (context, child) {
        final value = CurvedAnimation(
          parent: _staggerController,
          curve: Interval(start, end, curve: Curves.easeOutCubic),
        ).value;

        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  void _showSessionOptions(
    BuildContext context,
    Map<String, dynamic> record,
    bool isDark,
  ) {
    final isAbsent = record['status']?.toString().toUpperCase() == 'ABSENT';
    final isPresent = record['status']?.toString().toUpperCase() == 'PRESENT';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A).withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                record['course_name'] ?? 'Class Session',
                style: GoogleFonts.firaCode(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              if (isAbsent) ...[
                const SizedBox(height: 24),
                GlassButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    final session = {
                      'id': record['session_id'],
                      'course_name': record['course_name'],
                      'section': record['section'],
                      'room': record['room'],
                    };
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RequestLeaveScreen(session: session),
                      ),
                    ).then((result) {
                      if (result == true)
                        context.read<AttendanceCubit>().refresh();
                    });
                  },
                  label: 'Request Leave',
                  scale: 1.0,
                  width: double.infinity,
                ),
              ] else if (!isPresent)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Leave requests only available for absent sessions.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.firaCode(
                      fontSize: 12,
                      color: Colors.orange.withOpacity(0.8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

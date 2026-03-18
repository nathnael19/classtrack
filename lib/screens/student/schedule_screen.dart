import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/design_theme.dart';
import '../../logic/api_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ScrollController _scrollController = ScrollController();
  late int _selectedDayIndex;
  late List<Map<String, String>> _days;
  late DateTime _anchorDate; // The date used to determine which week to show
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  final ApiService _api = ApiService();

  @override
  void initState() {
    super.initState();
    _anchorDate = DateTime.now().toUtc().add(const Duration(hours: 3));
    _initializeDynamicDates(_anchorDate);
    _fetchSessions();
    // Scroll to today's date after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  Future<void> _fetchSessions() async {
    setState(() => _isLoading = true);
    try {
      final monday = DateTime.parse(_days[0]['fullDate']!);
      final sunday = DateTime.parse(_days[6]['fullDate']!).add(const Duration(hours: 23, minutes: 59));
      
      final sessions = await _api.getSessions(
        startDate: monday,
        endDate: sunday,
      );
      
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedDay() {
    if (_scrollController.hasClients) {
      // Each date item is 70 wide + 16 horizontal margins (8 on each side) = 86 total per item
      const double itemWidth = 86.0;

      // Calculate target offset
      final double targetOffset = (_selectedDayIndex * itemWidth);

      _scrollController.animateTo(
        targetOffset,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _initializeDynamicDates(DateTime anchor) {
    // Find the Monday of the week containing the anchor date
    final int daysSinceMonday = anchor.weekday - 1;
    final DateTime monday = anchor.subtract(Duration(days: daysSinceMonday));

    _days = List.generate(7, (index) {
      final DateTime date = monday.add(Duration(days: index));
      return {
        'day': DateFormat('EEE').format(date).toUpperCase(),
        'date': date.day.toString(),
        'fullDate': DateFormat('yyyy-MM-dd').format(date),
      };
    });

    // Set selected index to the offset from Monday for the anchor date
    _selectedDayIndex = daysSinceMonday;
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _anchorDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
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

    if (picked != null) {
      setState(() {
        _anchorDate = picked;
        _initializeDynamicDates(picked);
      });
      _scrollToSelectedDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme, isDark),
            const SizedBox(height: 24),
            _buildDateSelector(isDark, theme),
            const SizedBox(height: 32),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _fetchSessions,
                      color: ClassTrackTheme.primaryBlue,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            if (_sessions.isEmpty)...[
                              const SizedBox(height: 100),
                              Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.event_note_rounded,
                                      size: 48,
                                      color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No sessions scheduled for this week.',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else
                              ..._buildTimelineSessions(theme, isDark),
                            const SizedBox(height: 100), // Space for navigation
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Schedule',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy').format(_anchorDate),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ),
                boxShadow: isDark ? [] : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                color: ClassTrackTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTimelineSessions(ThemeData theme, bool isDark) {
    final selectedDate = _days[_selectedDayIndex]['fullDate'];
    final daySessions = _sessions.where((s) {
      final startTime = DateTime.parse(s['start_time']).toLocal();
      return DateFormat('yyyy-MM-dd').format(startTime) == selectedDate;
    }).toList();

    if (daySessions.isEmpty) {
      return [
        const SizedBox(height: 60),
        Center(
          child: Text(
            'No classes for this day.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ];
    }

    daySessions.sort((a, b) => a['start_time'].compareTo(b['start_time']));

    return daySessions.map((session) {
      final startTime = DateTime.parse(session['start_time']).toLocal();
      final endTime = DateTime.parse(session['end_time']).toLocal();
      final now = DateTime.now();

      TimelineStatus timelineStatus;
      if (now.isAfter(endTime)) {
        timelineStatus = TimelineStatus.completed;
      } else if (now.isAfter(startTime) && now.isBefore(endTime)) {
        timelineStatus = TimelineStatus.active;
      } else {
        timelineStatus = TimelineStatus.upcoming;
      }

      return _buildTimelineItem(
        theme: theme,
        time: DateFormat('HH:mm').format(startTime),
        status: timelineStatus,
        child: ClassCard(
          title: session['topic'] ?? 'Untitled Session',
          time: '${DateFormat('hh:mm a').format(startTime)} - ${DateFormat('hh:mm a').format(endTime)}',
          location: session['room'] ?? 'N/A',
          lecturer: session['lecturer_name'] ?? 'N/A',
          status: now.isAfter(endTime) ? ClassStatus.completed : ClassStatus.upcoming,
          isHighlighted: timelineStatus == TimelineStatus.active,
        ),
      );
    }).toList();
  }

  Widget _buildDateSelector(bool isDark, ThemeData theme) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? ClassTrackTheme.primaryBlue : (isDark ? const Color(0xFF1E293B) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: !isSelected ? Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                ) : null,
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  else if (!isDark)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _days[index]['day']!,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.7)
                          : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _days[index]['date']!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.white : const Color(0xFF0F172A)),
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem({
    required ThemeData theme,
    required String time,
    required TimelineStatus status,
    required Widget child,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  time,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: status == TimelineStatus.active
                        ? ClassTrackTheme.primaryBlue
                        : (isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(status),
                Expanded(
                  child: Container(
                    width: 1.5, 
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(TimelineStatus status) {
    switch (status) {
      case TimelineStatus.completed:
        return const Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF10B981),
          size: 24,
        );
      case TimelineStatus.active:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ClassTrackTheme.primaryBlue, width: 3),
          ),
          padding: const EdgeInsets.all(4),
          child: Container(
            decoration: const BoxDecoration(
              color: ClassTrackTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        );
      case TimelineStatus.upcoming:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF64748B).withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF64748B).withValues(alpha: 0.2),
              width: 1,
            ),
          ),
        );
    }
  }
}

enum TimelineStatus { completed, active, upcoming }

enum ClassStatus { completed, upcoming }

class ClassCard extends StatelessWidget {
  final String title;
  final String time;
  final String location;
  final String lecturer;
  final ClassStatus status;
  final bool isHighlighted;

  const ClassCard({
    super.key,
    required this.title,
    required this.time,
    required this.location,
    required this.lecturer,
    required this.status,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHighlighted 
            ? ClassTrackTheme.primaryBlue.withValues(alpha: 0.5)
            : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          width: isHighlighted ? 2 : 1,
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusTag(theme),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: ClassTrackTheme.primaryBlue,
              ),
              const SizedBox(width: 6),
              Text(
                location,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  lecturer,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTag(ThemeData theme) {
    final bool isCompleted = status == ClassStatus.completed;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted 
          ? const Color(0xFFD1FAE5).withValues(alpha: isDark ? 0.2 : 1.0) 
          : const Color(0xFFEEF2FF).withValues(alpha: isDark ? 0.2 : 1.0),
        borderRadius: BorderRadius.circular(8),
        border: isDark ? Border.all(
          color: isCompleted ? const Color(0xFF10B981).withValues(alpha: 0.3) : const Color(0xFF6366F1).withValues(alpha: 0.3),
        ) : null,
      ),
      child: Text(
        isCompleted ? 'COMPLETED' : 'UPCOMING',
        style: theme.textTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: isCompleted
              ? const Color(0xFF059669)
              : const Color(0xFF4F46E5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

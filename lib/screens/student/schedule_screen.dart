import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/design_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _anchorDate = DateTime.now().toUtc().add(const Duration(hours: 3));
    _initializeDynamicDates(_anchorDate);
    // Scroll to today's date after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
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
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _anchorDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildDateSelector(),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildTimelineItem(
                      time: '08:30',
                      status: TimelineStatus.completed,
                      child: const ClassCard(
                        title: 'Physics Lab II',
                        time: '08:30 AM - 10:00 AM',
                        location: 'Lab 102',
                        lecturer: 'Dr. Sarah Chen',
                        status: ClassStatus.completed,
                      ),
                    ),
                    _buildTimelineItem(
                      time: '10:00',
                      status: TimelineStatus.active,
                      child: const ClassCard(
                        title: 'Advanced Mathematics',
                        time: '10:00 AM - 11:30 AM',
                        location: 'Room 402',
                        lecturer: 'Prof. Marcus Thorne',
                        status: ClassStatus.upcoming,
                        isHighlighted: true,
                      ),
                    ),
                    _buildTimelineItem(
                      time: '13:00',
                      status: TimelineStatus.upcoming,
                      child: const ClassCard(
                        title: 'Software Engineering',
                        time: '01:00 PM - 02:30 PM',
                        location: 'Lab 305',
                        lecturer: 'Dr. Alan Turing',
                        status: ClassStatus.upcoming,
                      ),
                    ),
                    _buildTimelineItem(
                      time: '15:30',
                      status: TimelineStatus.upcoming,
                      child: const ClassCard(
                        title: 'Database Systems',
                        time: '03:30 PM - 05:00 PM',
                        location: 'Main Hall B',
                        lecturer: 'Prof. Grace Hopper',
                        status: ClassStatus.upcoming,
                      ),
                    ),
                    const SizedBox(height: 100), // Space for navigation
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Schedule',
                style: GoogleFonts.lexend(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMMM yyyy').format(_anchorDate),
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                color: ClassTrackTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
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
                color: isSelected ? ClassTrackTheme.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    )
                  else
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
                    style: GoogleFonts.lexend(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white70
                          : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _days[index]['date']!,
                    style: GoogleFonts.lexend(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
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
    required String time,
    required TimelineStatus status,
    required Widget child,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Text(
                  time,
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: status == TimelineStatus.active
                        ? ClassTrackTheme.primaryBlue
                        : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(height: 8),
                _buildStatusIndicator(status),
                Expanded(
                  child: Container(width: 1, color: const Color(0xFFE2E8F0)),
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
          Icons.check_circle,
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
            decoration: BoxDecoration(
              color: ClassTrackTheme.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
        );
      case TimelineStatus.upcoming:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFFE2E8F0),
            shape: BoxShape.circle,
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: isHighlighted
            ? Border(
                left: BorderSide(color: ClassTrackTheme.primaryBlue, width: 4),
              )
            : null,
        boxShadow: [
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
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusTag(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: ClassTrackTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: GoogleFonts.lexend(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.person_outline_rounded,
                size: 16,
                color: Color(0xFF94A3B8),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  lecturer,
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
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

  Widget _buildStatusTag() {
    final bool isCompleted = status == ClassStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFD1FAE5) : const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isCompleted ? 'COMPLETED' : 'UPCOMING',
        style: GoogleFonts.lexend(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isCompleted
              ? const Color(0xFF059669)
              : const Color(0xFF4F46E5),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

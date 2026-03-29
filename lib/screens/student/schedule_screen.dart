import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/design_theme.dart';
import '../../logic/api_service.dart';
import 'request_leave_screen.dart';
import '../../logic/cubits/attendance/attendance_cubit.dart';
import '../../utils/time_utils.dart';
import '../../widgets/glass_widgets.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with TickerProviderStateMixin {
  final ScrollController _dateScrollController = ScrollController();
  late int _selectedDayIndex;
  late List<Map<String, String>> _days;
  late DateTime _anchorDate;
  List<dynamic> _sessions = [];
  List<dynamic> _recurringSchedules = [];
  bool _isLoading = true;
  final ApiService _api = ApiService();

  late AnimationController _fadeController;
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _anchorDate = DateTime.now().toUtc().add(const Duration(hours: 3));
    _initializeDynamicDates(_anchorDate);
    _fetchSessions();

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedDay();
    });
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    _fadeController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _initializeDynamicDates(DateTime anchor) {
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
    _selectedDayIndex = daysSinceMonday;
  }

  Future<void> _fetchSessions() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final monday = DateTime.parse(_days[0]['fullDate']!);
      final sunday = DateTime.parse(_days[6]['fullDate']!).add(const Duration(hours: 23, minutes: 59));
      
      final results = await Future.wait([
        _api.getSessions(startDate: monday, endDate: sunday),
        _api.getRecurringSchedules(),
      ]);
      
      if (mounted) {
        setState(() {
          _sessions = results[0];
          _recurringSchedules = results[1];
          _isLoading = false;
        });
        _staggerController.reset();
        _staggerController.forward();
      }
    } catch (e) {
      debugPrint('Error fetching schedule: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToSelectedDay() {
    if (_dateScrollController.hasClients) {
      const double itemWidth = 86.0;
      final double targetOffset = (_selectedDayIndex * itemWidth) - 16;
      _dateScrollController.animateTo(
        targetOffset.clamp(0.0, _dateScrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    }
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
              primary: const Color(0xFF6366F1),
              surface: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedback.lightImpact();
      setState(() {
        _anchorDate = picked;
        _initializeDynamicDates(picked);
      });
      _fetchSessions();
      _scrollToSelectedDay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const DynamicBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, theme, isDark),
                const SizedBox(height: 16),
                _buildLiquidDateSelector(theme, isDark),
                const SizedBox(height: 24),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
                      : RefreshIndicator(
                          onRefresh: _fetchSessions,
                          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                          color: const Color(0xFF6366F1),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                ..._buildBentoSchedule(theme, isDark),
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
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Schedule',
                  style: GoogleFonts.firaCode(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMMM yyyy').format(_anchorDate).toUpperCase(),
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
            _buildGlassActionButton(
              icon: Icons.calendar_today_rounded,
              onPressed: () => _selectDate(context),
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassActionButton({required IconData icon, required VoidCallback onPressed, required bool isDark}) {
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
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            ),
            child: Icon(icon, color: const Color(0xFF6366F1), size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidDateSelector(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          controller: _dateScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _days.length,
          itemBuilder: (context, index) {
            final isSelected = _selectedDayIndex == index;
            return GestureDetector(
              onTap: () {
                if (!isSelected) {
                  HapticFeedback.selectionClick();
                  setState(() => _selectedDayIndex = index);
                  _scrollToSelectedDay();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                curve: Curves.easeOutBack,
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: !isSelected ? (isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.5)) : null,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? Colors.white24 : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _days[index]['day']!,
                      style: GoogleFonts.firaCode(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white70 : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _days[index]['date']!,
                      style: GoogleFonts.firaCode(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF0F172A)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildBentoSchedule(ThemeData theme, bool isDark) {
    final selectedDateString = _days[_selectedDayIndex]['fullDate']!;
    final selectedDate = DateTime.parse(selectedDateString);
    final selectedDayOfWeek = selectedDate.weekday - 1;

    final daySessions = _sessions.where((s) {
      final startTime = DateTime.parse(s['start_time']).toLocal();
      return DateFormat('yyyy-MM-dd').format(startTime) == selectedDateString;
    }).toList();

    final dayRecurring = _recurringSchedules.where((s) => s['day_of_week'] == selectedDayOfWeek).toList();

    if (daySessions.isEmpty && dayRecurring.isEmpty) {
      return [_buildEmptyState(theme, isDark)];
    }

    final List<Map<String, dynamic>> combined = [];
    for (var s in daySessions) combined.add({...s, 'isRecurring': false, 'sortTime': s['start_time']});
    for (var r in dayRecurring) {
      final startTimeStr = '${selectedDateString}T${r['start_time']}';
      final endTimeStr = '${selectedDateString}T${r['end_time']}';
      bool exists = daySessions.any((s) => s['course_id'] == r['course_id'] && s['start_time'].contains(r['start_time']));
      if (!exists) {
        combined.add({
          'topic': 'Recurring Session',
          'start_time': startTimeStr,
          'end_time': endTimeStr,
          'room': r['room'],
          'section': r['section'],
          'course_name': r['course_name'],
          'lecturer_name': r['lecturer_name'],
          'isRecurring': true,
          'sortTime': startTimeStr,
          'id': r['id'],
        });
      }
    }
    combined.sort((a, b) => a['sortTime'].compareTo(b['sortTime']));

    return List.generate(combined.length, (index) {
      final session = combined[index];
      final startTime = DateTime.parse(session['start_time']).toLocal();
      final endTime = DateTime.parse(session['end_time']).toLocal();
      final now = DateTime.now();

      TimelineStatus status;
      if (now.isAfter(endTime)) status = TimelineStatus.completed;
      else if (now.isAfter(startTime) && now.isBefore(endTime)) status = TimelineStatus.active;
      else status = TimelineStatus.upcoming;

      return _buildTransitionItem(
        index: index,
        child: BentoSessionCard(
          session: session,
          startTime: startTime,
          endTime: endTime,
          status: status,
          isDark: isDark,
          onTap: () => _showSessionOptions(context, session),
        ),
      );
    });
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark) {
    return FadeTransition(
      opacity: _fadeController,
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Icon(Icons.event_busy_rounded, size: 60, color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
            const SizedBox(height: 20),
            Text(
              'Freedom! Nothing scheduled.',
              style: GoogleFonts.firaCode(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white24 : Colors.black26,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitionItem({required int index, required Widget child}) {
    final start = index * 0.1;
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
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: child,
      ),
    );
  }

  void _showSessionOptions(BuildContext context, Map<String, dynamic> session) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.9) : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.black12, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 32),
              Text(session['course_name'] ?? 'Session Details', style: GoogleFonts.firaCode(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(session['topic'] ?? '', style: theme.textTheme.bodyMedium?.copyWith(color: isDark ? Colors.white60 : Colors.black54)),
              const SizedBox(height: 40),
              if (session['status'] == 'COMPLETED' || (session['isRecurring'] == false && DateTime.parse(session['end_time']).toLocal().isBefore(DateTime.now())))
                GlassButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RequestLeaveScreen(session: session)));
                  },
                  label: 'Request Leave',
                  scale: 1.0,
                  width: double.infinity,
                )
              else
                Text('Leave requests open after class ends.', style: GoogleFonts.firaCode(fontSize: 12, color: Colors.orange.withOpacity(0.8), fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class BentoSessionCard extends StatelessWidget {
  final Map<String, dynamic> session;
  final DateTime startTime;
  final DateTime endTime;
  final TimelineStatus status;
  final bool isDark;
  final VoidCallback onTap;

  const BentoSessionCard({
    super.key,
    required this.session,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = status == TimelineStatus.active 
        ? const Color(0xFF22C55E) 
        : (status == TimelineStatus.completed ? const Color(0xFF64748B) : const Color(0xFF6366F1));

    return GlassCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Side Indicator
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: accentColor,
                boxShadow: [
                  if (status == TimelineStatus.active)
                    BoxShadow(color: accentColor.withOpacity(0.6), blurRadius: 10, spreadRadius: 1)
                ],
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session['course_name'] ?? 'Untitled Course',
                            style: GoogleFonts.firaCode(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session['topic'] ?? 'General Session',
                      style: GoogleFonts.firaCode(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Interaction Row
                    Row(
                      children: [
                        _buildInfoItem(Icons.access_time_rounded, DateFormat('hh:mm a').format(startTime)),
                        const SizedBox(width: 16),
                        _buildInfoItem(Icons.location_on_rounded, session['room'] ?? 'TBD'),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            formatEthiopianTimeFromDateTime(startTime),
                            style: GoogleFonts.firaCode(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    String label = status == TimelineStatus.active ? 'LIVE' : (status == TimelineStatus.completed ? 'DONE' : 'NEXT');
    Color color = status == TimelineStatus.active 
        ? const Color(0xFF22C55E) 
        : (status == TimelineStatus.completed ? Colors.white24 : const Color(0xFF6366F1));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.firaCode(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: status == TimelineStatus.completed && isDark ? Colors.white38 : color,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: isDark ? Colors.white24 : Colors.black26),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.firaCode(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }
}

enum TimelineStatus { completed, active, upcoming }

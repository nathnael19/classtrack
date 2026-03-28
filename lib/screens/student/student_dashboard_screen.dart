import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
import 'package:classtrack/logic/cubits/attendance/attendance_cubit.dart';
import 'package:classtrack/screens/auth/login_screen.dart';

// Import modular widgets
import 'components/dashboard_header.dart';
import 'components/attendance_status_card.dart';
import 'components/next_class_hero_card.dart';
import 'components/upcoming_class_card.dart';
import 'qr_scanner_screen.dart';
import 'schedule_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'request_leave_screen.dart';
import 'course_materials_screen.dart';
import 'my_courses_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> _pages() => [
    BlocBuilder<AttendanceCubit, AttendanceState>(
      builder: (context, state) {
        return _DashboardHome(
          activeSessions: state.activeSessions,
          upcomingSessions: state.upcomingSessions,
          enrolledCourses: state.enrolledCourses,
          userData: state.userData,
          attendanceSummary: state.summary,
          isLoading: state.status == AttendanceStatus.loading,
          onRefresh: () => context.read<AttendanceCubit>().refresh(),
        );
      },
    ),
    const ScheduleScreen(),
    const AttendanceHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _pages()),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: BlocBuilder<AttendanceCubit, AttendanceState>(
          builder: (context, state) {
            return Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: ClassTrackTheme.primaryBlue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRScannerScreen(
                          sessionId: state.activeSessions.isNotEmpty
                              ? state.activeSessions[0]['id']
                              : null,
                        ),
                      ),
                    );
                    if (result == true) {
                      if (context.mounted) {
                        context.read<AttendanceCubit>().refresh();
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(32),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BottomAppBar(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 85,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: const CircularNotchedRectangle(),
      notchMargin: 10,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _buildNavItem(
              icon: Icons.calendar_today_rounded,
              label: 'Schedule',
              index: 1,
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              icon: Icons.history_rounded,
              label: 'History',
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isSelected = _selectedIndex == index;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ClassTrackTheme.primaryBlue
                  : (isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFF94A3B8)),
              size: 26,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected
                    ? ClassTrackTheme.primaryBlue
                    : (isDark
                          ? const Color(0xFF64748B)
                          : const Color(0xFF94A3B8)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSessionOptions(BuildContext context, Map<String, dynamic> session) {
  final theme = Theme.of(context);
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
            session['topic'] ?? session['course_name'] ?? 'Class Session',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(
              Icons.menu_book_rounded,
              color: ClassTrackTheme.primaryBlue,
            ),
            title: const Text('View Materials'),
            subtitle: const Text('Access lecture notes and resources'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseMaterialsScreen(
                    courseId: session['course_id'],
                    courseName: session['course_name'] ?? 'Course Materials',
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.edit_calendar_rounded,
              color: ClassTrackTheme.primaryBlue,
            ),
            title: const Text('Request Leave'),
            subtitle: const Text('Submit a leave request for this session'),
            onTap: () {
              Navigator.pop(ctx);
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
        ],
      ),
    ),
  );
}

class _DashboardHome extends StatelessWidget {
  final List<dynamic> activeSessions;
  final List<dynamic> upcomingSessions;
  final List<dynamic> enrolledCourses;
  final Map<String, dynamic>? userData;
  final Map<String, dynamic>? attendanceSummary;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _DashboardHome({
    required this.activeSessions,
    required this.upcomingSessions,
    required this.enrolledCourses,
    this.userData,
    this.attendanceSummary,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final DateTime nowGmt3 = DateTime.now().toUtc().add(
      const Duration(hours: 3),
    );
    final String dateStr = DateFormat('EEEE, MMM d').format(nowGmt3);

    String greeting;
    int hour = nowGmt3.hour;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    final String userName = userData?['name'] ?? 'Student';

    return RefreshIndicator(
      onRefresh: onRefresh,
      color: ClassTrackTheme.primaryBlue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(date: dateStr, greeting: '$greeting, $userName'),
            const SizedBox(height: 32),
            AttendanceStatusCard(
              percent: attendanceSummary?['percent']?.toDouble() ?? 0.0,
              status: attendanceSummary?['status'] ?? 'Calculating...',
              message:
                  attendanceSummary?['message'] ?? 'Fetching your records...',
            ),
            const SizedBox(height: 32),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (activeSessions.isNotEmpty)
              NextClassHeroCard(
                title: activeSessions[0]['course_name'] ?? 'Active Session',
                section: activeSessions[0]['section'],
                time: 'NOW',
                location: activeSessions[0]['room'] ?? 'N/A',
                geofenceStatus: 'Ongoing Session',
                isPresent: activeSessions[0]['is_present'] ?? false,
                onViewMap: () {},
              )
            else
              _buildNoActiveClassCard(theme, isDark),
            if (enrolledCourses.isNotEmpty) ...[
              const SizedBox(height: 32),
              _buildMyCoursesSection(context, theme, isDark),
            ],
            const SizedBox(height: 32),
            _buildScanButton(context),
            const SizedBox(height: 40),
            _buildUpcomingClassesHeader(theme, isDark),
            const SizedBox(height: 16),
            _buildClassList(context, theme, isDark),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildNoActiveClassCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF8FAFC)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFF94A3B8),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'No active classes right now.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRScannerScreen(
                sessionId: activeSessions.isNotEmpty
                    ? activeSessions[0]['id']
                    : null,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ClassTrackTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 8,
          shadowColor: ClassTrackTheme.primaryBlue.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner_rounded, size: 26),
            const SizedBox(width: 12),
            Text(
              'Scan Attendance',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyCoursesSection(BuildContext context, ThemeData theme, bool isDark) {
    final displayCourses = enrolledCourses.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Courses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (enrolledCourses.length > 4)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: ClassTrackTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text('See All'),
              )
            else if (enrolledCourses.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyCoursesScreen()),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: ClassTrackTheme.primaryBlue.withOpacity(0.7),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Icon(Icons.arrow_forward_ios, size: 14),
              ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 4),
            scrollDirection: Axis.horizontal,
            itemCount: displayCourses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final course = displayCourses[index];
              final courseId = course['id'] as int;
              final courseName = course['name'] ?? course['course_name'] ?? 'Course';
              final courseCode = course['code'] ?? course['course_code'] ?? '';

              final colors = [
                ClassTrackTheme.primaryBlue,
                const Color(0xFF8B5CF6),
                const Color(0xFF059669),
                const Color(0xFFD97706),
                const Color(0xFFDC2626),
              ];
              final color = colors[index % colors.length];

              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CourseMaterialsScreen(
                      courseId: courseId,
                      courseName: courseName,
                    ),
                  ),
                ),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [color, color.withOpacity(0.75)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Icon(Icons.menu_book_rounded, color: Colors.white70, size: 20),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (courseCode.isNotEmpty)
                            Text(
                              courseCode,
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          const SizedBox(height: 2),
                          Text(
                            courseName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingClassesHeader(ThemeData theme, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upcoming Classes',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        TextButton(
          onPressed: () {},
          child: Text(
            'See All',
            style: theme.textTheme.labelLarge?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: ClassTrackTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassList(BuildContext context, ThemeData theme, bool isDark) {
    if (upcomingSessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 48,
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 16),
              Text(
                'No upcoming sessions scheduled.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: upcomingSessions.map((session) {
        final startTime = DateTime.parse(session['start_time']).toLocal();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: InkWell(
            onTap: () => _showSessionOptions(context, session),
            borderRadius: BorderRadius.circular(16),
            child: UpcomingClassCard(
              icon: Icons.school_rounded,
              iconColor: ClassTrackTheme.primaryBlue,
              iconBg: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
              title:
                  session['topic'] ?? session['course_name'] ?? 'Class Session',
              section: session['section'],
              time: DateFormat('h:mm a').format(startTime),
              location: session['room'] ?? 'N/A',
            ),
          ),
        );
      }).toList(),
    );
  }
}

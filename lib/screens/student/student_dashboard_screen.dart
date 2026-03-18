import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/api_service.dart';
import 'package:classtrack/logic/cubits/auth/auth_cubit.dart';
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

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;
  List<dynamic> _activeSessions = [];
  List<dynamic> _upcomingSessions = [];
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchActiveSessions(),
      _fetchUpcomingSessions(),
      _fetchUserProfile(),
    ]);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchUpcomingSessions() async {
    try {
      final api = ApiService();
      final response = await api.getUpcomingSessions();
      if (mounted) {
        setState(() {
          _upcomingSessions = response;
        });
      }
    } catch (e) {
      debugPrint('Error fetching upcoming sessions: $e');
    }
  }

  Future<void> _fetchUserProfile() async {
    try {
      final api = ApiService();
      final response = await api.getCurrentUser();
      if (mounted) {
        setState(() {
          _userData = response;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
    }
  }

  Future<void> _fetchActiveSessions() async {
    try {
      final api = ApiService();
      final response = await api.dio.get(api.v1('/sessions/active'));
      if (mounted) {
        setState(() {
          _activeSessions = response.data;
        });
      }
    } catch (e) {
      debugPrint('Error fetching active sessions: $e');
    }
  }

  List<Widget> _pages() => [
    _DashboardHome(
      activeSessions: _activeSessions,
      upcomingSessions: _upcomingSessions,
      userData: _userData,
      isLoading: _isLoading,
      onRefresh: _fetchDashboardData,
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
        backgroundColor: const Color(0xFFFAFAFA),
        body: IndexedStack(index: _selectedIndex, children: _pages()),
        bottomNavigationBar: _buildBottomNavigationBar(),
        floatingActionButton: Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            color: ClassTrackTheme.primaryBlue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 12,
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
                      sessionId: _activeSessions.isNotEmpty ? _activeSessions[0]['id'] : null,
                    ),
                  ),
                );
                if (result == true) {
                  _fetchActiveSessions();
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
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
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
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ClassTrackTheme.primaryBlue
                  : const Color(0xFF94A3B8),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? ClassTrackTheme.primaryBlue
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHome extends StatelessWidget {
  final List<dynamic> activeSessions;
  final List<dynamic> upcomingSessions;
  final Map<String, dynamic>? userData;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _DashboardHome({
    required this.activeSessions,
    required this.upcomingSessions,
    this.userData,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
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

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardHeader(date: dateStr, greeting: '$greeting, $userName'),
              const SizedBox(height: 24),
              const AttendanceStatusCard(
                percent: 0.85,
                status: 'Great Standing',
                message: 'You missed only 2 classes this month.',
              ),
              const SizedBox(height: 24),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (activeSessions.isNotEmpty)
                NextClassHeroCard(
                  title: activeSessions[0]['course_name'] ?? 'Active Session',
                  time: 'NOW',
                  location: activeSessions[0]['room'] ?? 'N/A',
                  geofenceStatus: 'Ongoing Session',
                  onViewMap: () {},
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No active classes right now.'),
                  ),
                ),
              const SizedBox(height: 24),
              _buildScanButton(context),
              // ... rest of the children (Upcoming Classes logic could also be updated but let's keep it simple)
              const SizedBox(height: 32),
              _buildUpcomingClassesHeader(),
              const SizedBox(height: 16),
              _buildClassList(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QRScannerScreen(
                sessionId: activeSessions.isNotEmpty ? activeSessions[0]['id'] : null,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: ClassTrackTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: ClassTrackTheme.primaryBlue.withValues(alpha: 0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner_rounded, size: 24),
            const SizedBox(width: 12),
            Text(
              'Scan Attendance',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingClassesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upcoming Classes',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        TextButton(
          onPressed: () {
            // Navigation handled by bottom bar
          },
          child: Text(
            'See All',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: ClassTrackTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassList() {
    if (upcomingSessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: Text(
            'No upcoming classes.',
            style: GoogleFonts.lexend(color: const Color(0xFF64748B)),
          ),
        ),
      );
    }

    return Column(
      children: upcomingSessions.map((session) {
        final startTime = DateTime.parse(session['start_time']).toLocal();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: UpcomingClassCard(
            icon: Icons.school_rounded,
            iconColor: const Color(0xFF6366F1),
            iconBg: const Color(0xFFEEF2FF),
            title: session['topic'] ?? 'Class Session',
            time: DateFormat('h:mm a').format(startTime),
            location: session['room'] ?? 'N/A',
          ),
        );
      }).toList(),
    );
  }
}

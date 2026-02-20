import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// Import modular widgets
import 'components/dashboard_header.dart';
import 'components/attendance_status_card.dart';
import 'components/next_class_hero_card.dart';
import 'components/upcoming_class_card.dart';
import 'qr_scanner_screen.dart';
import 'schedule_screen.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _DashboardHome(),
    const ScheduleScreen(),
    const Center(child: Text('History')),
    const Center(child: Text('Profile')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: IndexedStack(index: _selectedIndex, children: _pages),
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
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const QRScannerScreen(),
                ),
              );
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
  const _DashboardHome();

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

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DashboardHeader(date: dateStr, greeting: '$greeting, Nathnael'),
            const SizedBox(height: 24),
            const AttendanceStatusCard(
              percent: 0.85,
              status: 'Great Standing',
              message: 'You missed only 2 classes this month.',
            ),
            const SizedBox(height: 24),
            NextClassHeroCard(
              title: 'Advanced Mathematics',
              time: '10:00 AM',
              location: 'Room 402',
              geofenceStatus: 'Inside Campus Geofence',
              onViewMap: () {
                // TODO: Implement View Map
              },
            ),
            const SizedBox(height: 24),
            _buildScanButton(context),
            const SizedBox(height: 32),
            _buildUpcomingClassesHeader(),
            const SizedBox(height: 16),
            _buildClassList(),
            const SizedBox(height: 80), // Spacing for bottom nav
          ],
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
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
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
    return const Column(
      children: [
        UpcomingClassCard(
          icon: Icons.code_rounded,
          iconColor: Color(0xFF6366F1),
          iconBg: Color(0xFFEEF2FF),
          title: 'Software Engineering',
          time: '1:00 PM',
          location: 'Lab 305',
        ),
        SizedBox(height: 16),
        UpcomingClassCard(
          icon: Icons.storage_rounded,
          iconColor: Color(0xFFF59E0B),
          iconBg: Color(0xFFFFFBEB),
          title: 'Database Systems',
          time: '3:30 PM',
          location: 'Main Hall B',
        ),
        SizedBox(height: 16),
        UpcomingClassCard(
          icon: Icons.language_rounded,
          iconColor: Color(0xFF10B981),
          iconBg: Color(0xFFECFDF5),
          title: 'Web Technology',
          time: 'Tomorrow • 09:00 AM',
          location: 'Remote',
          isOnline: true,
        ),
      ],
    );
  }
}

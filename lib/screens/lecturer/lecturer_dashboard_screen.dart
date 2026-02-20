import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'components/lecturer_header.dart';
import 'components/stat_card.dart';
import 'components/start_session_banner.dart';
import 'components/lecturer_class_card.dart';

class LecturerDashboardScreen extends StatefulWidget {
  const LecturerDashboardScreen({super.key});

  @override
  State<LecturerDashboardScreen> createState() =>
      _LecturerDashboardScreenState();
}

class _LecturerDashboardScreenState extends State<LecturerDashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildHome(),
            const Center(child: Text('History')),
            const Center(child: Text('Classes')),
            const Center(child: Text('Settings')),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const LecturerHeader(),
          const SizedBox(height: 32),
          const Row(
            children: [
              StatCard(
                icon: Icons.trending_up_rounded,
                label: 'Avg. Attendance',
                value: '92%',
                trend: '+2.4% from last month',
                iconColor: Color(0xFF3F68E4),
              ),
              SizedBox(width: 16),
              StatCard(
                icon: Icons.people_outline_rounded,
                label: 'Total Students',
                value: '1,240',
                trend: 'Across 4 modules',
                iconColor: Color(0xFF6366F1),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const StartSessionBanner(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Active Classes",
                style: GoogleFonts.lexend(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ClassTrackTheme.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LecturerClassCard(
            isLive: true,
            code: 'CS101',
            title: 'Data Structures',
            time: '10:00 AM - 12:00 PM',
            location: 'Auditorium B, Science Block',
            imageUrl:
                'https://images.unsplash.com/photo-1541339907198-e08756ebafe3?auto=format&fit=crop&q=80&w=400',
            onViewStudents: () {},
            onManageSession: () {},
          ),
          const SizedBox(height: 16),
          const LecturerClassCard(
            isLive: false,
            code: 'CS202',
            title: 'Algorithms',
            time: '02:00 PM - 04:00 PM',
            location: 'Lab 4, Innovation Center',
            imageUrl:
                'https://images.unsplash.com/photo-1544006659-f0b21f04cb1d?auto=format&fit=crop&q=80&w=400',
          ),
          const SizedBox(height: 100), // Space for bottom nav
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFF1F5F9))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.grid_view_rounded,
            label: 'Dashboard',
            index: 0,
          ),
          _buildNavItem(
            icon: Icons.history_rounded,
            label: 'History',
            index: 1,
          ),
          _buildNavItem(icon: Icons.book_outlined, label: 'Classes', index: 2),
          _buildNavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
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
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                fontSize: 11,
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

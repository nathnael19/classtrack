import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AttendanceListScreen extends StatefulWidget {
  final String section;

  const AttendanceListScreen({super.key, this.section = 'Sec A'});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _students = [
    {
      'name': 'Benjamin Turner',
      'id': '2024-UX-0129',
      'status': 'PRESENT',
      'time': '09:02 AM',
      'avatar': 'https://i.pravatar.cc/150?u=benjamin',
    },
    {
      'name': 'Sophia Martinez',
      'id': '2024-UX-0084',
      'status': 'LATE',
      'time': '09:18 AM',
      'avatar': 'https://i.pravatar.cc/150?u=sophia',
    },
    {
      'name': 'David Chen',
      'id': '2024-UX-0331',
      'status': 'ABSENT',
      'time': '--',
      'avatar': 'https://i.pravatar.cc/150?u=david',
    },
    {
      'name': 'Isabella Rossi',
      'id': '2024-UX-0145',
      'status': 'PRESENT',
      'time': '08:58 AM',
      'avatar': 'https://i.pravatar.cc/150?u=isabella',
    },
    {
      'name': 'Liam Gallagher',
      'id': '2024-UX-0092',
      'status': 'ABSENT',
      'time': '--',
      'avatar': 'https://i.pravatar.cc/150?u=liam',
    },
    {
      'name': 'Emma Wilson',
      'id': '2024-UX-0112',
      'status': 'PRESENT',
      'time': '09:05 AM',
      'avatar': 'https://i.pravatar.cc/150?u=emma',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSummaryCards(),
                  const SizedBox(height: 20),
                  _buildGeofencingBanner(),
                  const SizedBox(height: 24),
                  _buildSectionHeader(),
                  const SizedBox(height: 16),
                  _buildStudentList(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xFF1E293B),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Text(
            'ATTENDANCE LIST',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
          Text(
            widget.section,
            style: GoogleFonts.lexend(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: Color(0xFF1E293B)),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search student name or ID...',
            hintStyle: GoogleFonts.lexend(
              color: const Color(0xFF94A3B8),
              fontSize: 15,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Color(0xFF94A3B8),
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('PRESENT', '42', '84%', const Color(0xFF3F68E4)),
        _buildStatCard('LATE', '03', '6%', const Color(0xFFF59E0B)),
        _buildStatCard('ABSENT', '05', '10%', const Color(0xFF94A3B8)),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String percentage,
    Color color,
  ) {
    return Container(
      width: (MediaQuery.of(context).size.width - 64) / 3,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  percentage,
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeofencingBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF3F68E4),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Geofencing Active',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                Text(
                  'Room 402 • 50m radius',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    color: const Color(0xFF6366F1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'LIVE',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF3F68E4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Student Records',
          style: GoogleFonts.lexend(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(
            Icons.filter_list_rounded,
            size: 18,
            color: Color(0xFF3F68E4),
          ),
          label: Text(
            'Filter',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3F68E4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = _students[index];
        return _buildStudentTile(student);
      },
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    Color statusBgColor;
    Color statusTextColor;
    switch (student['status']) {
      case 'PRESENT':
        statusBgColor = const Color(0xFFE0E7FF);
        statusTextColor = const Color(0xFF3F68E4);
        break;
      case 'LATE':
        statusBgColor = const Color(0xFFFEF3C7);
        statusTextColor = const Color(0xFFD97706);
        break;
      case 'ABSENT':
      default:
        statusBgColor = const Color(0xFFF1F5F9);
        statusTextColor = const Color(0xFF64748B);
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(student['avatar']),
            backgroundColor: const Color(0xFFF1F5F9),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: GoogleFonts.lexend(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'ID: ${student['id']}',
                  style: GoogleFonts.lexend(
                    fontSize: 11,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  student['status'],
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: statusTextColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              if (student['status'] != 'ABSENT')
                Text(
                  'Scan: ${student['time']}',
                  style: GoogleFonts.lexend(
                    fontSize: 10,
                    color: const Color(0xFF94A3B8),
                  ),
                )
              else
                const Text('...', style: TextStyle(color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, color: Color(0xFFCBD5E1)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.done_all_rounded, size: 20),
              label: const Text('Mark All Remaining Present'),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                side: BorderSide.none,
                foregroundColor: const Color(0xFF3F68E4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F68E4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF3F68E4).withValues(alpha: 0.4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Finalize Attendance Session',
                    style: GoogleFonts.lexend(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

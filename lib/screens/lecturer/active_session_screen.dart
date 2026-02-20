import 'dart:async';
import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'attendance_list_screen.dart';

class ActiveSessionScreen extends StatefulWidget {
  final String courseName;
  final String duration;
  final double proximity;

  const ActiveSessionScreen({
    super.key,
    this.courseName = 'Advanced Mathematics',
    this.duration = '10 min',
    this.proximity = 30.0,
  });

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  late int _remainingSeconds;
  Timer? _timer;
  final int _presentCount = 42;
  final int _totalCount = 60;

  @override
  void initState() {
    super.initState();
    // Parse duration string to seconds
    final mins = int.tryParse(widget.duration.split(' ')[0]) ?? 10;
    _remainingSeconds = mins * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFBFB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text(
              'Active QR Session',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              'LIVE TRACKING',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: ClassTrackTheme.primaryBlue,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_horiz_rounded,
              color: Color(0xFF0F172A),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildCourseInfoCard(),
              const SizedBox(height: 32),
              _buildQRCodeDisplay(),
              const SizedBox(height: 16),
              Text(
                'Scanning range: Up to 5 meters',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      label: 'TIME REMAINING',
                      value: _formatTime(_remainingSeconds),
                      subtext: 'Minutes     Seconds',
                      valueColor: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      label: 'ATTENDANCE',
                      value: '$_presentCount / $_totalCount',
                      subtext: 'STUDENTS PRESENT',
                      valueColor: ClassTrackTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildEndSessionButton(),
              const SizedBox(height: 48),
              _buildStudentPresenceHeader(),
              const SizedBox(height: 24),
              _buildStudentAvatarList(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school_outlined,
              color: ClassTrackTheme.primaryBlue,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseName,
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Lecture 4 • Hall A-102',
                  style: GoogleFonts.lexend(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _buildGeofenceBadge(),
        ],
      ),
    );
  }

  Widget _buildGeofenceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: Color(0xFF22C55E), size: 14),
          const SizedBox(width: 4),
          Text(
            'GEOFENCE ACTIVE',
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeDisplay() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFDDE4FF), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        clipBehavior: Clip.antiAlias,
        child: AspectRatio(
          aspectRatio: 1,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Use a real image of a QR code in a mockup setting if possible,
              // for now let's use a nice Unsplash image that looks like a QR mockup
              Image.network(
                'https://images.unsplash.com/photo-1595079676339-1534801ad6cf?auto=format&fit=crop&q=80&w=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.qr_code_2_rounded,
                  size: 150,
                  color: Color(0xFF94A3B8),
                ),
              ),
              // Overlay a QR symbol if the image doesn't look enough like one
              // (The requested design has a framed QR)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subtext,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            style: GoogleFonts.lexend(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFCBD5E1),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndSessionButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.stop_circle_outlined, color: Colors.white),
        label: Text(
          'End Session',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444), // Red as per design
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.4),
        ),
      ),
    );
  }

  Widget _buildStudentPresenceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Students Enrolled',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AttendanceListScreen(
                  section: 'Hall A-102', // Mocking based on UI
                ),
              ),
            );
          },
          child: Text(
            'View List',
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

  Widget _buildStudentAvatarList() {
    final students = [
      {'name': 'Alex J.', 'img': 'https://i.pravatar.cc/150?u=1'},
      {'name': 'Sarah M.', 'img': 'https://i.pravatar.cc/150?u=2'},
      {'name': 'Daniel K.', 'img': 'https://i.pravatar.cc/150?u=3'},
      {'name': 'Elena R.', 'img': 'https://i.pravatar.cc/150?u=4'},
      {'name': 'James W.', 'img': 'https://i.pravatar.cc/150?u=5'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: students.length,
        separatorBuilder: (context, index) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ClassTrackTheme.primaryBlue,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFF1F5F9),
                  backgroundImage: NetworkImage(students[index]['img']!),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                students[index]['name']!,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

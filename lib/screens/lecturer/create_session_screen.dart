import 'package:flutter/material.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  String? _selectedCourse;
  String? _selectedLocation;
  int _selectedDuration = 5; // Default 5 min
  double _proximityLimit = 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Session',
          style: GoogleFonts.lexend(
            color: const Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF64748B)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFF1F5F9), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: Icons.school_outlined,
                title: 'COURSE DETAILS',
              ),
              const SizedBox(height: 24),
              _buildLabel('Select Course'),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Choose your course...',
                value: _selectedCourse,
                onChanged: (val) => setState(() => _selectedCourse = val),
                items: [
                  'CS101: Data Structures',
                  'CS202: Algorithms',
                  'CS303: Operating Systems',
                ],
                icon: Icons.unfold_more_rounded,
              ),
              const SizedBox(height: 24),
              _buildLabel('Classroom Location'),
              const SizedBox(height: 8),
              _buildDropdown(
                hint: 'Select location...',
                value: _selectedLocation,
                onChanged: (val) => setState(() => _selectedLocation = val),
                items: [
                  'Auditorium B, Science Block',
                  'Lab 4, Innovation Center',
                  'Room 203, Arts Building',
                ],
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 40),
              _buildSectionHeader(
                icon: Icons.timer_outlined,
                title: 'ATTENDANCE WINDOW',
              ),
              const SizedBox(height: 24),
              _buildDurationSelector(),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'The QR code will expire after the selected duration.',
                  style: GoogleFonts.lexend(
                    fontSize: 13,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              _buildSectionHeader(
                icon: Icons.location_on_outlined,
                title: 'PROXIMITY LIMIT',
                trailing: Text(
                  '${_proximityLimit.toInt()}m',
                  style: GoogleFonts.lexend(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ClassTrackTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildProximitySlider(),
              const SizedBox(height: 32),
              _buildGeofencingInfo(),
              const SizedBox(height: 40),
              _buildGenerateButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Icon(icon, color: ClassTrackTheme.primaryBlue, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: GoogleFonts.lexend(
              fontSize: 15,
              color: const Color(0xFF94A3B8),
            ),
          ),
          isExpanded: true,
          icon: Icon(icon, color: const Color(0xFF94A3B8)),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: GoogleFonts.lexend(
                  fontSize: 15,
                  color: const Color(0xFF0F172A),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _buildDurationButton(5),
          _buildDurationButton(10),
          _buildDurationButton(15),
        ],
      ),
    );
  }

  Widget _buildDurationButton(int min) {
    final isSelected = _selectedDuration == min;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedDuration = min),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? ClassTrackTheme.primaryBlue
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: ClassTrackTheme.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$min min',
              style: GoogleFonts.lexend(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF3F68E4),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProximitySlider() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: ClassTrackTheme.primaryBlue.withValues(
              alpha: 0.2,
            ),
            inactiveTrackColor: const Color(0xFFF1F5F9),
            thumbColor: ClassTrackTheme.primaryBlue,
            overlayColor: ClassTrackTheme.primaryBlue.withValues(alpha: 0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: _proximityLimit,
            min: 20,
            max: 50,
            onChanged: (val) => setState(() => _proximityLimit = val),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSliderLabel('20M'),
              _buildSliderLabel('35M'),
              _buildSliderLabel('50M'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.lexend(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF94A3B8),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildGeofencingInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF3F68E4),
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  height: 1.5,
                  color: const Color(0xFF475569),
                ),
                children: [
                  const TextSpan(text: 'Geofencing is '),
                  TextSpan(
                    text: 'Active',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: ClassTrackTheme.primaryBlue,
                    ),
                  ),
                  const TextSpan(text: '. Students must be within '),
                  TextSpan(
                    text: '${_proximityLimit.toInt()} meters',
                    style: GoogleFonts.lexend(
                      fontWeight: FontWeight.bold,
                      color: ClassTrackTheme.primaryBlue,
                    ),
                  ),
                  const TextSpan(
                    text: ' of the classroom coordinates to mark attendance.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Implement QR generation
        },
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: Text(
          'Generate QR Code',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: ClassTrackTheme.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 10,
          shadowColor: ClassTrackTheme.primaryBlue.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

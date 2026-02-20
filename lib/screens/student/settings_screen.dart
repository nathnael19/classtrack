import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classtrack/theme/design_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _pushNotifications = true;
  bool _biometricLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context),
              const SizedBox(height: 24),
              Text(
                'Settings',
                style: GoogleFonts.lexend(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader('GENERAL PREFERENCES'),
              _buildSettingsGroup([
                _buildSwitchItem(
                  icon: Icons.dark_mode_outlined,
                  title: 'Dark Mode',
                  value: _darkMode,
                  onChanged: (val) => setState(() => _darkMode = val),
                ),
                _buildSwitchItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader('SECURITY & PERMISSIONS'),
              _buildSettingsGroup([
                _buildSwitchItem(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  value: _biometricLogin,
                  onChanged: (val) => setState(() => _biometricLogin = val),
                ),
                _buildStatusItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location Access',
                  subtitle: 'Required for geofencing',
                  status: 'Enabled',
                  statusColor: const Color(0xFF22C55E),
                  statusBg: const Color(0xFFF0FDF4),
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader('ABOUT'),
              _buildSettingsGroup([
                _buildNavigationItem(
                  icon: Icons.security_outlined,
                  title: 'Privacy Policy',
                ),
                _buildNavigationItem(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                ),
              ]),
              const SizedBox(height: 48),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: ClassTrackTheme.primaryBlue,
          ),
          const SizedBox(width: 4),
          Text(
            'Profile',
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: ClassTrackTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF94A3B8),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          if (index == items.length - 1) return items[index];
          return Column(
            children: [
              items[index],
              const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIconFrame(icon),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: ClassTrackTheme.primaryBlue,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xFFE2E8F0),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildStatusItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
    required Color statusBg,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: _buildIconFrame(icon),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: const Color(0xFF94A3B8),
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              status,
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem({required IconData icon, required String title}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildIconFrame(icon),
      title: Text(
        title,
        style: GoogleFonts.lexend(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF334155),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFFCBD5E1),
      ),
      onTap: () {},
    );
  }

  Widget _buildIconFrame(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'ClassTrack for Education',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version 1.0.4 (24B102)',
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

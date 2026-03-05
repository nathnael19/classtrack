import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:classtrack/logic/cubits/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _pushNotifications = false;
  bool _biometricLogin = false;
  bool _locationAccess = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Check actual permission status to sync UI
    final isNotifGranted = await Permission.notification.isGranted;
    final isLocGranted = await Permission.location.isGranted;

    setState(() {
      _pushNotifications =
          (prefs.getBool('push_notifications') ?? false) && isNotifGranted;
      _biometricLogin = prefs.getBool('biometric_login') ?? false;
      _locationAccess =
          (prefs.getBool('location_access') ?? false) && isLocGranted;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    if (value == true) {
      if (key == 'biometric_login') {
        final bool canAuthenticateWithBiometrics =
            await auth.canCheckBiometrics;
        final bool canAuthenticate =
            canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (!canAuthenticate) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometric authentication is not available on this device.',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        try {
          final bool didAuthenticate = await auth.authenticate(
            localizedReason: 'Please authenticate to enable biometric login',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );

          if (!didAuthenticate) return;
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication error: $e'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      Permission? permission;
      if (key == 'push_notifications') permission = Permission.notification;
      if (key == 'location_access') permission = Permission.location;

      if (permission != null) {
        final status = await permission.request();
        if (!mounted) return;

        if (!status.isGranted) {
          String message = 'Permission denied';
          if (key == 'push_notifications')
            message = 'Notification permission denied';
          if (key == 'location_access') message = 'Location permission denied';

          SnackBarAction? action;
          if (status.isPermanentlyDenied) {
            message = 'Permissions: Permanently Disabled';
            action = SnackBarAction(
              label: 'SETTINGS',
              onPressed: () => openAppSettings(),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              action: action,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    setState(() {
      if (key == 'dark_mode') _darkMode = value;
      if (key == 'push_notifications') _pushNotifications = value;
      if (key == 'biometric_login') _biometricLogin = value;
      if (key == 'location_access') _locationAccess = value;
    });
  }

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
                  value: context.watch<ThemeCubit>().isDarkMode,
                  onChanged: (val) {
                    _updateSetting('dark_mode', val);
                    context.read<ThemeCubit>().toggleTheme(val);
                  },
                ),
                _buildSwitchItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (val) => _updateSetting('push_notifications', val),
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader('SECURITY & PERMISSIONS'),
              _buildSettingsGroup([
                _buildSwitchItem(
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  value: _biometricLogin,
                  onChanged: (val) => _updateSetting('biometric_login', val),
                ),
                _buildSwitchItem(
                  icon: Icons.location_on_outlined,
                  title: 'Location Access',
                  value: _locationAccess,
                  onChanged: (val) => _updateSetting('location_access', val),
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

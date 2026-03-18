import 'package:flutter/material.dart';
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
          if (key == 'push_notifications') {
            message = 'Notification permission denied';
          }
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

    if (!mounted) return;

    setState(() {
      if (key == 'push_notifications') _pushNotifications = value;
      if (key == 'biometric_login') _biometricLogin = value;
      if (key == 'location_access') _locationAccess = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBackButton(context, theme),
              const SizedBox(height: 32),
              Text(
                'Settings',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(theme, isDark, 'GENERAL PREFERENCES'),
              _buildSettingsGroup(isDark, [
                _buildSwitchItem(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.dark_mode_rounded,
                  title: 'Dark Mode',
                  value: context.watch<ThemeCubit>().isDarkMode,
                  onChanged: (val) {
                    _updateSetting('dark_mode', val);
                    context.read<ThemeCubit>().toggleTheme(val);
                  },
                ),
                _buildSwitchItem(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  value: _pushNotifications,
                  onChanged: (val) => _updateSetting('push_notifications', val),
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader(theme, isDark, 'SECURITY & PERMISSIONS'),
              _buildSettingsGroup(isDark, [
                _buildSwitchItem(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.fingerprint_rounded,
                  title: 'Biometric Login',
                  value: _biometricLogin,
                  onChanged: (val) => _updateSetting('biometric_login', val),
                ),
                _buildSwitchItem(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.location_history_rounded,
                  title: 'Location Access',
                  value: _locationAccess,
                  onChanged: (val) => _updateSetting('location_access', val),
                ),
              ]),
              const SizedBox(height: 32),
              _buildSectionHeader(theme, isDark, 'ABOUT'),
              _buildSettingsGroup(isDark, [
                _buildNavigationItem(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.policy_rounded,
                  title: 'Privacy Policy',
                ),
                _buildNavigationItem(
                  theme: theme,
                  isDark: isDark,
                  icon: Icons.gavel_rounded,
                  title: 'Terms of Service',
                ),
              ]),
              const SizedBox(height: 60),
              _buildFooter(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, ThemeData theme) {
    return InkWell(
      onTap: () => Navigator.pop(context),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: ClassTrackTheme.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            'Profile',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: ClassTrackTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, bool isDark, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 16),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(bool isDark, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Divider(
                height: 1, 
                color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9), 
                indent: 60,
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSwitchItem({
    required ThemeData theme,
    required bool isDark,
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: _buildIconFrame(isDark, icon),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: ClassTrackTheme.primaryBlue,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }

  Widget _buildNavigationItem({
    required ThemeData theme, 
    required bool isDark,
    required IconData icon, 
    required String title,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: _buildIconFrame(isDark, icon),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Color(0xFFCBD5E1),
      ),
      onTap: () {},
    );
  }

  Widget _buildIconFrame(bool isDark, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: const Color(0xFF64748B), size: 20),
    );
  }

  Widget _buildFooter(ThemeData theme, bool isDark) {
    return Center(
      child: Column(
        children: [
          Text(
            'ClassTrack for Education',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Version 1.0.4 (24B102)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
        ],
      ),
    );
  }
}

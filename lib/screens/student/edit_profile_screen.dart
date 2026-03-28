import 'dart:ui';
import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter/material.dart';
import '../../logic/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _programController;
  late TextEditingController _enrollmentYearController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  final ApiService _apiService = ApiService();

  List<dynamic> _departments = [];
  int? _selectedDepartmentId;
  String? _selectedGender;
  bool _isLoadingDepts = true;
  bool _isSaving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(text: widget.userData['phone_number']);
    _programController = TextEditingController(text: widget.userData['program']);
    _enrollmentYearController = TextEditingController(text: widget.userData['enrollment_year']?.toString());
    _emergencyNameController = TextEditingController(text: widget.userData['emergency_contact_name']);
    _emergencyPhoneController = TextEditingController(text: widget.userData['emergency_contact_phone']);
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedDepartmentId = widget.userData['department_id'];
    _selectedGender = widget.userData['gender'];
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final depts = await _apiService.getDepartments();
      if (mounted) {
        setState(() {
          _departments = depts;
          _isLoadingDepts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load departments')),
        );
        setState(() => _isLoadingDepts = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _programController.dispose();
    _enrollmentYearController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updateData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'department_id': _selectedDepartmentId,
        'phone_number': _phoneController.text.trim(),
        'program': _programController.text.trim(),
        'enrollment_year': int.tryParse(_enrollmentYearController.text.trim()),
        'emergency_contact_name': _emergencyNameController.text.trim(),
        'emergency_contact_phone': _emergencyPhoneController.text.trim(),
        'gender': _selectedGender,
      };

      if (_newPasswordController.text.isNotEmpty) {
        if (_currentPasswordController.text.isEmpty) {
          throw 'Current password is required to change password';
        }
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw 'New passwords do not match';
        }
        updateData['current_password'] = _currentPasswordController.text;
        updateData['new_password'] = _newPasswordController.text;
      }

      await _apiService.updateProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Background soft glow
          if (isDark)
            Positioned(
              top: -150,
              left: -150,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withOpacity(0.05),
                ),
              ),
            ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, theme, isDark),
                Expanded(
                  child: _isLoadingDepts
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _SlideFadeIn(
                                  delay: 100,
                                  child: _buildBentoSection(
                                    title: 'PERSONAL INFO',
                                    isDark: isDark,
                                    children: [
                                      _buildTextField(
                                        label: 'Full Name',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _nameController,
                                        hintText: 'Your Name',
                                        icon: Icons.person_rounded,
                                        validator: (v) => v!.isEmpty ? 'Name is required' : null,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'Email Address',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _emailController,
                                        hintText: 'email@example.com',
                                        icon: Icons.alternate_email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (v) => v!.isEmpty ? 'Email is required' : null,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'Phone Number',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _phoneController,
                                        hintText: '+1 234 567 8900',
                                        icon: Icons.phone_rounded,
                                        keyboardType: TextInputType.phone,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildGenderDropdown(theme, isDark),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _SlideFadeIn(
                                  delay: 200,
                                  child: _buildBentoSection(
                                    title: 'ACADEMIC DETAILS',
                                    isDark: isDark,
                                    children: [
                                      _buildDepartmentDropdown(theme, isDark),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'Program / Major',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _programController,
                                        hintText: 'e.g. Computer Science',
                                        icon: Icons.school_rounded,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'Enrollment Year',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _enrollmentYearController,
                                        hintText: 'e.g. 2026',
                                        icon: Icons.calendar_today_rounded,
                                        keyboardType: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _SlideFadeIn(
                                  delay: 300,
                                  child: _buildBentoSection(
                                    title: 'EMERGENCY CONTACT',
                                    isDark: isDark,
                                    children: [
                                      _buildTextField(
                                        label: 'Contact Name',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _emergencyNameController,
                                        hintText: 'Parent / Guardian',
                                        icon: Icons.health_and_safety_rounded,
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'Contact Phone',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _emergencyPhoneController,
                                        hintText: '+1 999 999 9999',
                                        icon: Icons.contact_phone_rounded,
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _SlideFadeIn(
                                  delay: 400,
                                  child: _buildBentoSection(
                                    title: 'SECURITY UPDATES',
                                    isDark: isDark,
                                    children: [
                                      _buildTextField(
                                        label: 'Current Password',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _currentPasswordController,
                                        hintText: 'Enter current password',
                                        icon: Icons.lock_rounded,
                                        isPassword: true,
                                        obscureText: _obscureCurrent,
                                        toggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'New Password',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _newPasswordController,
                                        hintText: 'Enter new password',
                                        icon: Icons.password_rounded,
                                        isPassword: true,
                                        obscureText: _obscureNew,
                                        toggleObscure: () => setState(() => _obscureNew = !_obscureNew),
                                      ),
                                      const SizedBox(height: 20),
                                      _buildTextField(
                                        label: 'Confirm New Password',
                                        theme: theme,
                                        isDark: isDark,
                                        controller: _confirmPasswordController,
                                        hintText: 'Re-enter new password',
                                        icon: Icons.verified_user_rounded,
                                        isPassword: true,
                                        obscureText: _obscureConfirm,
                                        toggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 48),
                                _SlideFadeIn(
                                  delay: 500,
                                  child: _buildSaveButton(theme),
                                ),
                                const SizedBox(height: 60),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildGlassIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => Navigator.pop(context),
            isDark: isDark,
          ),
          const SizedBox(width: 16),
          Text(
            'Edit Profile',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, size: 18),
            color: isDark ? Colors.white : ClassTrackTheme.primaryBlue,
          ),
        ),
      ),
    );
  }

  Widget _buildBentoSection({
    required String title,
    required List<Widget> children,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 12),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.03) : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                ),
              ),
              child: Column(children: children),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required ThemeData theme,
    required bool isDark,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? toggleObscure,
  }) {
    final indigo = const Color(0xFF6366F1);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            obscureText: obscureText,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: isDark ? Colors.white24 : Colors.black26,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(icon, color: isDark ? indigo.withOpacity(0.5) : indigo, size: 20),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: Colors.black26,
                        size: 20,
                      ),
                      onPressed: toggleObscure,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDepartmentDropdown(ThemeData theme, bool isDark) {
    final indigo = const Color(0xFF6366F1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Department',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedDepartmentId,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              hint: const Text('Select Department', style: TextStyle(color: Colors.black26)),
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded, color: Colors.black26),
              items: _departments.map((dept) {
                return DropdownMenuItem<int>(
                  value: dept['id'],
                  child: Text(dept['name'], style: const TextStyle(fontWeight: FontWeight.w700)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedDepartmentId = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender',
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 12,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
              hint: const Text('Select Gender', style: TextStyle(color: Colors.black26)),
              isExpanded: true,
              icon: const Icon(Icons.expand_more_rounded, color: Colors.black26),
              items: ['Male', 'Female', 'Other', 'Prefer Not to Say'].map((gender) {
                return DropdownMenuItem<String>(
                  value: gender,
                  child: Text(gender, style: const TextStyle(fontWeight: FontWeight.w700)),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedGender = val),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text(
                  'Update Profile',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
        ),
      ),
    );
  }
}

class _SlideFadeIn extends StatelessWidget {
  final Widget child;
  final int delay;

  const _SlideFadeIn({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

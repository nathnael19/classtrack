import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:classtrack/widgets/glass_widgets.dart';
import 'package:classtrack/utils/form_validators.dart';
import '../../logic/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
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

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneController = TextEditingController(
      text: widget.userData['phone_number'],
    );
    _programController = TextEditingController(
      text: widget.userData['program'],
    );
    _enrollmentYearController = TextEditingController(
      text: widget.userData['enrollment_year']?.toString(),
    );
    _emergencyNameController = TextEditingController(
      text: widget.userData['emergency_contact_name'],
    );
    _emergencyPhoneController = TextEditingController(
      text: widget.userData['emergency_contact_phone'],
    );
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _selectedDepartmentId = widget.userData['department_id'];
    _selectedGender = widget.userData['gender'];
    _fetchDepartments();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() => _imageFile = File(image.path));
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _isSaving = true);
    HapticFeedback.mediumImpact();

    try {
      // 1. Upload Image if changed
      if (_imageFile != null) {
        await _apiService.uploadProfilePicture(_imageFile!);
      }

      // 2. Update other profile data
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
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          const DynamicBackground(),
          LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final dynamicScale = (h / 844.0).clamp(0.85, 1.1);

              return SafeArea(
                child: Column(
                  children: [
                    // Custom App Bar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Text(
                            'Edit Profile',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _isLoadingDepts
                          ? const Center(child: CircularProgressIndicator())
                          : SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24.0,
                              ),
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20 * dynamicScale),
                                    
                                    // Profile Picture Section
                                    _buildAvatarPicker(theme, isDark, dynamicScale),
                                    
                                    SizedBox(height: 32 * dynamicScale),

                                    // Personal Info Section
                                    _buildSectionTitle(
                                      'Personal Information',
                                      isDark,
                                      theme,
                                    ),
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              GlassTextField(
                                                controller: _nameController,
                                                hintText: 'Full Name',
                                                prefixIcon: Icons
                                                    .person_outline_rounded,
                                                scale: dynamicScale,
                                                validator: (v) =>
                                                    FormValidators.validateRequired(
                                                      v,
                                                      'Full Name',
                                                    ),
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller: _emailController,
                                                hintText: 'Email Address',
                                                prefixIcon:
                                                    Icons.email_outlined,
                                                scale: dynamicScale,
                                                validator: FormValidators
                                                    .validateEmail,
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller: _phoneController,
                                                hintText: 'Phone Number',
                                                prefixIcon:
                                                    Icons.phone_outlined,
                                                scale: dynamicScale,
                                                keyboardType:
                                                    TextInputType.phone,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassDropdown<String>(
                                                value: _selectedGender,
                                                hintText: 'Select Gender',
                                                prefixIcon: Icons
                                                    .person_search_outlined,
                                                items:
                                                    [
                                                      'Male',
                                                      'Female',
                                                      'Other',
                                                      'Prefer Not to Say',
                                                    ].map((g) {
                                                      return DropdownMenuItem<
                                                        String
                                                      >(
                                                        value: g,
                                                        child: Text(g),
                                                      );
                                                    }).toList(),
                                                onChanged: (val) => setState(
                                                  () => _selectedGender = val,
                                                ),
                                                scale: dynamicScale,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Academic Details
                                    _buildSectionTitle(
                                      'Academic Details',
                                      isDark,
                                      theme,
                                    ),
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              GlassDropdown<int>(
                                                value: _selectedDepartmentId,
                                                hintText: 'Select Department',
                                                prefixIcon: Icons
                                                    .account_balance_outlined,
                                                items: _departments.map((dept) {
                                                  return DropdownMenuItem<int>(
                                                    value: dept['id'],
                                                    child: Text(dept['name']),
                                                  );
                                                }).toList(),
                                                onChanged: (val) => setState(
                                                  () => _selectedDepartmentId =
                                                      val,
                                                ),
                                                scale: dynamicScale,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller: _programController,
                                                hintText: 'Program / Major',
                                                prefixIcon:
                                                    Icons.school_outlined,
                                                scale: dynamicScale,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller:
                                                    _enrollmentYearController,
                                                hintText: 'Enrollment Year',
                                                prefixIcon: Icons
                                                    .calendar_today_outlined,
                                                scale: dynamicScale,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Emergency Contact
                                    _buildSectionTitle(
                                      'Emergency Contact',
                                      isDark,
                                      theme,
                                    ),
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              GlassTextField(
                                                controller:
                                                    _emergencyNameController,
                                                hintText: 'Contact Name',
                                                prefixIcon: Icons
                                                    .health_and_safety_outlined,
                                                scale: dynamicScale,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller:
                                                    _emergencyPhoneController,
                                                hintText: 'Contact Phone',
                                                prefixIcon: Icons
                                                    .contact_phone_outlined,
                                                scale: dynamicScale,
                                                keyboardType:
                                                    TextInputType.phone,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Security Updates
                                    _buildSectionTitle(
                                      'Security Updates',
                                      isDark,
                                      theme,
                                    ),
                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: SlideTransition(
                                        position: _slideAnimation,
                                        child: GlassCard(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              GlassTextField(
                                                controller:
                                                    _currentPasswordController,
                                                hintText: 'Current Password',
                                                prefixIcon:
                                                    Icons.lock_outline_rounded,
                                                obscureText: _obscureCurrent,
                                                suffixIcon: _obscureCurrent
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                onSuffixIconPressed: () =>
                                                    setState(
                                                      () => _obscureCurrent =
                                                          !_obscureCurrent,
                                                    ),
                                                scale: dynamicScale,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller:
                                                    _newPasswordController,
                                                hintText:
                                                    'New Password (Optional)',
                                                prefixIcon:
                                                    Icons.password_outlined,
                                                obscureText: _obscureNew,
                                                suffixIcon: _obscureNew
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                onSuffixIconPressed: () =>
                                                    setState(
                                                      () => _obscureNew =
                                                          !_obscureNew,
                                                    ),
                                                scale: dynamicScale,
                                              ),
                                              const SizedBox(height: 16),
                                              GlassTextField(
                                                controller:
                                                    _confirmPasswordController,
                                                hintText:
                                                    'Confirm New Password',
                                                prefixIcon: Icons
                                                    .verified_user_outlined,
                                                obscureText: _obscureConfirm,
                                                suffixIcon: _obscureConfirm
                                                    ? Icons
                                                          .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                onSuffixIconPressed: () =>
                                                    setState(
                                                      () => _obscureConfirm =
                                                          !_obscureConfirm,
                                                    ),
                                                scale: dynamicScale,
                                                validator: (v) {
                                                  if (_newPasswordController
                                                          .text
                                                          .isNotEmpty &&
                                                      v !=
                                                          _newPasswordController
                                                              .text) {
                                                    return 'Passwords do not match';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: 48 * dynamicScale),

                                    FadeTransition(
                                      opacity: _fadeAnimation,
                                      child: GlassButton(
                                        onPressed: _handleSave,
                                        label: 'Update Profile',
                                        isLoading: _isSaving,
                                        scale: dynamicScale,
                                        width: double.infinity,
                                      ),
                                    ),
                                    const SizedBox(height: 60),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(ThemeData theme, bool isDark, double scale) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120 * scale,
              height: 120 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6366F1).withOpacity(0.2),
                    const Color(0xFFA855F7).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _imageFile != null
                    ? Image.file(_imageFile!, fit: BoxFit.cover)
                    : widget.userData['profile_picture_url'] != null
                        ? Image.network(
                            '${_apiService.dio.options.baseUrl}${widget.userData['profile_picture_url']}',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                          )
                        : _buildPlaceholderIcon(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.scaffoldBackgroundColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Icon(
      Icons.person_outline_rounded,
      size: 48,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white38 : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }
}

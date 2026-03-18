import 'package:classtrack/theme/design_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final ApiService _apiService = ApiService();

  List<dynamic> _departments = [];
  int? _selectedDepartmentId;
  bool _isLoadingDepts = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _selectedDepartmentId = widget.userData['department_id'];
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    try {
      final depts = await _apiService.getDepartments();
      setState(() {
        _departments = depts;
        _isLoadingDepts = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load departments')),
        );
      }
      setState(() => _isLoadingDepts = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updateData = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'department_id': _selectedDepartmentId,
      };

      await _apiService.updateProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate refresh needed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Edit Profile',
          style: GoogleFonts.lexend(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoadingDepts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Full Name'),
                    _buildTextField(
                      controller: _nameController,
                      hintText: 'Your Name',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Email Address'),
                    _buildTextField(
                      controller: _emailController,
                      hintText: 'email@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? 'Email is required' : null,
                    ),
                    const SizedBox(height: 20),
                    _buildLabel('Department'),
                    _buildDepartmentDropdown(),
                    const SizedBox(height: 40),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.lexend(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.lexend(fontSize: 15),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.lexend(
            color: const Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDepartmentId,
          hint: Text(
            'Select Department',
            style: GoogleFonts.lexend(
              color: const Color(0xFF94A3B8),
              fontSize: 14,
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B)),
          items: _departments.map((dept) {
            return DropdownMenuItem<int>(
              value: dept['id'],
              child: Text(
                dept['name'],
                style: GoogleFonts.lexend(fontSize: 15),
              ),
            );
          }).toList(),
          onChanged: (val) {
            setState(() => _selectedDepartmentId = val);
          },
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: ClassTrackTheme.primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isSaving
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Save Changes',
                style: GoogleFonts.lexend(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

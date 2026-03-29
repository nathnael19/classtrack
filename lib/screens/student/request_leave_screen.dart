import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:classtrack/widgets/glass_widgets.dart';
import 'package:classtrack/utils/form_validators.dart';
import '../../logic/api_service.dart';

class RequestLeaveScreen extends StatefulWidget {
  final Map<String, dynamic> session;

  const RequestLeaveScreen({super.key, required this.session});

  @override
  State<RequestLeaveScreen> createState() => _RequestLeaveScreenState();
}

class _RequestLeaveScreenState extends State<RequestLeaveScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _documentController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isSubmitting = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _documentController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }
    
    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      await _api.createLeaveRequest(
        sessionId: widget.session['id'] as int,
        reason: _reasonController.text.trim(),
        documentUrl: _documentController.text.trim().isNotEmpty
            ? _documentController.text.trim()
            : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Leave request submitted successfully'),
          backgroundColor: Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final session = widget.session;
    final courseName = session['course_name'] ?? session['topic'] ?? 'Class Session';
    final room = session['room'] ?? 'N/A';
    final section = session['section'];

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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            color: isDark ? Colors.white : const Color(0xFF0F172A),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Spacer(),
                          Text(
                            'Request Leave',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const Spacer(),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16 * dynamicScale),
                              
                              // Session Info Card
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          courseName,
                                          style: theme.textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 20 * dynamicScale,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: isDark ? Colors.white60 : Colors.black45,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              room,
                                              style: theme.textTheme.bodyMedium?.copyWith(
                                                color: isDark ? Colors.white60 : Colors.black45,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (section != null) ...[
                                              const SizedBox(width: 12),
                                              Icon(
                                                Icons.groups_outlined,
                                                size: 16,
                                                color: isDark ? Colors.white60 : Colors.black45,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Section $section',
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: isDark ? Colors.white60 : Colors.black45,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              _buildSectionTitle('Leave Details', isDark, theme),
                              
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: GlassCard(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        GlassTextField(
                                          controller: _reasonController,
                                          hintText: 'Explain why you need to miss this class...',
                                          prefixIcon: Icons.description_outlined,
                                          validator: (v) => FormValidators.validateRequired(v, 'Reason'),
                                          scale: dynamicScale,
                                        ),
                                        const SizedBox(height: 20),
                                        GlassTextField(
                                          controller: _documentController,
                                          hintText: 'Document URL (Optional)',
                                          prefixIcon: Icons.link_rounded,
                                          keyboardType: TextInputType.url,
                                          scale: dynamicScale,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 48),
                              
                              FadeTransition(
                                opacity: _fadeAnimation,
                                child: GlassButton(
                                  onPressed: _submit,
                                  label: 'Submit Request',
                                  isLoading: _isSubmitting,
                                  scale: dynamicScale,
                                  width: double.infinity,
                                ),
                              ),
                              const SizedBox(height: 48),
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

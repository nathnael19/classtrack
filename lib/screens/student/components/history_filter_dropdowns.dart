import 'package:flutter/material.dart';
import '../../../theme/design_theme.dart';

class HistoryFilterDropdowns extends StatelessWidget {
  final String selectedCourse;
  final String selectedPeriod;
  final List<String> courses;
  final List<String> periods;
  final ValueChanged<String?> onCourseChanged;
  final ValueChanged<String?> onPeriodChanged;

  const HistoryFilterDropdowns({
    super.key,
    required this.selectedCourse,
    required this.selectedPeriod,
    required this.courses,
    required this.periods,
    required this.onCourseChanged,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COURSE',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                context: context,
                value: selectedCourse,
                items: courses,
                onChanged: onCourseChanged,
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PERIOD',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              _buildDropdown(
                context: context,
                value: selectedPeriod,
                items: periods,
                onChanged: onPeriodChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: ClassTrackTheme.primaryBlue,
          ),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

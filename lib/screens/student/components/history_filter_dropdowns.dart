import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../widgets/glass_widgets.dart';

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
    return Row(
      children: [
        Expanded(
          child: GlassDropdown<String>(
            value: selectedCourse,
            items: courses.map((course) {
              return DropdownMenuItem(
                value: course,
                child: Text(
                  course,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: onCourseChanged,
            hintText: 'Course',
            prefixIcon: Icons.school_rounded,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassDropdown<String>(
            value: selectedPeriod,
            items: periods.map((period) {
              return DropdownMenuItem(
                value: period,
                child: Text(
                  period,
                  style: GoogleFonts.firaCode(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            onChanged: onPeriodChanged,
            hintText: 'Period',
            prefixIcon: Icons.calendar_today_rounded,
          ),
        ),
      ],
    );
  }
}

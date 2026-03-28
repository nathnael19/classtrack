import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/attendance/attendance_cubit.dart';
import 'package:classtrack/screens/student/course_materials_screen.dart';
import 'package:classtrack/theme/design_theme.dart';

class MyCoursesScreen extends StatelessWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Courses',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          final courses = state.enrolledCourses;

          if (courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No enrolled courses found',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              final courseId = course['id'] as int;
              final courseName = course['name'] ?? course['course_name'] ?? 'Course';
              final courseCode = course['code'] ?? course['course_code'] ?? '';

              final colors = [
                ClassTrackTheme.primaryBlue,
                const Color(0xFF8B5CF6),
                const Color(0xFF059669),
                const Color(0xFFD97706),
                const Color(0xFFDC2626),
              ];
              final color = colors[index % colors.length];

              return _buildCourseCard(
                context,
                theme,
                isDark,
                courseId,
                courseName,
                courseCode,
                color,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    int courseId,
    String name,
    String code,
    Color color,
  ) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CourseMaterialsScreen(
            courseId: courseId,
            courseName: name,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.book_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

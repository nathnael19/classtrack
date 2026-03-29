import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/attendance/attendance_cubit.dart';
import 'package:classtrack/screens/student/course_materials_screen.dart';
import 'package:classtrack/theme/design_theme.dart';

class MyCoursesScreen extends StatefulWidget {
  const MyCoursesScreen({super.key});

  @override
  State<MyCoursesScreen> createState() => _MyCoursesScreenState();
}

class _MyCoursesScreenState extends State<MyCoursesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Text(
          'My Courses',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<AttendanceCubit, AttendanceState>(
        builder: (context, state) {
          final allCourses = state.enrolledCourses;
          final courses = allCourses.where((c) {
            final name = (c['name'] ?? c['course_name'] ?? '')
                .toString()
                .toLowerCase();
            final code = (c['code'] ?? c['course_code'] ?? '')
                .toString()
                .toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) ||
                code.contains(_searchQuery.toLowerCase());
          }).toList();

          if (allCourses.isEmpty) {
            return _buildEmptyState(theme, isDark, 'No enrolled courses found');
          }

          return Column(
            children: [
              _buildSearchBar(theme, isDark),
              Expanded(
                child: courses.isEmpty
                    ? _buildEmptyState(
                        theme,
                        isDark,
                        'No courses match your search',
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.15,
                            ),
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          final course = courses[index];
                          final courseId = course['id'] as int;
                          final courseName =
                              course['name'] ??
                              course['course_name'] ??
                              'Course';
                          final courseCode =
                              course['code'] ?? course['course_code'] ?? '';

                          final colors = [
                            ClassTrackTheme.primaryBlue,
                            const Color(0xFF8B5CF6),
                            const Color(0xFF0D9488),
                            const Color(0xFFD97706),
                            const Color(0xFFE11D48),
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
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search your courses...',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isDark, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.02),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isEmpty
                  ? Icons.school_outlined
                  : Icons.search_off_rounded,
              size: 48,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
          builder: (_) =>
              CourseMaterialsScreen(courseId: courseId, courseName: name),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Liquid Effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
              ),
            ),

            // Subtle Pattern Overlay
            Positioned(
              right: -10,
              top: -10,
              child: Icon(
                Icons.book_rounded,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.folder_shared_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        code,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

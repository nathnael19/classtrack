import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/cubits/materials/course_materials_cubit.dart';
import 'package:classtrack/theme/design_theme.dart';
import 'package:intl/intl.dart';

class CourseMaterialsScreen extends StatelessWidget {
  final int courseId;
  final String courseName;

  const CourseMaterialsScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CourseMaterialsCubit(courseId: courseId)..fetchMaterials(),
      child: Scaffold(
        body: const _CourseMaterialsView(),
        appBar: AppBar(
          title: Text(
            courseName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}

class _CourseMaterialsView extends StatelessWidget {
  const _CourseMaterialsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocBuilder<CourseMaterialsCubit, CourseMaterialsState>(
      builder: (context, state) {
        if (state.status == CourseMaterialsStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == CourseMaterialsStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load materials',
                    style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () =>
                      context.read<CourseMaterialsCubit>().fetchMaterials(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.materials.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open_rounded,
                    size: 64, color: isDark ? Colors.white24 : Colors.black12),
                const SizedBox(height: 16),
                Text(
                  'No materials shared yet',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          );
        }

        // Group materials by folder
        final grouped = <String, List<dynamic>>{};
        for (var m in state.materials) {
          final folder = m['folder_name'] ?? 'General';
          grouped.putIfAbsent(folder, () => []).add(m);
        }

        final folders = grouped.keys.toList()..sort();

        return RefreshIndicator(
          onRefresh: () => context.read<CourseMaterialsCubit>().fetchMaterials(),
          child: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: folders.length,
            itemBuilder: (context, index) {
              final folder = folders[index];
              final folderMaterials = grouped[folder]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, top: 8),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: ClassTrackTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            folder.toUpperCase(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: ClassTrackTheme.primaryBlue,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Divider(color: theme.dividerColor)),
                      ],
                    ),
                  ),
                  ...folderMaterials.map((m) => _MaterialItem(material: m)),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _MaterialItem extends StatelessWidget {
  final Map<String, dynamic> material;

  const _MaterialItem({required this.material});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final materialId = material['id'] as int;

    return BlocBuilder<CourseMaterialsCubit, CourseMaterialsState>(
      builder: (context, state) {
        final progress = state.downloadProgress[materialId];
        final isDownloaded = state.isDownloaded[materialId] ?? false;
        final isDownloading = progress != null;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.read<CourseMaterialsCubit>().openMaterial(material),
              borderRadius: BorderRadius.circular(24),
              child: Ink(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                  ),
                ),
                child: Row(
                  children: [
                    _FileIcon(type: material['file_type'] ?? ''),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            material['title'] ?? 'Unnamed Material',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                _formatFileSize(material['file_size'] ?? 0),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.circle, size: 3, color: theme.textTheme.bodySmall?.color?.withOpacity(0.3)),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('MMM d, yyyy').format(DateTime.parse(material['created_at'])),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (isDownloading) ...[
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                                color: ClassTrackTheme.primaryBlue,
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _ActionButton(
                      isDownloaded: isDownloaded,
                      isDownloading: isDownloading,
                      onPressed: () => context.read<CourseMaterialsCubit>().downloadMaterial(material),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    var result = bytes / (1 << (i * 10));
    return "${result.toStringAsFixed(1)} ${suffixes[i]}";
  }
}

class _FileIcon extends StatelessWidget {
  final String type;

  const _FileIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color = Colors.blue;
    IconData icon = Icons.insert_drive_file_rounded;

    if (type.contains('pdf')) {
      color = Colors.red;
      icon = Icons.picture_as_pdf_rounded;
    } else if (type.contains('image')) {
      color = Colors.orange;
      icon = Icons.image_rounded;
    } else if (type.contains('video')) {
      color = Colors.purple;
      icon = Icons.video_collection_rounded;
    } else if (type.contains('word') || type.contains('text')) {
      color = Colors.blue;
      icon = Icons.description_rounded;
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final bool isDownloaded;
  final bool isDownloading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.isDownloaded,
    required this.isDownloading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (isDownloading) {
      return Container(
        width: 40,
        height: 40,
        padding: const EdgeInsets.all(10),
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(ClassTrackTheme.primaryBlue),
        ),
      );
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isDownloaded ? Icons.open_in_new_rounded : Icons.file_download_outlined,
        color: isDownloaded
            ? ClassTrackTheme.accentEmerald
            : (isDark ? Colors.white70 : Colors.black54),
      ),
      style: IconButton.styleFrom(
        backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

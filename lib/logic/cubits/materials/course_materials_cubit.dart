import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:classtrack/logic/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

enum CourseMaterialsStatus { initial, loading, success, failure }

class CourseMaterialsState {
  final CourseMaterialsStatus status;
  final List<dynamic> materials;
  final Map<int, double> downloadProgress; // materialId -> 0.0 to 1.0
  final Map<int, bool> isDownloaded; // materialId -> true/false
  final String? error;

  CourseMaterialsState({
    required this.status,
    this.materials = const [],
    this.downloadProgress = const {},
    this.isDownloaded = const {},
    this.error,
  });

  factory CourseMaterialsState.initial() =>
      CourseMaterialsState(status: CourseMaterialsStatus.initial);

  CourseMaterialsState copyWith({
    CourseMaterialsStatus? status,
    List<dynamic>? materials,
    Map<int, double>? downloadProgress,
    Map<int, bool>? isDownloaded,
    String? error,
  }) {
    return CourseMaterialsState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      error: error,
    );
  }
}

class CourseMaterialsCubit extends Cubit<CourseMaterialsState> {
  final ApiService api = ApiService();
  final int courseId;

  CourseMaterialsCubit({required this.courseId})
    : super(CourseMaterialsState.initial());

  Future<void> fetchMaterials() async {
    emit(state.copyWith(status: CourseMaterialsStatus.loading));
    try {
      final materials = await api.getCourseMaterials(courseId);

      final Map<int, bool> downloadedStatus = {};
      
      if (!kIsWeb) {
        final directory = await getApplicationDocumentsDirectory();
        print('CourseMaterialsCubit: Successfully fetched ${materials.length} materials for course $courseId');

        for (var material in materials) {
          try {
            final materialId = material['id'] as int;
            final fileName =
                material['original_filename'] ?? 'material_$materialId';
            final filePath = '${directory.path}/$fileName';
            downloadedStatus[materialId] = await File(filePath).exists();
          } catch (itemError) {
            debugPrint('Error processing material item $material: $itemError');
          }
        }
      }

      emit(
        state.copyWith(
          status: CourseMaterialsStatus.success,
          materials: materials,
          isDownloaded: downloadedStatus,
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('CourseMaterialsCubit.fetchMaterials Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      emit(
        state.copyWith(
          status: CourseMaterialsStatus.failure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> downloadMaterial(Map<String, dynamic> material) async {
    final materialId = material['id'] as int;
    final fileName = material['original_filename'] ?? 'material_$materialId';

    try {
      if (kIsWeb) {
        final url = api.getMaterialUrl(materialId);
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';

      if (await File(filePath).exists()) {
        await OpenFilex.open(filePath);
        return;
      }

      await api.downloadMaterial(
        materialId,
        filePath,
        onProgress: (count, total) {
          if (total > 0) {
            final progress = count / total;
            final updatedProgress = Map<int, double>.from(
              state.downloadProgress,
            );
            updatedProgress[materialId] = progress;
            emit(state.copyWith(downloadProgress: updatedProgress));
          }
        },
      );

      final updatedDownloaded = Map<int, bool>.from(state.isDownloaded);
      updatedDownloaded[materialId] = true;

      final updatedProgress = Map<int, double>.from(state.downloadProgress);
      updatedProgress.remove(materialId);

      emit(
        state.copyWith(
          isDownloaded: updatedDownloaded,
          downloadProgress: updatedProgress,
        ),
      );

      await OpenFilex.open(filePath);
    } catch (e) {
      emit(state.copyWith(error: 'Download failed: $e'));
    }
  }

  Future<void> openMaterial(Map<String, dynamic> material) async {
    if (kIsWeb) {
      downloadMaterial(material);
      return;
    }
    
    final materialId = material['id'] as int;
    final fileName = material['original_filename'] ?? 'material_$materialId';
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';

    if (await File(filePath).exists()) {
      await OpenFilex.open(filePath);
    } else {
      downloadMaterial(material);
    }
  }
}

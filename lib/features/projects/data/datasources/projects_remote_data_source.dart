import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/project_member_model.dart';
import '../models/project_model.dart';

class ProjectsRemoteDataSource {
  ProjectsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ProjectModel>> getProjects() async {
    try {
      final response = await _client.client.get('/projects');
      final items = (response.data as List<dynamic>? ?? [])
          .map((item) => ProjectModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return items;
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to fetch projects');
    }
  }

  Future<List<ProjectMemberModel>> getMembers(String projectId) async {
    try {
      final response = await _client.client.get('/projects/$projectId/members');
      final items = (response.data as List<dynamic>? ?? [])
          .map((item) => ProjectMemberModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return items;
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to fetch project members');
    }
  }

  Future<void> addMember(String projectId, {required String employeeId, String? role}) async {
    try {
      await _client.client.post(
        '/projects/$projectId/members',
        data: {
          'employeeId': employeeId,
          if (role != null && role.isNotEmpty) 'role': role,
        },
      );
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to add project member');
    }
  }

  Future<ProjectModel> createProject({
    required String code,
    required String name,
    String? description,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await _client.client.post(
        '/projects',
        data: {
          'code': code,
          'name': name,
          if (description != null && description.isNotEmpty) 'description': description,
          if (status != null && status.isNotEmpty) 'status': status,
          if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
          if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
        },
      );
      return ProjectModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to create project');
    }
  }

  AppException _mapException(DioException e, {required String message}) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return AppException(message, code: e.response?.statusCode);
  }
}

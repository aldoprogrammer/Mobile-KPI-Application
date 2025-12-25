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

  Future<void> addMember(String projectId, {required String email, required String role}) async {
    try {
      await _client.client.post(
        '/projects/$projectId/members',
        data: {
          'email': email,
          'role': role,
        },
      );
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to add project member');
    }
  }

  AppException _mapException(DioException e, {required String message}) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return AppException(message, code: e.response?.statusCode);
  }
}
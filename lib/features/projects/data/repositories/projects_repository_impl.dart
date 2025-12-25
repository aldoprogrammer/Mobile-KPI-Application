import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/entities/project_member.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_remote_data_source.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl(this._remote);

  final ProjectsRemoteDataSource _remote;

  @override
  Future<Project> createProject({
    required String code,
    required String name,
    String? description,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    try {
      return await _remote.createProject(
        code: code,
        name: name,
        description: description,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<void> addMember(String projectId, {required String employeeId, String? role}) async {
    try {
      await _remote.addMember(projectId, employeeId: employeeId, role: role);
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<ProjectMember>> getMembers(String projectId) async {
    try {
      return await _remote.getMembers(projectId);
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<Project>> getProjects() async {
    try {
      return await _remote.getProjects();
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  Failure _mapFailure(AppException exception) {
    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    return UnknownFailure(exception.message);
  }
}

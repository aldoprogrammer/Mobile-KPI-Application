import '../entities/project.dart';
import '../entities/project_member.dart';

abstract class ProjectsRepository {
  Future<List<Project>> getProjects();
  Future<List<ProjectMember>> getMembers(String projectId);
  Future<void> addMember(String projectId, {required String employeeId, String? role});
  Future<Project> createProject({
    required String code,
    required String name,
    String? description,
    String? status,
    String? startDate,
    String? endDate,
  });
}

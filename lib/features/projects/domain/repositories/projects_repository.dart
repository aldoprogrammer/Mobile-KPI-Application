import '../entities/project.dart';
import '../entities/project_member.dart';

abstract class ProjectsRepository {
  Future<List<Project>> getProjects();
  Future<List<ProjectMember>> getMembers(String projectId);
  Future<void> addMember(String projectId, {required String email, required String role});
}
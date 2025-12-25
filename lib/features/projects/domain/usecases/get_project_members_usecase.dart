import '../entities/project_member.dart';
import '../repositories/projects_repository.dart';

class GetProjectMembersUseCase {
  const GetProjectMembersUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<ProjectMember>> call(String projectId) {
    return _repository.getMembers(projectId);
  }
}
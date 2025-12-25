import '../repositories/projects_repository.dart';

class AddProjectMemberUseCase {
  const AddProjectMemberUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<void> call(String projectId, {required String email, required String role}) {
    return _repository.addMember(projectId, email: email, role: role);
  }
}
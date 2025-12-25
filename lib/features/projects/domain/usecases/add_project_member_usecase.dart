import '../repositories/projects_repository.dart';

class AddProjectMemberUseCase {
  const AddProjectMemberUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<void> call(String projectId, {required String employeeId, String? role}) {
    return _repository.addMember(projectId, employeeId: employeeId, role: role);
  }
}

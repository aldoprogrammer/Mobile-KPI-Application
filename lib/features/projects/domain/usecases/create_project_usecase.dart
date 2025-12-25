import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class CreateProjectUseCase {
  const CreateProjectUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<Project> call({
    required String code,
    required String name,
    String? description,
    String? status,
    String? startDate,
    String? endDate,
  }) {
    return _repository.createProject(
      code: code,
      name: name,
      description: description,
      status: status,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

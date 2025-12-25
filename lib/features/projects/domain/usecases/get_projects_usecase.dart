import '../entities/project.dart';
import '../repositories/projects_repository.dart';

class GetProjectsUseCase {
  const GetProjectsUseCase(this._repository);

  final ProjectsRepository _repository;

  Future<List<Project>> call() {
    return _repository.getProjects();
  }
}
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/create_project_usecase.dart';
import '../../domain/usecases/get_projects_usecase.dart';

class ProjectsProvider extends ChangeNotifier {
  ProjectsProvider(this._getProjects, this._createProject);

  final GetProjectsUseCase _getProjects;
  final CreateProjectUseCase _createProject;

  List<Project> _projects = [];
  bool _loading = false;
  String? _error;

  List<Project> get projects => _projects;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _projects = await _getProjects();
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load projects';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> createProject({
    required String code,
    required String name,
    String? description,
    String? status,
    String? startDate,
    String? endDate,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final project = await _createProject(
        code: code,
        name: name,
        description: description,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      _projects = [project, ..._projects];
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to create project';
      notifyListeners();
      return false;
    }
  }
}

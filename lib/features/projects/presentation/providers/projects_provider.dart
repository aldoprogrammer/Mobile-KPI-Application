import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project.dart';
import '../../domain/usecases/get_projects_usecase.dart';

class ProjectsProvider extends ChangeNotifier {
  ProjectsProvider(this._getProjects);

  final GetProjectsUseCase _getProjects;

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
}
import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/project_member.dart';
import '../../domain/usecases/add_project_member_usecase.dart';
import '../../domain/usecases/get_project_members_usecase.dart';

class ProjectMembersProvider extends ChangeNotifier {
  ProjectMembersProvider({
    required GetProjectMembersUseCase getMembers,
    required AddProjectMemberUseCase addMember,
    required this.projectId,
  })  : _getMembers = getMembers,
        _addMember = addMember;

  final GetProjectMembersUseCase _getMembers;
  final AddProjectMemberUseCase _addMember;
  final String projectId;

  List<ProjectMember> _members = [];
  bool _loading = false;
  String? _error;

  List<ProjectMember> get members => _members;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _members = await _getMembers(projectId);
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load members';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> addMember({required String email, required String role}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      await _addMember(projectId, email: email, role: role);
      await load();
      return true;
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to add member';
      _loading = false;
      notifyListeners();
      return false;
    }
  }
}
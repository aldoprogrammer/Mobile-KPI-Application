import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/employee.dart';
import '../../domain/usecases/get_employees_usecase.dart';

class EmployeesProvider extends ChangeNotifier {
  EmployeesProvider(this._getEmployeesUseCase);

  final GetEmployeesUseCase _getEmployeesUseCase;

  final List<Employee> _employees = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  List<Employee> get employees => List.unmodifiable(_employees);
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadInitial() async {
    _employees.clear();
    _page = 1;
    _hasMore = true;
    await _loadPage();
  }

  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore) return;
    _page += 1;
    await _loadPage();
  }

  Future<void> _loadPage() async {
    final isInitial = _employees.isEmpty;
    if (isInitial) {
      _loading = true;
    } else {
      _loadingMore = true;
    }
    _error = null;
    notifyListeners();

    try {
      final items = await _getEmployeesUseCase(page: _page, pageSize: _pageSize);
      if (items.isEmpty) {
        _hasMore = false;
      } else {
        _employees.addAll(items);
      }
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load employees';
    } finally {
      _loading = false;
      _loadingMore = false;
      notifyListeners();
    }
  }
}

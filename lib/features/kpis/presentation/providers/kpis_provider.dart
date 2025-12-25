import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/kpi.dart';
import '../../domain/usecases/get_active_kpis_usecase.dart';
import '../../domain/usecases/get_kpis_usecase.dart';

class KpisProvider extends ChangeNotifier {
  KpisProvider({required GetKpisUseCase getKpis, required GetActiveKpisUseCase getActiveKpis})
      : _getKpis = getKpis,
        _getActiveKpis = getActiveKpis;

  final GetKpisUseCase _getKpis;
  final GetActiveKpisUseCase _getActiveKpis;

  List<Kpi> _kpis = [];
  bool _loading = false;
  String? _error;
  bool _activeOnly = false;

  List<Kpi> get kpis => _kpis;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get activeOnly => _activeOnly;

  Future<void> load({bool activeOnly = false}) async {
    _loading = true;
    _error = null;
    _activeOnly = activeOnly;
    notifyListeners();

    try {
      _kpis = activeOnly ? await _getActiveKpis() : await _getKpis();
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load KPIs';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
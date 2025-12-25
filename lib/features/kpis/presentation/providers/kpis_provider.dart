import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/kpi.dart';
import '../../domain/usecases/create_kpi_usecase.dart';
import '../../domain/usecases/get_active_kpis_usecase.dart';
import '../../domain/usecases/get_kpis_usecase.dart';

class KpisProvider extends ChangeNotifier {
  KpisProvider({
    required GetKpisUseCase getKpis,
    required GetActiveKpisUseCase getActiveKpis,
    required CreateKpiUseCase createKpi,
  })  : _getKpis = getKpis,
        _getActiveKpis = getActiveKpis,
        _createKpi = createKpi;

  final GetKpisUseCase _getKpis;
  final GetActiveKpisUseCase _getActiveKpis;
  final CreateKpiUseCase _createKpi;

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

  Future<bool> createKpi({
    required String code,
    required String title,
    required int weight,
    String? description,
    bool? active,
  }) async {
    _error = null;
    notifyListeners();

    try {
      final kpi = await _createKpi(
        code: code,
        title: title,
        weight: weight,
        description: description,
        active: active,
      );
      if (!_activeOnly || kpi.active) {
        _kpis = [kpi, ..._kpis];
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to create KPI';
      notifyListeners();
      return false;
    }
  }
}

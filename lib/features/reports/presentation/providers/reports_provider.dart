import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/report_summary.dart';
import '../../domain/usecases/get_report_summaries_usecase.dart';

class ReportsProvider extends ChangeNotifier {
  ReportsProvider(this._getSummaries);

  final GetReportSummariesUseCase _getSummaries;

  final List<ReportSummary> _summaries = [];
  bool _loading = false;
  String? _error;
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String? _employeeId;
  String? _from;
  String? _to;

  List<ReportSummary> get summaries => List.unmodifiable(_summaries);
  bool get isLoading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get employeeId => _employeeId;
  String? get from => _from;
  String? get to => _to;

  Future<void> loadInitial({String? employeeId, String? from, String? to}) async {
    _summaries.clear();
    _page = 1;
    _hasMore = true;
    _employeeId = employeeId;
    _from = from;
    _to = to;
    await _loadPage();
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore) return;
    _page += 1;
    await _loadPage();
  }

  Future<void> _loadPage() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final items = await _getSummaries(
        page: _page,
        pageSize: _pageSize,
        employeeId: _employeeId,
        from: _from,
        to: _to,
      );
      if (items.isEmpty) {
        _hasMore = false;
      } else {
        _summaries.addAll(items);
        if (items.length < _pageSize) {
          _hasMore = false;
        }
      }
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load reports';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}

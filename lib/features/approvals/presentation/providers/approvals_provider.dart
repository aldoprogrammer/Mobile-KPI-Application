import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/approval_action_result.dart';
import '../../domain/entities/approval_detail.dart';
import '../../domain/entities/approval_summary.dart';
import '../../domain/usecases/act_on_approval_usecase.dart';
import '../../domain/usecases/get_approval_usecase.dart';
import '../../domain/usecases/get_approvals_usecase.dart';

class ApprovalsProvider extends ChangeNotifier {
  ApprovalsProvider({
    required GetApprovalUseCase getApproval,
    required GetApprovalsUseCase getApprovals,
    required ActOnApprovalUseCase actOnApproval,
  })  : _getApproval = getApproval,
        _getApprovals = getApprovals,
        _actOnApproval = actOnApproval;

  final GetApprovalUseCase _getApproval;
  final GetApprovalsUseCase _getApprovals;
  final ActOnApprovalUseCase _actOnApproval;

  ApprovalDetail? _detail;
  final List<ApprovalSummary> _summaries = [];
  bool _loading = false;
  String? _error;
  int _page = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  String? _status;

  ApprovalDetail? get detail => _detail;
  List<ApprovalSummary> get summaries => List.unmodifiable(_summaries);
  bool get isLoading => _loading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  String? get status => _status;

  Future<void> load(String approvalId) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _detail = await _getApproval(approvalId);
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to load approval';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadInitial({String? status}) async {
    _summaries.clear();
    _page = 1;
    _hasMore = true;
    _status = status;
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
      final items = await _getApprovals(
        page: _page,
        pageSize: _pageSize,
        status: _status,
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
      _error = e is Failure ? e.message : 'Failed to load approvals';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<ApprovalActionResult?> act({
    required String approvalId,
    required String action,
    String? comment,
  }) async {
    _error = null;
    notifyListeners();

    try {
      return await _actOnApproval(
        approvalId: approvalId,
        action: action,
        comment: comment,
      );
    } catch (e) {
      _error = e is Failure ? e.message : 'Failed to update approval';
      notifyListeners();
      return null;
    }
  }
}

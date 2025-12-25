import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/approval_action_result.dart';
import '../../domain/entities/approval_detail.dart';
import '../../domain/entities/approval_summary.dart';
import '../../domain/repositories/approvals_repository.dart';
import '../datasources/approvals_remote_data_source.dart';

class ApprovalsRepositoryImpl implements ApprovalsRepository {
  ApprovalsRepositoryImpl(this._remote);

  final ApprovalsRemoteDataSource _remote;

  @override
  Future<ApprovalActionResult> actOnApproval({
    required String approvalId,
    required String action,
    String? comment,
  }) async {
    try {
      return await _remote.actOnApproval(
        approvalId: approvalId,
        action: action,
        comment: comment,
      );
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<ApprovalDetail> getApproval(String approvalId) async {
    try {
      return await _remote.getApproval(approvalId);
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<ApprovalSummary>> getApprovals({
    required int page,
    required int pageSize,
    String? status,
  }) async {
    try {
      return await _remote.getApprovals(
        page: page,
        pageSize: pageSize,
        status: status,
      );
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  Failure _mapFailure(AppException exception) {
    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    return UnknownFailure(exception.message);
  }
}

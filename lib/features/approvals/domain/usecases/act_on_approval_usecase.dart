import '../entities/approval_action_result.dart';
import '../repositories/approvals_repository.dart';

class ActOnApprovalUseCase {
  const ActOnApprovalUseCase(this._repository);

  final ApprovalsRepository _repository;

  Future<ApprovalActionResult> call({
    required String approvalId,
    required String action,
    String? comment,
  }) {
    return _repository.actOnApproval(
      approvalId: approvalId,
      action: action,
      comment: comment,
    );
  }
}

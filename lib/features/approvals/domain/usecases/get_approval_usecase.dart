import '../entities/approval_detail.dart';
import '../repositories/approvals_repository.dart';

class GetApprovalUseCase {
  const GetApprovalUseCase(this._repository);

  final ApprovalsRepository _repository;

  Future<ApprovalDetail> call(String approvalId) {
    return _repository.getApproval(approvalId);
  }
}

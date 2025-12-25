import '../entities/approval_summary.dart';
import '../repositories/approvals_repository.dart';

class GetApprovalsUseCase {
  const GetApprovalsUseCase(this._repository);

  final ApprovalsRepository _repository;

  Future<List<ApprovalSummary>> call({
    required int page,
    required int pageSize,
    String? status,
  }) {
    return _repository.getApprovals(
      page: page,
      pageSize: pageSize,
      status: status,
    );
  }
}

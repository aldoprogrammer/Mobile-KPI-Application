import '../entities/approval_action_result.dart';
import '../entities/approval_detail.dart';
import '../entities/approval_summary.dart';

abstract class ApprovalsRepository {
  Future<ApprovalDetail> getApproval(String approvalId);
  Future<List<ApprovalSummary>> getApprovals({
    required int page,
    required int pageSize,
    String? status,
  });
  Future<ApprovalActionResult> actOnApproval({
    required String approvalId,
    required String action,
    String? comment,
  });
}

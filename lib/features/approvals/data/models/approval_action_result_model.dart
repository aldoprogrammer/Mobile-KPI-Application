import '../../domain/entities/approval_action_result.dart';

class ApprovalActionResultModel extends ApprovalActionResult {
  const ApprovalActionResultModel({
    required super.status,
    required super.currentStep,
  });

  factory ApprovalActionResultModel.fromJson(Map<String, dynamic> json) {
    return ApprovalActionResultModel(
      status: json['status'] as String? ?? '-',
      currentStep: json['currentStep'] as String? ?? '-',
    );
  }
}

import '../../domain/entities/approval_summary.dart';

class ApprovalSummaryModel extends ApprovalSummary {
  const ApprovalSummaryModel({
    required super.id,
    required super.evaluationId,
    required super.status,
    required super.currentStep,
    required super.employeeId,
    required super.employeeName,
    required super.periodStart,
    required super.periodEnd,
  });

  factory ApprovalSummaryModel.fromJson(Map<String, dynamic> json) {
    return ApprovalSummaryModel(
      id: json['id']?.toString() ?? '',
      evaluationId: json['evaluationId']?.toString() ?? '',
      status: json['status'] as String? ?? '-',
      currentStep: json['currentStep'] as String? ?? '-',
      employeeId: json['employeeId']?.toString(),
      employeeName: json['employeeName'] as String?,
      periodStart: json['periodStart']?.toString(),
      periodEnd: json['periodEnd']?.toString(),
    );
  }
}

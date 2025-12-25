import '../../domain/entities/evaluation_detail.dart';
import 'evaluation_approval_step_model.dart';
import 'evaluation_item_model.dart';

class EvaluationDetailModel extends EvaluationDetail {
  const EvaluationDetailModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.employeeEmail,
    required super.periodStart,
    required super.periodEnd,
    required super.status,
    required super.items,
    required super.approvalId,
    required super.approvalStatus,
    required super.approvalCurrentStep,
    required super.approvalSteps,
  });

  factory EvaluationDetailModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] as Map<String, dynamic>?;
    final user = employee?['user'] as Map<String, dynamic>?;
    final approval = json['approval'] as Map<String, dynamic>?;
    final stepsJson = approval?['steps'] as List<dynamic>? ?? [];

    return EvaluationDetailModel(
      id: json['id']?.toString() ?? '',
      employeeId: (json['employeeId'] ?? employee?['id']).toString(),
      employeeName: employee?['name'] as String? ?? '-',
      employeeEmail: user?['email'] as String? ?? '-',
      periodStart: json['periodStart']?.toString() ?? '',
      periodEnd: json['periodEnd']?.toString() ?? '',
      status: json['status'] as String? ?? '-',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => EvaluationItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      approvalId: approval?['id']?.toString(),
      approvalStatus: approval?['status'] as String?,
      approvalCurrentStep: approval?['currentStep'] as String?,
      approvalSteps: stepsJson
          .map((item) => EvaluationApprovalStepModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

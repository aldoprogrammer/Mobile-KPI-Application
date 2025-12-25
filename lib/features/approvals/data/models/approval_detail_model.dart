import '../../domain/entities/approval_detail.dart';
import 'approval_step_model.dart';

class ApprovalDetailModel extends ApprovalDetail {
  const ApprovalDetailModel({
    required super.id,
    required super.evaluationId,
    required super.status,
    required super.currentStep,
    required super.steps,
  });

  factory ApprovalDetailModel.fromJson(Map<String, dynamic> json) {
    final evaluation = json['evaluation'] as Map<String, dynamic>?;
    final stepsJson = json['steps'] as List<dynamic>? ?? [];
    return ApprovalDetailModel(
      id: json['id']?.toString() ?? '',
      evaluationId: (json['evaluationId'] ?? evaluation?['id']).toString(),
      status: json['status'] as String? ?? '-',
      currentStep: json['currentStep'] as String? ?? '-',
      steps: stepsJson
          .map((item) => ApprovalStepModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

import '../../domain/entities/evaluation_approval_step.dart';

class EvaluationApprovalStepModel extends EvaluationApprovalStep {
  const EvaluationApprovalStepModel({
    required super.step,
    required super.action,
    required super.actedByEmail,
    required super.actedByRole,
    required super.comment,
    required super.createdAt,
  });

  factory EvaluationApprovalStepModel.fromJson(Map<String, dynamic> json) {
    final actedBy = json['actedBy'] as Map<String, dynamic>?;
    return EvaluationApprovalStepModel(
      step: json['step'] as String? ?? '-',
      action: json['action'] as String? ?? '-',
      actedByEmail: actedBy?['email'] as String? ?? '-',
      actedByRole: actedBy?['role'] as String? ?? '-',
      comment: json['comment'] as String?,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

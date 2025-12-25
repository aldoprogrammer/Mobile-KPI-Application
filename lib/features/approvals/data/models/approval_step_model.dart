import '../../domain/entities/approval_step.dart';

class ApprovalStepModel extends ApprovalStep {
  const ApprovalStepModel({
    required super.step,
    required super.action,
    required super.actedByEmail,
    required super.actedByRole,
    required super.comment,
    required super.createdAt,
  });

  factory ApprovalStepModel.fromJson(Map<String, dynamic> json) {
    final actedBy = json['actedBy'] as Map<String, dynamic>?;
    return ApprovalStepModel(
      step: json['step'] as String? ?? '-',
      action: json['action'] as String? ?? '-',
      actedByEmail: actedBy?['email'] as String? ?? '-',
      actedByRole: actedBy?['role'] as String? ?? '-',
      comment: json['comment'] as String?,
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

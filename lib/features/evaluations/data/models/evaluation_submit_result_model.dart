import '../../domain/entities/evaluation_submit_result.dart';

class EvaluationSubmitResultModel extends EvaluationSubmitResult {
  const EvaluationSubmitResultModel({
    required super.evaluationId,
    required super.approvalId,
    required super.status,
    required super.currentStep,
  });

  factory EvaluationSubmitResultModel.fromJson(Map<String, dynamic> json) {
    return EvaluationSubmitResultModel(
      evaluationId: json['evaluationId']?.toString() ?? '',
      approvalId: json['approvalId']?.toString() ?? '',
      status: json['status'] as String? ?? '-',
      currentStep: json['currentStep'] as String? ?? '-',
    );
  }
}

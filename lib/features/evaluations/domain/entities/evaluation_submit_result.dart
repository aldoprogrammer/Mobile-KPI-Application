import 'package:equatable/equatable.dart';

class EvaluationSubmitResult extends Equatable {
  const EvaluationSubmitResult({
    required this.evaluationId,
    required this.approvalId,
    required this.status,
    required this.currentStep,
  });

  final String evaluationId;
  final String approvalId;
  final String status;
  final String currentStep;

  @override
  List<Object?> get props => [evaluationId, approvalId, status, currentStep];
}

import 'package:equatable/equatable.dart';

import 'approval_step.dart';

class ApprovalDetail extends Equatable {
  const ApprovalDetail({
    required this.id,
    required this.evaluationId,
    required this.status,
    required this.currentStep,
    required this.steps,
  });

  final String id;
  final String evaluationId;
  final String status;
  final String currentStep;
  final List<ApprovalStep> steps;

  @override
  List<Object?> get props => [id, evaluationId, status, currentStep, steps];
}

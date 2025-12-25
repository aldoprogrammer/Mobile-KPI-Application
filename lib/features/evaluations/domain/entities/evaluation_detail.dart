import 'package:equatable/equatable.dart';

import 'evaluation_approval_step.dart';
import 'evaluation_item.dart';

class EvaluationDetail extends Equatable {
  const EvaluationDetail({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.items,
    required this.approvalId,
    required this.approvalStatus,
    required this.approvalCurrentStep,
    required this.approvalSteps,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final String periodStart;
  final String periodEnd;
  final String status;
  final List<EvaluationItem> items;
  final String? approvalId;
  final String? approvalStatus;
  final String? approvalCurrentStep;
  final List<EvaluationApprovalStep> approvalSteps;

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        employeeEmail,
        periodStart,
        periodEnd,
        status,
        items,
        approvalId,
        approvalStatus,
        approvalCurrentStep,
        approvalSteps,
      ];
}

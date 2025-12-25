import 'package:equatable/equatable.dart';

class ApprovalSummary extends Equatable {
  const ApprovalSummary({
    required this.id,
    required this.evaluationId,
    required this.status,
    required this.currentStep,
    required this.employeeId,
    required this.employeeName,
    required this.periodStart,
    required this.periodEnd,
  });

  final String id;
  final String evaluationId;
  final String status;
  final String currentStep;
  final String? employeeId;
  final String? employeeName;
  final String? periodStart;
  final String? periodEnd;

  @override
  List<Object?> get props => [
        id,
        evaluationId,
        status,
        currentStep,
        employeeId,
        employeeName,
        periodStart,
        periodEnd,
      ];
}

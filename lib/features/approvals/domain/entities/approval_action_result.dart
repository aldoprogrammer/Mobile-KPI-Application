import 'package:equatable/equatable.dart';

class ApprovalActionResult extends Equatable {
  const ApprovalActionResult({
    required this.status,
    required this.currentStep,
  });

  final String status;
  final String currentStep;

  @override
  List<Object?> get props => [status, currentStep];
}

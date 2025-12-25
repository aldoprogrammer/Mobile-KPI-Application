import 'package:equatable/equatable.dart';

class ReportSummary extends Equatable {
  const ReportSummary({
    required this.id,
    required this.employeeId,
    required this.periodStart,
    required this.periodEnd,
    required this.status,
    required this.totalScore,
  });

  final String id;
  final String employeeId;
  final String periodStart;
  final String periodEnd;
  final String status;
  final int totalScore;

  @override
  List<Object?> get props => [id, employeeId, periodStart, periodEnd, status, totalScore];
}

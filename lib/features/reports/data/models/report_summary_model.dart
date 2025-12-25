import '../../domain/entities/report_summary.dart';

class ReportSummaryModel extends ReportSummary {
  const ReportSummaryModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.periodStart,
    required super.periodEnd,
    required super.status,
    required super.totalScore,
  });

  factory ReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return ReportSummaryModel(
      id: json['id'].toString(),
      employeeId: json['employeeId'] as String? ?? '-',
      employeeName: json['employeeName'] as String?,
      periodStart: json['periodStart'] as String? ?? '-',
      periodEnd: json['periodEnd'] as String? ?? '-',
      status: json['status'] as String? ?? '-',
      totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
    );
  }
}

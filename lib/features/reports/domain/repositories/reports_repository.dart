import '../entities/report_summary.dart';

abstract class ReportsRepository {
  Future<List<ReportSummary>> getSummaries({
    required int page,
    required int pageSize,
    String? employeeId,
    String? from,
    String? to,
  });
}

import '../entities/report_summary.dart';
import '../repositories/reports_repository.dart';

class GetReportSummariesUseCase {
  const GetReportSummariesUseCase(this._repository);

  final ReportsRepository _repository;

  Future<List<ReportSummary>> call({
    required int page,
    required int pageSize,
    String? employeeId,
    String? from,
    String? to,
  }) {
    return _repository.getSummaries(
      page: page,
      pageSize: pageSize,
      employeeId: employeeId,
      from: from,
      to: to,
    );
  }
}

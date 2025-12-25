import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/report_summary_model.dart';

class ReportsRemoteDataSource {
  ReportsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<ReportSummaryModel>> getSummaries({
    required int page,
    required int pageSize,
    String? employeeId,
    String? from,
    String? to,
  }) async {
    try {
      final response = await _client.client.get(
        '/reports/summary',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (employeeId != null && employeeId.isNotEmpty) 'employeeId': employeeId,
          if (from != null && from.isNotEmpty) 'from': from,
          if (to != null && to.isNotEmpty) 'to': to,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>? ?? [])
          .map((item) => ReportSummaryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return items;
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }

  AppException _mapException(DioException e) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return AppException('Failed to fetch reports', code: e.response?.statusCode);
  }
}

import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/kpi_model.dart';

class KpisRemoteDataSource {
  KpisRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<KpiModel>> getKpis({bool? active}) async {
    try {
      final response = await _client.client.get(
        '/kpis',
        queryParameters: active == null ? null : {'active': active},
      );
      final items = (response.data as List<dynamic>? ?? [])
          .map((item) => KpiModel.fromJson(item as Map<String, dynamic>))
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
    return AppException('Failed to fetch KPIs', code: e.response?.statusCode);
  }
}
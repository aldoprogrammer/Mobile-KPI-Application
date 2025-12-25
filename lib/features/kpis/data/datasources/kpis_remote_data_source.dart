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

  Future<KpiModel> createKpi({
    required String code,
    required String title,
    required int weight,
    String? description,
    bool? active,
  }) async {
    try {
      final response = await _client.client.post(
        '/kpis',
        data: {
          'code': code,
          'title': title,
          'weight': weight,
          if (description != null && description.isNotEmpty) 'description': description,
          if (active != null) 'active': active,
        },
      );
      return KpiModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e);
    }
  }
}

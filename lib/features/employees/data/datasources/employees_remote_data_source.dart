import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/employee_model.dart';

class EmployeesRemoteDataSource {
  EmployeesRemoteDataSource(this._client);

  final ApiClient _client;

  Future<List<EmployeeModel>> getEmployees({required int page, required int pageSize}) async {
    try {
      final response = await _client.client.get(
        '/employees',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>? ?? [])
          .map((item) => EmployeeModel.fromJson(item as Map<String, dynamic>))
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
    return AppException('Failed to fetch employees', code: e.response?.statusCode);
  }
}

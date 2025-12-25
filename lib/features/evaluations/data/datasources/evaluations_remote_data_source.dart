import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/evaluation_create_result_model.dart';
import '../models/evaluation_detail_model.dart';
import '../models/evaluation_submit_result_model.dart';

class EvaluationsRemoteDataSource {
  EvaluationsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<EvaluationCreateResultModel> createEvaluation({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      final response = await _client.client.post(
        '/evaluations',
        data: {
          'employeeId': employeeId,
          'periodStart': periodStart,
          'periodEnd': periodEnd,
          'items': items,
        },
      );
      return EvaluationCreateResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to create evaluation');
    }
  }

  Future<EvaluationSubmitResultModel> submitEvaluation(String evaluationId) async {
    try {
      final response = await _client.client.post(
        '/evaluations/$evaluationId/submit',
        data: const {},
      );
      return EvaluationSubmitResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to submit evaluation');
    }
  }

  Future<EvaluationDetailModel> getEvaluation(String evaluationId) async {
    try {
      final response = await _client.client.get('/evaluations/$evaluationId');
      return EvaluationDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to fetch evaluation');
    }
  }

  AppException _mapException(DioException e, {required String message}) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return AppException(message, code: e.response?.statusCode);
  }
}

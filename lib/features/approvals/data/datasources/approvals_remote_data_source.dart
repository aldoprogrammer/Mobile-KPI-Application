import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/approval_action_result_model.dart';
import '../models/approval_detail_model.dart';
import '../models/approval_summary_model.dart';

class ApprovalsRemoteDataSource {
  ApprovalsRemoteDataSource(this._client);

  final ApiClient _client;

  Future<ApprovalDetailModel> getApproval(String approvalId) async {
    try {
      final response = await _client.client.get('/approvals/$approvalId');
      return ApprovalDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to fetch approval');
    }
  }

  Future<List<ApprovalSummaryModel>> getApprovals({
    required int page,
    required int pageSize,
    String? status,
  }) async {
    try {
      final response = await _client.client.get(
        '/approvals',
        queryParameters: {
          'page': page,
          'pageSize': pageSize,
          if (status != null && status.isNotEmpty) 'status': status,
        },
      );
      final data = response.data as Map<String, dynamic>;
      final items = (data['data'] as List<dynamic>? ?? [])
          .map((item) => ApprovalSummaryModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return items;
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to fetch approvals');
    }
  }

  Future<ApprovalActionResultModel> actOnApproval({
    required String approvalId,
    required String action,
    String? comment,
  }) async {
    try {
      final response = await _client.client.post(
        '/approvals/$approvalId/action',
        data: {
          'action': action,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );
      return ApprovalActionResultModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _mapException(e, message: 'Failed to update approval');
    }
  }

  AppException _mapException(DioException e, {required String message}) {
    if (e.error is AppException) {
      return e.error as AppException;
    }
    return AppException(message, code: e.response?.statusCode);
  }
}

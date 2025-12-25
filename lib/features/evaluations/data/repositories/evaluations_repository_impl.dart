import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/evaluation_create_result.dart';
import '../../domain/entities/evaluation_detail.dart';
import '../../domain/entities/evaluation_submit_result.dart';
import '../../domain/repositories/evaluations_repository.dart';
import '../datasources/evaluations_remote_data_source.dart';

class EvaluationsRepositoryImpl implements EvaluationsRepository {
  EvaluationsRepositoryImpl(this._remote);

  final EvaluationsRemoteDataSource _remote;

  @override
  Future<EvaluationCreateResult> createEvaluation({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      return await _remote.createEvaluation(
        employeeId: employeeId,
        periodStart: periodStart,
        periodEnd: periodEnd,
        items: items,
      );
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<EvaluationDetail> getEvaluation(String evaluationId) async {
    try {
      return await _remote.getEvaluation(evaluationId);
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<EvaluationSubmitResult> submitEvaluation(String evaluationId) async {
    try {
      return await _remote.submitEvaluation(evaluationId);
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  Failure _mapFailure(AppException exception) {
    if (exception is UnauthorizedException) {
      return UnauthorizedFailure(exception.message);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message);
    }
    return UnknownFailure(exception.message);
  }
}

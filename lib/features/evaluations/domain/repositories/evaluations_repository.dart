import '../entities/evaluation_create_result.dart';
import '../entities/evaluation_detail.dart';
import '../entities/evaluation_submit_result.dart';

abstract class EvaluationsRepository {
  Future<EvaluationCreateResult> createEvaluation({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required List<Map<String, dynamic>> items,
  });

  Future<EvaluationSubmitResult> submitEvaluation(String evaluationId);

  Future<EvaluationDetail> getEvaluation(String evaluationId);
}

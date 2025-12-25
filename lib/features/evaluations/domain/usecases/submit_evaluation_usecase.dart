import '../entities/evaluation_submit_result.dart';
import '../repositories/evaluations_repository.dart';

class SubmitEvaluationUseCase {
  const SubmitEvaluationUseCase(this._repository);

  final EvaluationsRepository _repository;

  Future<EvaluationSubmitResult> call(String evaluationId) {
    return _repository.submitEvaluation(evaluationId);
  }
}

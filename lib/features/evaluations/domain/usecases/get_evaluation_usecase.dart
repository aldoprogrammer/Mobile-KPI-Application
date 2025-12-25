import '../entities/evaluation_detail.dart';
import '../repositories/evaluations_repository.dart';

class GetEvaluationUseCase {
  const GetEvaluationUseCase(this._repository);

  final EvaluationsRepository _repository;

  Future<EvaluationDetail> call(String evaluationId) {
    return _repository.getEvaluation(evaluationId);
  }
}

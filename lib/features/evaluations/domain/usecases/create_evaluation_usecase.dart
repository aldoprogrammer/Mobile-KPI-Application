import '../entities/evaluation_create_result.dart';
import '../repositories/evaluations_repository.dart';

class CreateEvaluationUseCase {
  const CreateEvaluationUseCase(this._repository);

  final EvaluationsRepository _repository;

  Future<EvaluationCreateResult> call({
    required String employeeId,
    required String periodStart,
    required String periodEnd,
    required List<Map<String, dynamic>> items,
  }) {
    return _repository.createEvaluation(
      employeeId: employeeId,
      periodStart: periodStart,
      periodEnd: periodEnd,
      items: items,
    );
  }
}

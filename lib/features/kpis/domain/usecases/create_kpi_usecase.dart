import '../entities/kpi.dart';
import '../repositories/kpis_repository.dart';

class CreateKpiUseCase {
  const CreateKpiUseCase(this._repository);

  final KpisRepository _repository;

  Future<Kpi> call({
    required String code,
    required String title,
    required int weight,
    String? description,
    bool? active,
  }) {
    return _repository.createKpi(
      code: code,
      title: title,
      weight: weight,
      description: description,
      active: active,
    );
  }
}

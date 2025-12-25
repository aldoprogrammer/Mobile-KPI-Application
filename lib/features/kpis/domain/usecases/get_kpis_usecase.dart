import '../entities/kpi.dart';
import '../repositories/kpis_repository.dart';

class GetKpisUseCase {
  const GetKpisUseCase(this._repository);

  final KpisRepository _repository;

  Future<List<Kpi>> call() {
    return _repository.getKpis();
  }
}
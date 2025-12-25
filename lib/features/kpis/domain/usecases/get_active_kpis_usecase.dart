import '../entities/kpi.dart';
import '../repositories/kpis_repository.dart';

class GetActiveKpisUseCase {
  const GetActiveKpisUseCase(this._repository);

  final KpisRepository _repository;

  Future<List<Kpi>> call() {
    return _repository.getActiveKpis();
  }
}
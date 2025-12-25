import '../entities/kpi.dart';

abstract class KpisRepository {
  Future<List<Kpi>> getKpis();
  Future<List<Kpi>> getActiveKpis();
  Future<Kpi> createKpi({
    required String code,
    required String title,
    required int weight,
    String? description,
    bool? active,
  });
}

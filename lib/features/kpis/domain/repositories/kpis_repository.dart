import '../entities/kpi.dart';

abstract class KpisRepository {
  Future<List<Kpi>> getKpis();
  Future<List<Kpi>> getActiveKpis();
}
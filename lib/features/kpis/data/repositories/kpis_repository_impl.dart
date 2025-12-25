import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kpi.dart';
import '../../domain/repositories/kpis_repository.dart';
import '../datasources/kpis_remote_data_source.dart';

class KpisRepositoryImpl implements KpisRepository {
  KpisRepositoryImpl(this._remote);

  final KpisRemoteDataSource _remote;

  @override
  Future<List<Kpi>> getActiveKpis() async {
    try {
      return await _remote.getKpis(active: true);
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<Kpi>> getKpis() async {
    try {
      return await _remote.getKpis();
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
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({required AuthRemoteDataSource remote, required AuthLocalDataSource local})
      : _remote = remote,
        _local = local;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;

  @override
  Future<AuthToken> login({required String email, required String password}) async {
    try {
      final token = await _remote.login(email: email, password: password);
      await _local.cacheToken(token);
      return token;
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<AuthToken?> getSession() async {
    try {
      return await _local.readToken();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    await _local.clear();
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
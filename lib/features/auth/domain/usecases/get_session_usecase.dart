import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class GetSessionUseCase {
  const GetSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthToken?> call() {
    return _repository.getSession();
  }
}
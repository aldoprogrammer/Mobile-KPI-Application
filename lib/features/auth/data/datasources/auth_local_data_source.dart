import '../../../../core/network/token_pair.dart';
import '../../../../core/network/token_storage.dart';
import '../models/auth_token_model.dart';

class AuthLocalDataSource {
  AuthLocalDataSource(this._storage);

  final TokenStorage _storage;

  Future<void> cacheToken(AuthTokenModel token) async {
    await _storage.save(TokenPair(accessToken: token.accessToken, refreshToken: token.refreshToken));
  }

  Future<AuthTokenModel?> readToken() async {
    final pair = await _storage.read();
    if (pair == null) {
      return null;
    }
    return AuthTokenModel(accessToken: pair.accessToken, refreshToken: pair.refreshToken);
  }

  Future<void> clear() async {
    await _storage.clear();
  }
}
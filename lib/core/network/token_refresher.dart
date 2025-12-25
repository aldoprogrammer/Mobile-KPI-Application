import 'token_pair.dart';

abstract class TokenRefresher {
  Future<TokenPair?> refresh(String refreshToken);
}
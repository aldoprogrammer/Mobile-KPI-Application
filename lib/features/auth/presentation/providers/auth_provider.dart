import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/usecases/get_session_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required LoginUseCase loginUseCase,
    required GetSessionUseCase getSessionUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _loginUseCase = loginUseCase,
        _getSessionUseCase = getSessionUseCase,
        _logoutUseCase = logoutUseCase;

  final LoginUseCase _loginUseCase;
  final GetSessionUseCase _getSessionUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthStatus _status = AuthStatus.unknown;
  AuthToken? _token;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  AuthToken? get token => _token;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> initialize() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final token = await _getSessionUseCase();
    _token = token;
    _status = token == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    _loading = false;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final token = await _loginUseCase(email: email, password: password);
      _token = token;
      _status = AuthStatus.authenticated;
      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _loading = false;
      _error = e is Failure ? e.message : 'Login failed';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> forceLogout() async {
    await _logoutUseCase();
    _token = null;
    _status = AuthStatus.unauthenticated;
    _error = 'Session expired. Please log in again.';
    notifyListeners();
  }
}
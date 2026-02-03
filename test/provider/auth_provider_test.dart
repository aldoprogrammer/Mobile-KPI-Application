
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kpi_mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:kpi_mobile_app/features/auth/domain/usecases/get_session_usecase.dart';
import 'package:kpi_mobile_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:kpi_mobile_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:kpi_mobile_app/features/auth/presentation/providers/auth_provider.dart';

import 'auth_provider_test.mocks.dart';

@GenerateMocks([LoginUseCase, GetSessionUseCase, LogoutUseCase])
void main() {
  late AuthProvider authProvider;
  late MockLoginUseCase mockLoginUseCase;
  late MockGetSessionUseCase mockGetSessionUseCase;
  late MockLogoutUseCase mockLogoutUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockGetSessionUseCase = MockGetSessionUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    authProvider = AuthProvider(
      loginUseCase: mockLoginUseCase,
      getSessionUseCase: mockGetSessionUseCase,
      logoutUseCase: mockLogoutUseCase,
    );
  });

  final tAuthToken = AuthToken(accessToken: 'test_token', refreshToken: 'test_refresh_token');
  final tEmail = 'test@test.com';
  final tPassword = 'password';

  test('initial state is correct', () {
    expect(authProvider.status, AuthStatus.unknown);
    expect(authProvider.token, isNull);
    expect(authProvider.isLoading, isFalse);
    expect(authProvider.error, isNull);
  });

  group('initialize', () {
    test('should get session and update status to authenticated when token is present', () async {
      // arrange
      when(mockGetSessionUseCase()).thenAnswer((_) async => tAuthToken);
      // act
      await authProvider.initialize();
      // assert
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.token, tAuthToken);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
      verify(mockGetSessionUseCase());
      verifyNoMoreInteractions(mockGetSessionUseCase);
    });

    test('should get session and update status to unauthenticated when token is not present', () async {
      // arrange
      when(mockGetSessionUseCase()).thenAnswer((_) async => null);
      // act
      await authProvider.initialize();
      // assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.token, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
      verify(mockGetSessionUseCase());
      verifyNoMoreInteractions(mockGetSessionUseCase);
    });
  });

  group('login', () {
    test('should login and update status to authenticated on success', () async {
      // arrange
      when(mockLoginUseCase(email: tEmail, password: tPassword)).thenAnswer((_) async => tAuthToken);
      // act
      final result = await authProvider.login(email: tEmail, password: tPassword);
      // assert
      expect(result, isTrue);
      expect(authProvider.status, AuthStatus.authenticated);
      expect(authProvider.token, tAuthToken);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, isNull);
      verify(mockLoginUseCase(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockLoginUseCase);
    });

    test('should set error and status to unauthenticated on failure', () async {
      // arrange
      final exception = Exception('Login failed');
      when(mockLoginUseCase(email: tEmail, password: tPassword)).thenThrow(exception);
      // act
      final result = await authProvider.login(email: tEmail, password: tPassword);
      // assert
      expect(result, isFalse);
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.token, isNull);
      expect(authProvider.isLoading, isFalse);
      expect(authProvider.error, 'Login failed');
      verify(mockLoginUseCase(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockLoginUseCase);
    });
  });

  group('logout', () {
    test('should logout and update status to unauthenticated', () async {
      // arrange
      when(mockLogoutUseCase()).thenAnswer((_) async => null);
      // act
      await authProvider.logout();
      // assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.token, isNull);
      verify(mockLogoutUseCase());
      verifyNoMoreInteractions(mockLogoutUseCase);
    });
  });

  group('forceLogout', () {
    test('should logout, set error, and update status to unauthenticated', () async {
      // arrange
      when(mockLogoutUseCase()).thenAnswer((_) async => null);
      // act
      await authProvider.forceLogout();
      // assert
      expect(authProvider.status, AuthStatus.unauthenticated);
      expect(authProvider.token, isNull);
      expect(authProvider.error, 'Session expired. Please log in again.');
      verify(mockLogoutUseCase());
      verifyNoMoreInteractions(mockLogoutUseCase);
    });
  });
}

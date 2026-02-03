
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kpi_mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:kpi_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kpi_mobile_app/features/auth/domain/usecases/login_usecase.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  final tAuthToken = AuthToken(accessToken: 'test_token', refreshToken: 'test_refresh_token');
  final tEmail = 'test@test.com';
  final tPassword = 'password';

  test(
    'should login and return auth token from the repository',
    () async {
      // arrange
      when(mockAuthRepository.login(email: tEmail, password: tPassword)).thenAnswer((_) async => tAuthToken);
      // act
      final result = await usecase(email: tEmail, password: tPassword);
      // assert
      expect(result, tAuthToken);
      verify(mockAuthRepository.login(email: tEmail, password: tPassword));
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}

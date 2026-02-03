
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kpi_mobile_app/features/auth/domain/entities/auth_token.dart';
import 'package:kpi_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kpi_mobile_app/features/auth/domain/usecases/get_session_usecase.dart';

import 'get_session_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late GetSessionUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetSessionUseCase(mockAuthRepository);
  });

  final tAuthToken = AuthToken(accessToken: 'test_token', refreshToken: 'test_refresh_token');

  test(
    'should get auth token from the repository',
    () async {
      // arrange
      when(mockAuthRepository.getSession()).thenAnswer((_) async => tAuthToken);
      // act
      final result = await usecase();
      // assert
      expect(result, tAuthToken);
      verify(mockAuthRepository.getSession());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}

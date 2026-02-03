
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:kpi_mobile_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:kpi_mobile_app/features/auth/domain/usecases/logout_usecase.dart';

import 'logout_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LogoutUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LogoutUseCase(mockAuthRepository);
  });

  test(
    'should call logout on the repository',
    () async {
      // arrange
      when(mockAuthRepository.logout()).thenAnswer((_) async => null);
      // act
      await usecase();
      // assert
      verify(mockAuthRepository.logout());
      verifyNoMoreInteractions(mockAuthRepository);
    },
  );
}

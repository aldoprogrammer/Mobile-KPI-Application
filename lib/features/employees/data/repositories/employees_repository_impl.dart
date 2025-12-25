import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/employee.dart';
import '../../domain/repositories/employees_repository.dart';
import '../datasources/employees_remote_data_source.dart';

class EmployeesRepositoryImpl implements EmployeesRepository {
  EmployeesRepositoryImpl(this._remote);

  final EmployeesRemoteDataSource _remote;

  @override
  Future<Employee> createEmployee({
    required String email,
    required String password,
    required String role,
    required String name,
    String? department,
    String? position,
  }) async {
    try {
      return await _remote.createEmployee(
        email: email,
        password: password,
        role: role,
        name: name,
        department: department,
        position: position,
      );
    } on AppException catch (e) {
      throw _mapFailure(e);
    }
  }

  @override
  Future<List<Employee>> getEmployees({required int page, required int pageSize}) async {
    try {
      return await _remote.getEmployees(page: page, pageSize: pageSize);
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

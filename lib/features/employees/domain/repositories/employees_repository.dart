import '../entities/employee.dart';

abstract class EmployeesRepository {
  Future<List<Employee>> getEmployees({required int page, required int pageSize});
  Future<Employee> createEmployee({
    required String email,
    required String password,
    required String role,
    required String name,
    String? department,
    String? position,
  });
}

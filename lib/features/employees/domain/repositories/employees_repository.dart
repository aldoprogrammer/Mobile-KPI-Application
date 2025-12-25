import '../entities/employee.dart';

abstract class EmployeesRepository {
  Future<List<Employee>> getEmployees({required int page, required int pageSize});
}
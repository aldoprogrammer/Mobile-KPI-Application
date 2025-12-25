import '../entities/employee.dart';
import '../repositories/employees_repository.dart';

class CreateEmployeeUseCase {
  const CreateEmployeeUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<Employee> call({
    required String email,
    required String password,
    required String role,
    required String name,
    String? department,
    String? position,
  }) {
    return _repository.createEmployee(
      email: email,
      password: password,
      role: role,
      name: name,
      department: department,
      position: position,
    );
  }
}

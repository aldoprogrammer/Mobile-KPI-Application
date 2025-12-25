import '../entities/employee.dart';
import '../repositories/employees_repository.dart';

class GetEmployeesUseCase {
  const GetEmployeesUseCase(this._repository);

  final EmployeesRepository _repository;

  Future<List<Employee>> call({required int page, required int pageSize}) {
    return _repository.getEmployees(page: page, pageSize: pageSize);
  }
}
import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return EmployeeModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Unknown',
      email: user?['email'] as String? ?? '-',
      role: user?['role'] as String? ?? '-',
    );
  }
}

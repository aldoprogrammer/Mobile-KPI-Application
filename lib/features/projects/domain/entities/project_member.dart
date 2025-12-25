import 'package:equatable/equatable.dart';

class ProjectMember extends Equatable {
  const ProjectMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  final String id;
  final String name;
  final String email;
  final String? role;

  @override
  List<Object?> get props => [id, name, email, role];
}

import '../../domain/entities/project_member.dart';

class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    final employee = json['employee'] as Map<String, dynamic>?;
    final user = employee?['user'] as Map<String, dynamic>?;
    return ProjectMemberModel(
      id: json['id'].toString(),
      name: employee?['name'] as String? ?? 'Member',
      email: user?['email'] as String? ?? '-',
      role: user?['role'] as String?,
    );
  }
}

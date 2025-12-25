import '../../domain/entities/project_member.dart';

class ProjectMemberModel extends ProjectMember {
  const ProjectMemberModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      id: json['id'].toString(),
      name: json['name'] as String? ?? 'Member',
      email: json['email'] as String? ?? '-',
      role: json['role'] as String? ?? '-',
    );
  }
}
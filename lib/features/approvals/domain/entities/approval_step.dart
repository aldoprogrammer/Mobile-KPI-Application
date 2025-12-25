import 'package:equatable/equatable.dart';

class ApprovalStep extends Equatable {
  const ApprovalStep({
    required this.step,
    required this.action,
    required this.actedByEmail,
    required this.actedByRole,
    required this.comment,
    required this.createdAt,
  });

  final String step;
  final String action;
  final String actedByEmail;
  final String actedByRole;
  final String? comment;
  final String createdAt;

  @override
  List<Object?> get props => [step, action, actedByEmail, actedByRole, comment, createdAt];
}

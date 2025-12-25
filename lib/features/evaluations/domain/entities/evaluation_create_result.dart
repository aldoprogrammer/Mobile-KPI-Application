import 'package:equatable/equatable.dart';

class EvaluationCreateResult extends Equatable {
  const EvaluationCreateResult({
    required this.id,
    required this.status,
  });

  final String id;
  final String status;

  @override
  List<Object?> get props => [id, status];
}

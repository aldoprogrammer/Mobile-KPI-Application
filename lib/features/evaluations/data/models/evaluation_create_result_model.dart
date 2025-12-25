import '../../domain/entities/evaluation_create_result.dart';

class EvaluationCreateResultModel extends EvaluationCreateResult {
  const EvaluationCreateResultModel({
    required super.id,
    required super.status,
  });

  factory EvaluationCreateResultModel.fromJson(Map<String, dynamic> json) {
    return EvaluationCreateResultModel(
      id: json['id']?.toString() ?? '',
      status: json['status'] as String? ?? '-',
    );
  }
}

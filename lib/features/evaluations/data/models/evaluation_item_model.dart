import '../../domain/entities/evaluation_item.dart';

class EvaluationItemModel extends EvaluationItem {
  const EvaluationItemModel({
    required super.kpiId,
    required super.kpiTitle,
    required super.weight,
    required super.score,
    required super.comment,
  });

  factory EvaluationItemModel.fromJson(Map<String, dynamic> json) {
    final kpi = json['kpi'] as Map<String, dynamic>?;
    return EvaluationItemModel(
      kpiId: (json['kpiId'] ?? kpi?['id']).toString(),
      kpiTitle: kpi?['title'] as String? ?? '-',
      weight: (kpi?['weight'] as num?)?.toInt() ?? 0,
      score: (json['score'] as num?)?.toInt() ?? 0,
      comment: json['comment'] as String?,
    );
  }
}

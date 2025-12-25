import 'package:equatable/equatable.dart';

class EvaluationItem extends Equatable {
  const EvaluationItem({
    required this.kpiId,
    required this.kpiTitle,
    required this.weight,
    required this.score,
    required this.comment,
  });

  final String kpiId;
  final String kpiTitle;
  final int weight;
  final int score;
  final String? comment;

  @override
  List<Object?> get props => [kpiId, kpiTitle, weight, score, comment];
}

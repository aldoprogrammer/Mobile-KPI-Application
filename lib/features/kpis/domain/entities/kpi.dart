import 'package:equatable/equatable.dart';

class Kpi extends Equatable {
  const Kpi({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.weight,
    required this.active,
  });

  final String id;
  final String code;
  final String title;
  final String description;
  final int weight;
  final bool active;

  @override
  List<Object?> get props => [id, code, title, description, weight, active];
}

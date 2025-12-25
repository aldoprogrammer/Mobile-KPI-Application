import '../../domain/entities/kpi.dart';

class KpiModel extends Kpi {
  const KpiModel({
    required super.id,
    required super.code,
    required super.title,
    required super.description,
    required super.weight,
    required super.active,
  });

  factory KpiModel.fromJson(Map<String, dynamic> json) {
    return KpiModel(
      id: json['id'].toString(),
      code: json['code'] as String? ?? '-',
      title: json['title'] as String? ?? 'Untitled',
      description: json['description'] as String? ?? '-',
      weight: (json['weight'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? false,
    );
  }
}

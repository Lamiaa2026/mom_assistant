class GrowthLogModel {
  final String id;
  final String childId;
  final DateTime date;
  final double weightKg;
  final double heightCm;
  final double? headCircumferenceCm;
  final String? milestoneNote; // e.g. "أول ابتسامة", "أول خطوة"

  GrowthLogModel({
    required this.id,
    required this.childId,
    required this.date,
    required this.weightKg,
    required this.heightCm,
    this.headCircumferenceCm,
    this.milestoneNote,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'date': date.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'headCircumferenceCm': headCircumferenceCm,
      'milestoneNote': milestoneNote,
    };
  }

  factory GrowthLogModel.fromJson(Map<String, dynamic> json) {
    return GrowthLogModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      date: DateTime.parse(json['date'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      headCircumferenceCm: (json['headCircumferenceCm'] as num?)?.toDouble(),
      milestoneNote: json['milestoneNote'] as String?,
    );
  }
}

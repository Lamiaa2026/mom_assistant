enum HealthRecordType {
  vaccine,
  medicine,
  doctorVisit,
  growthMilestone,
}

class HealthVaccineModel {
  final String id;
  final String childId;
  final String title;
  final String description;
  final HealthRecordType type;
  final int? scheduledAgeMonths; // e.g. 0 for birth, 2, 4, 6, 9, 12, 18, 24
  final DateTime? scheduledDate;
  final bool isCompleted;
  final DateTime? completedDate;
  final String? dosage; // For medicine
  final String? doctorName;
  final String? notes;

  HealthVaccineModel({
    required this.id,
    required this.childId,
    required this.title,
    required this.description,
    required this.type,
    this.scheduledAgeMonths,
    this.scheduledDate,
    this.isCompleted = false,
    this.completedDate,
    this.dosage,
    this.doctorName,
    this.notes,
  });

  String get typeLabel {
    switch (type) {
      case HealthRecordType.vaccine:
        return 'تطعيم';
      case HealthRecordType.medicine:
        return 'دواء / جرعة';
      case HealthRecordType.doctorVisit:
        return 'زيارة طبيب';
      case HealthRecordType.growthMilestone:
        return 'إنجاز وتطور';
    }
  }

  String get ageBadge {
    if (scheduledAgeMonths == null) return '';
    if (scheduledAgeMonths == 0) return 'عند الولادة';
    if (scheduledAgeMonths! < 12) return '$scheduledAgeMonths أشهر';
    if (scheduledAgeMonths == 12) return 'عمر سنة';
    if (scheduledAgeMonths == 18) return 'عمر سنة ونصف';
    if (scheduledAgeMonths == 24) return 'عمر سنتين';
    return '$scheduledAgeMonths شهر';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'title': title,
      'description': description,
      'type': type.name,
      'scheduledAgeMonths': scheduledAgeMonths,
      'scheduledDate': scheduledDate?.toIso8601String(),
      'isCompleted': isCompleted,
      'completedDate': completedDate?.toIso8601String(),
      'dosage': dosage,
      'doctorName': doctorName,
      'notes': notes,
    };
  }

  factory HealthVaccineModel.fromJson(Map<String, dynamic> json) {
    return HealthVaccineModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      type: HealthRecordType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => HealthRecordType.vaccine,
      ),
      scheduledAgeMonths: json['scheduledAgeMonths'] as int?,
      scheduledDate: json['scheduledDate'] != null ? DateTime.parse(json['scheduledDate'] as String) : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedDate: json['completedDate'] != null ? DateTime.parse(json['completedDate'] as String) : null,
      dosage: json['dosage'] as String?,
      doctorName: json['doctorName'] as String?,
      notes: json['notes'] as String?,
    );
  }

  HealthVaccineModel copyWith({
    String? id,
    String? childId,
    String? title,
    String? description,
    HealthRecordType? type,
    int? scheduledAgeMonths,
    DateTime? scheduledDate,
    bool? isCompleted,
    DateTime? completedDate,
    String? dosage,
    String? doctorName,
    String? notes,
  }) {
    return HealthVaccineModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      scheduledAgeMonths: scheduledAgeMonths ?? this.scheduledAgeMonths,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedDate: completedDate ?? this.completedDate,
      dosage: dosage ?? this.dosage,
      doctorName: doctorName ?? this.doctorName,
      notes: notes ?? this.notes,
    );
  }
}

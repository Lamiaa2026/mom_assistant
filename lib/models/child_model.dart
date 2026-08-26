class ChildModel {
  final String id;
  final String name;
  final DateTime birthDate;
  final String gender; // 'boy' or 'girl'
  final String avatar; // emoji or icon key
  final double? currentWeightKg;
  final double? currentHeightCm;
  final String? bloodType;
  final String? allergies;
  final String? notes;

  ChildModel({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.gender,
    required this.avatar,
    this.currentWeightKg,
    this.currentHeightCm,
    this.bloodType,
    this.allergies,
    this.notes,
  });

  String get ageDescription {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    int months = now.month - birthDate.month;
    int days = now.day - birthDate.day;

    if (days < 0) {
      months -= 1;
      days += 30;
    }
    if (months < 0) {
      years -= 1;
      months += 12;
    }

    if (years > 0) {
      if (months > 0) {
        return '$years ${years == 1 ? "سنة" : "سنوات"} و $months ${months == 1 ? "شهر" : "أشهر"}';
      }
      return '$years ${years == 1 ? "سنة" : "سنوات"}';
    } else if (months > 0) {
      if (days > 0) {
        return '$months ${months == 1 ? "شهر" : "أشهر"} و $days يوم';
      }
      return '$months ${months == 1 ? "شهر" : "أشهر"}';
    } else {
      return '$days ${days == 1 ? "يوم" : "أيام"}';
    }
  }

  int get ageInMonths {
    final now = DateTime.now();
    return (now.year - birthDate.year) * 12 + (now.month - birthDate.month);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'avatar': avatar,
      'currentWeightKg': currentWeightKg,
      'currentHeightCm': currentHeightCm,
      'bloodType': bloodType,
      'allergies': allergies,
      'notes': notes,
    };
  }

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String? ?? 'boy',
      avatar: json['avatar'] as String? ?? '👶',
      currentWeightKg: (json['currentWeightKg'] as num?)?.toDouble(),
      currentHeightCm: (json['currentHeightCm'] as num?)?.toDouble(),
      bloodType: json['bloodType'] as String?,
      allergies: json['allergies'] as String?,
      notes: json['notes'] as String?,
    );
  }

  ChildModel copyWith({
    String? id,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? avatar,
    double? currentWeightKg,
    double? currentHeightCm,
    String? bloodType,
    String? allergies,
    String? notes,
  }) {
    return ChildModel(
      id: id ?? this.id,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      avatar: avatar ?? this.avatar,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      currentHeightCm: currentHeightCm ?? this.currentHeightCm,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      notes: notes ?? this.notes,
    );
  }
}

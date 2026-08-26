enum FeedingType {
  breastLeft,
  breastRight,
  breastBoth,
  bottleFormula,
  bottleBreastMilk,
  solidFood,
}

class FeedingLogModel {
  final String id;
  final String childId;
  final DateTime timestamp;
  final FeedingType type;
  final int durationSeconds; // For breastfeeding
  final int amountMl; // For bottle feeding
  final String? solidFoodDetails; // For solid food
  final String? notes;

  FeedingLogModel({
    required this.id,
    required this.childId,
    required this.timestamp,
    required this.type,
    this.durationSeconds = 0,
    this.amountMl = 0,
    this.solidFoodDetails,
    this.notes,
  });

  String get typeLabel {
    switch (type) {
      case FeedingType.breastLeft:
        return 'رضاعة طبيعية (الجانب الأيسر)';
      case FeedingType.breastRight:
        return 'رضاعة طبيعية (الجانب الأيمن)';
      case FeedingType.breastBoth:
        return 'رضاعة طبيعية (الجانبين)';
      case FeedingType.bottleFormula:
        return 'حليب صناعي (ببرونة)';
      case FeedingType.bottleBreastMilk:
        return 'حليب طبيعي مسحوب (ببرونة)';
      case FeedingType.solidFood:
        return 'وجبة طعام صلب / مهروس';
    }
  }

  String get typeShortLabel {
    switch (type) {
      case FeedingType.breastLeft:
        return 'طبيعي (يسار)';
      case FeedingType.breastRight:
        return 'طبيعي (يمين)';
      case FeedingType.breastBoth:
        return 'طبيعي (الجانبين)';
      case FeedingType.bottleFormula:
        return 'صناعي';
      case FeedingType.bottleBreastMilk:
        return 'مسحوب';
      case FeedingType.solidFood:
        return 'وجبة صلبة';
    }
  }

  String get summary {
    switch (type) {
      case FeedingType.breastLeft:
      case FeedingType.breastRight:
      case FeedingType.breastBoth:
        final minutes = (durationSeconds / 60).round();
        return '$minutes دقيقة';
      case FeedingType.bottleFormula:
      case FeedingType.bottleBreastMilk:
        return '$amountMl مل';
      case FeedingType.solidFood:
        return solidFoodDetails ?? 'وجبة مغذية';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'durationSeconds': durationSeconds,
      'amountMl': amountMl,
      'solidFoodDetails': solidFoodDetails,
      'notes': notes,
    };
  }

  factory FeedingLogModel.fromJson(Map<String, dynamic> json) {
    return FeedingLogModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: FeedingType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedingType.bottleFormula,
      ),
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      amountMl: json['amountMl'] as int? ?? 0,
      solidFoodDetails: json['solidFoodDetails'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

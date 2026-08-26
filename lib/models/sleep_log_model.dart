enum SleepQuality {
  peaceful,
  normal,
  restless,
}

class SleepLogModel {
  final String id;
  final String childId;
  final DateTime startTime;
  final DateTime? endTime;
  final SleepQuality quality;
  final bool isNap;
  final String? notes;

  SleepLogModel({
    required this.id,
    required this.childId,
    required this.startTime,
    this.endTime,
    this.quality = SleepQuality.peaceful,
    this.isNap = true,
    this.notes,
  });

  bool get isOngoing => endTime == null;

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  String get durationFormatted {
    final dur = duration;
    final hours = dur.inHours;
    final minutes = dur.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hours س $minutes د';
    }
    return '$minutes دقيقة';
  }

  String get qualityLabel {
    switch (quality) {
      case SleepQuality.peaceful:
        return 'هادئ ومريح 😴';
      case SleepQuality.normal:
        return 'عادي 😌';
      case SleepQuality.restless:
        return 'متقطع ومضطرب 🥺';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'childId': childId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'quality': quality.name,
      'isNap': isNap,
      'notes': notes,
    };
  }

  factory SleepLogModel.fromJson(Map<String, dynamic> json) {
    return SleepLogModel(
      id: json['id'] as String,
      childId: json['childId'] as String,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      quality: SleepQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => SleepQuality.peaceful,
      ),
      isNap: json['isNap'] as bool? ?? true,
      notes: json['notes'] as String?,
    );
  }

  SleepLogModel copyWith({
    String? id,
    String? childId,
    DateTime? startTime,
    DateTime? endTime,
    SleepQuality? quality,
    bool? isNap,
    String? notes,
  }) {
    return SleepLogModel(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      quality: quality ?? this.quality,
      isNap: isNap ?? this.isNap,
      notes: notes ?? this.notes,
    );
  }
}

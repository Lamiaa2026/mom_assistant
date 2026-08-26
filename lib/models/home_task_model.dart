enum TaskRoom {
  kitchen,
  livingRoom,
  kidsRoom,
  masterBedroom,
  bathroom,
  laundry,
  general,
}

enum TaskFrequency {
  daily,
  weekly,
  monthly,
}

class HomeTaskModel {
  final String id;
  final String title;
  final TaskRoom room;
  final TaskFrequency frequency;
  final bool isCompleted;
  final DateTime? completedAt;
  final int estimatedMinutes;
  final String? assignedTo; // e.g. "الأم", "الأب", "مساعد"

  HomeTaskModel({
    required this.id,
    required this.title,
    this.room = TaskRoom.general,
    this.frequency = TaskFrequency.daily,
    this.isCompleted = false,
    this.completedAt,
    this.estimatedMinutes = 15,
    this.assignedTo,
  });

  String get roomLabel {
    switch (room) {
      case TaskRoom.kitchen:
        return 'المطبخ 🍳';
      case TaskRoom.livingRoom:
        return 'غرفة المعيشة 🛋️';
      case TaskRoom.kidsRoom:
        return 'غرفة الأطفال 🧸';
      case TaskRoom.masterBedroom:
        return 'غرفة النوم 🛏️';
      case TaskRoom.bathroom:
        return 'الحمام 🛁';
      case TaskRoom.laundry:
        return 'الغسيل والكوي 🧺';
      case TaskRoom.general:
        return 'عام 🏠';
    }
  }

  String get frequencyLabel {
    switch (frequency) {
      case TaskFrequency.daily:
        return 'يومي';
      case TaskFrequency.weekly:
        return 'أسبوعي';
      case TaskFrequency.monthly:
        return 'شهري';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'room': room.name,
      'frequency': frequency.name,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'estimatedMinutes': estimatedMinutes,
      'assignedTo': assignedTo,
    };
  }

  factory HomeTaskModel.fromJson(Map<String, dynamic> json) {
    return HomeTaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      room: TaskRoom.values.firstWhere(
        (e) => e.name == json['room'],
        orElse: () => TaskRoom.general,
      ),
      frequency: TaskFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => TaskFrequency.daily,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      estimatedMinutes: json['estimatedMinutes'] as int? ?? 15,
      assignedTo: json['assignedTo'] as String?,
    );
  }

  HomeTaskModel copyWith({
    String? id,
    String? title,
    TaskRoom? room,
    TaskFrequency? frequency,
    bool? isCompleted,
    DateTime? completedAt,
    int? estimatedMinutes,
    String? assignedTo,
  }) {
    return HomeTaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      room: room ?? this.room,
      frequency: frequency ?? this.frequency,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      assignedTo: assignedTo ?? this.assignedTo,
    );
  }
}

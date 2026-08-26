enum MealType {
  breakfast,
  lunch,
  dinner,
  kidsSnack,
}

class MealPlanModel {
  final String id;
  final int dayOfWeek; // 0 = Sunday, 1 = Monday, ..., 6 = Saturday
  final MealType mealType;
  final String title;
  final String description;
  final int prepTimeMinutes;
  final List<String> ingredients;
  final bool isCooked;

  MealPlanModel({
    required this.id,
    required this.dayOfWeek,
    required this.mealType,
    required this.title,
    this.description = '',
    this.prepTimeMinutes = 20,
    this.ingredients = const [],
    this.isCooked = false,
  });

  String get mealTypeLabel {
    switch (mealType) {
      case MealType.breakfast:
        return 'إفطار 🥞';
      case MealType.lunch:
        return 'غداء 🍲';
      case MealType.dinner:
        return 'عشاء 🥗';
      case MealType.kidsSnack:
        return 'سناك للأطفال 🍌';
    }
  }

  static String getDayName(int day) {
    switch (day) {
      case 0:
        return 'الأحد';
      case 1:
        return 'الإثنين';
      case 2:
        return 'الثلاثاء';
      case 3:
        return 'الأربعاء';
      case 4:
        return 'الخميس';
      case 5:
        return 'الجمعة';
      case 6:
        return 'السبت';
      default:
        return '';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'mealType': mealType.name,
      'title': title,
      'description': description,
      'prepTimeMinutes': prepTimeMinutes,
      'ingredients': ingredients,
      'isCooked': isCooked,
    };
  }

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json['id'] as String,
      dayOfWeek: json['dayOfWeek'] as int? ?? 0,
      mealType: MealType.values.firstWhere(
        (e) => e.name == json['mealType'],
        orElse: () => MealType.lunch,
      ),
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      prepTimeMinutes: json['prepTimeMinutes'] as int? ?? 20,
      ingredients: (json['ingredients'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isCooked: json['isCooked'] as bool? ?? false,
    );
  }

  MealPlanModel copyWith({
    String? id,
    int? dayOfWeek,
    MealType? mealType,
    String? title,
    String? description,
    int? prepTimeMinutes,
    List<String>? ingredients,
    bool? isCooked,
  }) {
    return MealPlanModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      mealType: mealType ?? this.mealType,
      title: title ?? this.title,
      description: description ?? this.description,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      ingredients: ingredients ?? this.ingredients,
      isCooked: isCooked ?? this.isCooked,
    );
  }
}

enum GroceryCategory {
  babySupplies,
  fruitsVeggies,
  dairyEggs,
  meatFish,
  bakery,
  pantry,
  cleaning,
  other,
}

class GroceryItemModel {
  final String id;
  final String name;
  final GroceryCategory category;
  final String quantity; // e.g. "2 عبوة", "1 كجم", "3 حبات"
  final bool isBought;
  final DateTime addedDate;

  GroceryItemModel({
    required this.id,
    required this.name,
    this.category = GroceryCategory.pantry,
    this.quantity = '1',
    this.isBought = false,
    required this.addedDate,
  });

  String get categoryLabel {
    switch (category) {
      case GroceryCategory.babySupplies:
        return 'مستلزمات الطفل وحفاضات 👶';
      case GroceryCategory.fruitsVeggies:
        return 'خضار وفواكه 🍎';
      case GroceryCategory.dairyEggs:
        return 'ألبان وأجبان وبيض 🧀';
      case GroceryCategory.meatFish:
        return 'لحوم ودواجن وأسماك 🍗';
      case GroceryCategory.bakery:
        return 'مخبوزات ومعجنات 🍞';
      case GroceryCategory.pantry:
        return 'بقالة ومعلبات 🥫';
      case GroceryCategory.cleaning:
        return 'منظفات وعناية منزلية 🧼';
      case GroceryCategory.other:
        return 'أخرى 🛒';
    }
  }

  String get categoryShortLabel {
    switch (category) {
      case GroceryCategory.babySupplies:
        return 'الطفل';
      case GroceryCategory.fruitsVeggies:
        return 'خضار وفواكه';
      case GroceryCategory.dairyEggs:
        return 'ألبان';
      case GroceryCategory.meatFish:
        return 'لحوم';
      case GroceryCategory.bakery:
        return 'مخبوزات';
      case GroceryCategory.pantry:
        return 'بقالة';
      case GroceryCategory.cleaning:
        return 'منظفات';
      case GroceryCategory.other:
        return 'أخرى';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'isBought': isBought,
      'addedDate': addedDate.toIso8601String(),
    };
  }

  factory GroceryItemModel.fromJson(Map<String, dynamic> json) {
    return GroceryItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: GroceryCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => GroceryCategory.pantry,
      ),
      quantity: json['quantity'] as String? ?? '1',
      isBought: json['isBought'] as bool? ?? false,
      addedDate: DateTime.parse(json['addedDate'] as String),
    );
  }

  GroceryItemModel copyWith({
    String? id,
    String? name,
    GroceryCategory? category,
    String? quantity,
    bool? isBought,
    DateTime? addedDate,
  }) {
    return GroceryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isBought: isBought ?? this.isBought,
      addedDate: addedDate ?? this.addedDate,
    );
  }
}

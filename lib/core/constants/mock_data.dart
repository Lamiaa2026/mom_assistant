import 'package:uuid/uuid.dart';
import '../../models/child_model.dart';
import '../../models/feeding_log_model.dart';
import '../../models/sleep_log_model.dart';
import '../../models/health_vaccine_model.dart';
import '../../models/growth_log_model.dart';
import '../../models/home_task_model.dart';
import '../../models/grocery_item_model.dart';
import '../../models/meal_plan_model.dart';
import '../../models/ai_message_model.dart';

class MockData {
  static const uuid = Uuid();

  static final String babyZaidId = 'child_zaid_1';
  static final String childLinaId = 'child_lina_2';

  static List<ChildModel> getInitialChildren() {
    return [
      ChildModel(
        id: babyZaidId,
        name: 'زيد',
        birthDate: DateTime.now().subtract(const Duration(days: 190)), // ~6 months
        gender: 'boy',
        avatar: '👶',
        currentWeightKg: 7.8,
        currentHeightCm: 68.5,
        bloodType: 'O+',
        allergies: 'لا يوجد تحسس معروف حتى الآن',
        notes: 'يحب الاستماع إلى أصوات الطبيعة قبل النوم',
      ),
      ChildModel(
        id: childLinaId,
        name: 'لينا',
        birthDate: DateTime.now().subtract(const Duration(days: 365 * 3 + 60)), // ~3.5 years
        gender: 'girl',
        avatar: '👧',
        currentWeightKg: 14.2,
        currentHeightCm: 98.0,
        bloodType: 'A+',
        allergies: 'تحسس خفيف من الفراولة',
        notes: 'تحب الرسم وقصص الأميرات والحيوانات اللطيفة',
      ),
    ];
  }

  static List<FeedingLogModel> getInitialFeedingLogs(String childId) {
    final now = DateTime.now();
    return [
      FeedingLogModel(
        id: uuid.v4(),
        childId: childId,
        timestamp: now.subtract(const Duration(hours: 1, minutes: 20)),
        type: FeedingType.breastLeft,
        durationSeconds: 15 * 60,
        notes: 'رضاعة طبيعية مريحة',
      ),
      FeedingLogModel(
        id: uuid.v4(),
        childId: childId,
        timestamp: now.subtract(const Duration(hours: 4, minutes: 10)),
        type: FeedingType.solidFood,
        solidFoodDetails: 'مهروس كوسة وجزر مع شوفان 🥕',
        notes: 'أكل نصف الوجبة بشهية جيدة',
      ),
      FeedingLogModel(
        id: uuid.v4(),
        childId: childId,
        timestamp: now.subtract(const Duration(hours: 7)),
        type: FeedingType.bottleFormula,
        amountMl: 150,
        notes: 'شرب الرضعة بالكامل',
      ),
    ];
  }

  static List<SleepLogModel> getInitialSleepLogs(String childId) {
    final now = DateTime.now();
    return [
      SleepLogModel(
        id: uuid.v4(),
        childId: childId,
        startTime: now.subtract(const Duration(hours: 2, minutes: 30)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 30)),
        quality: SleepQuality.peaceful,
        isNap: true,
        notes: 'غفوة ما بعد الظهيرة هادئة',
      ),
      SleepLogModel(
        id: uuid.v4(),
        childId: childId,
        startTime: DateTime(now.year, now.month, now.day - 1, 21, 0),
        endTime: DateTime(now.year, now.month, now.day, 6, 30),
        quality: SleepQuality.normal,
        isNap: false,
        notes: 'استيقظ مرة واحدة للرضاعة في الساعة 3 فجراً',
      ),
    ];
  }

  static List<HealthVaccineModel> getInitialHealthRecords(String childId) {
    final now = DateTime.now();
    return [
      HealthVaccineModel(
        id: uuid.v4(),
        childId: childId,
        title: 'تطعيم الدرن والتهاب الكبد B (الولادة)',
        description: 'تطعيمات اليوم الأول في المستشفى',
        type: HealthRecordType.vaccine,
        scheduledAgeMonths: 0,
        isCompleted: true,
        completedDate: now.subtract(const Duration(days: 185)),
      ),
      HealthVaccineModel(
        id: uuid.v4(),
        childId: childId,
        title: 'تطعيم الشهرين (الخماسي + الروتا + شلل الأطفال)',
        description: 'الجرعة الأولى من التطعيمات الأساسية',
        type: HealthRecordType.vaccine,
        scheduledAgeMonths: 2,
        isCompleted: true,
        completedDate: now.subtract(const Duration(days: 125)),
      ),
      HealthVaccineModel(
        id: uuid.v4(),
        childId: childId,
        title: 'تطعيم الأربعة أشهر (الجرعة الثانية)',
        description: 'الخماسي والمكورات الرئوية وشلل الأطفال',
        type: HealthRecordType.vaccine,
        scheduledAgeMonths: 4,
        isCompleted: true,
        completedDate: now.subtract(const Duration(days: 65)),
      ),
      HealthVaccineModel(
        id: uuid.v4(),
        childId: childId,
        title: 'تطعيم الستة أشهر (الجرعة الثالثة)',
        description: 'الخماسي وشلل الأطفال والإنفلونزا البكتيرية',
        type: HealthRecordType.vaccine,
        scheduledAgeMonths: 6,
        isCompleted: false,
        scheduledDate: now.add(const Duration(days: 5)),
        notes: 'موعد في المركز الصحي الساعة 10:00 صباحاً',
      ),
      HealthVaccineModel(
        id: uuid.v4(),
        childId: childId,
        title: 'فيتامين د (Vitamin D3 Drops)',
        description: '4 قطرات يومياً بالفم لتقوية العظام',
        type: HealthRecordType.medicine,
        dosage: '4 قطرات يومياً (400 وحدة)',
        isCompleted: false,
        notes: 'يُفضل إعطاؤه صباحاً مع الرضاعة',
      ),
      HealthVaccineModel(
        id: uuid.v4(),
        childId: childId,
        title: 'تطعيم التسعة أشهر (الحصبة المنفردة)',
        description: 'التطعيم الوقائي للحصبة وشلل الأطفال الفموي',
        type: HealthRecordType.vaccine,
        scheduledAgeMonths: 9,
        isCompleted: false,
        scheduledDate: now.add(const Duration(days: 90)),
      ),
    ];
  }

  static List<GrowthLogModel> getInitialGrowthLogs(String childId) {
    final now = DateTime.now();
    return [
      GrowthLogModel(
        id: uuid.v4(),
        childId: childId,
        date: now.subtract(const Duration(days: 180)),
        weightKg: 3.4,
        heightCm: 50.0,
        headCircumferenceCm: 35.0,
        milestoneNote: 'الوزن عند الولادة 👶',
      ),
      GrowthLogModel(
        id: uuid.v4(),
        childId: childId,
        date: now.subtract(const Duration(days: 120)),
        weightKg: 5.5,
        heightCm: 58.0,
        headCircumferenceCm: 39.5,
        milestoneNote: 'أول ابتسامة ومتابعة الأصوات بعينيه ✨',
      ),
      GrowthLogModel(
        id: uuid.v4(),
        childId: childId,
        date: now.subtract(const Duration(days: 60)),
        weightKg: 6.8,
        heightCm: 64.0,
        headCircumferenceCm: 42.0,
        milestoneNote: 'بدأ يمسك بالألعاب ويقلب على بطنه 🧸',
      ),
      GrowthLogModel(
        id: uuid.v4(),
        childId: childId,
        date: now.subtract(const Duration(days: 5)),
        weightKg: 7.8,
        heightCm: 68.5,
        headCircumferenceCm: 43.8,
        milestoneNote: 'الجلوس مع مسند وبداية تذوق الخضار المهروس 🥕',
      ),
    ];
  }

  static List<HomeTaskModel> getInitialHomeTasks() {
    return [
      HomeTaskModel(
        id: uuid.v4(),
        title: 'تعقيم ببرونات وألعاب الطفل',
        room: TaskRoom.kitchen,
        frequency: TaskFrequency.daily,
        isCompleted: true,
        estimatedMinutes: 10,
        completedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      HomeTaskModel(
        id: uuid.v4(),
        title: 'تشغيل غسيل ملابس الأطفال وتطبيقها',
        room: TaskRoom.laundry,
        frequency: TaskFrequency.daily,
        isCompleted: false,
        estimatedMinutes: 25,
      ),
      HomeTaskModel(
        id: uuid.v4(),
        title: 'مسح وتطهير أسطح وطاولات الصالة',
        room: TaskRoom.livingRoom,
        frequency: TaskFrequency.daily,
        isCompleted: false,
        estimatedMinutes: 15,
      ),
      HomeTaskModel(
        id: uuid.v4(),
        title: 'ترتيب خزانة مستلزمات وحفاضات الطفل',
        room: TaskRoom.kidsRoom,
        frequency: TaskFrequency.weekly,
        isCompleted: false,
        estimatedMinutes: 20,
      ),
      HomeTaskModel(
        id: uuid.v4(),
        title: 'تنظيف وتلميع الحمام وتعقيمه',
        room: TaskRoom.bathroom,
        frequency: TaskFrequency.weekly,
        isCompleted: true,
        estimatedMinutes: 20,
        completedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      HomeTaskModel(
        id: uuid.v4(),
        title: 'تغيير مفارش سرير الأطفال والوسائد',
        room: TaskRoom.kidsRoom,
        frequency: TaskFrequency.weekly,
        isCompleted: false,
        estimatedMinutes: 15,
      ),
    ];
  }

  static List<GroceryItemModel> getInitialGroceryItems() {
    final now = DateTime.now();
    return [
      // Baby
      GroceryItemModel(
        id: uuid.v4(),
        name: 'حفاضات مقاس 3 (عبوة جامبو)',
        category: GroceryCategory.babySupplies,
        quantity: '1 كيس كبير',
        isBought: false,
        addedDate: now,
      ),
      GroceryItemModel(
        id: uuid.v4(),
        name: 'مناديل مبللة مائية بدون عطر (Water Wipes)',
        category: GroceryCategory.babySupplies,
        quantity: '4 عبوات',
        isBought: true,
        addedDate: now,
      ),
      GroceryItemModel(
        id: uuid.v4(),
        name: 'كريم التسلخات زنك وزيت زيتون',
        category: GroceryCategory.babySupplies,
        quantity: '1 علبة',
        isBought: false,
        addedDate: now,
      ),

      // Fruits & Veggies
      GroceryItemModel(
        id: uuid.v4(),
        name: 'كوسة وجزر وبطاطا حلوة لسيريلاك البيت',
        category: GroceryCategory.fruitsVeggies,
        quantity: '1 كجم كل صنف',
        isBought: false,
        addedDate: now,
      ),
      GroceryItemModel(
        id: uuid.v4(),
        name: 'موز وتفاح أحمر',
        category: GroceryCategory.fruitsVeggies,
        quantity: '2 كجم',
        isBought: true,
        addedDate: now,
      ),
      GroceryItemModel(
        id: uuid.v4(),
        name: 'أفوكادو طازج',
        category: GroceryCategory.fruitsVeggies,
        quantity: '4 حبات',
        isBought: false,
        addedDate: now,
      ),

      // Dairy & Pantry
      GroceryItemModel(
        id: uuid.v4(),
        name: 'زبادي كامل الدسم وزبادي أطفال يوناني',
        category: GroceryCategory.dairyEggs,
        quantity: '6 علب',
        isBought: false,
        addedDate: now,
      ),
      GroceryItemModel(
        id: uuid.v4(),
        name: 'شوفان حبة كاملة سريع الطهي',
        category: GroceryCategory.pantry,
        quantity: '1 علبة',
        isBought: true,
        addedDate: now,
      ),

      // Cleaning
      GroceryItemModel(
        id: uuid.v4(),
        name: 'مسحوق غسيل مخصص لملابس الأطفال الرضع',
        category: GroceryCategory.cleaning,
        quantity: '1 جالون',
        isBought: false,
        addedDate: now,
      ),
    ];
  }

  static List<MealPlanModel> getInitialMealPlans() {
    return [
      MealPlanModel(
        id: uuid.v4(),
        dayOfWeek: 0, // Sunday
        mealType: MealType.breakfast,
        title: 'بان كيك الشوفان والموز الصحي 🥞',
        description: 'غني بالألياف ومناسب للأطفال والأم بدون سكر مضاف',
        prepTimeMinutes: 15,
        ingredients: ['شوفان مطحون', 'موزة ناضجة', 'بيضة', 'حليب', 'قرفة خفيفة'],
        isCooked: true,
      ),
      MealPlanModel(
        id: uuid.v4(),
        dayOfWeek: 0,
        mealType: MealType.lunch,
        title: 'شوربة خضار مشكلة مع أرز بسمتي ودجاج مشوي 🍲',
        description: 'وجبة متوازنة ومغذية لكافة أفراد الأسرة',
        prepTimeMinutes: 35,
        ingredients: ['صدور دجاج', 'جزر وبطاطس وبازلاء', 'أرز بسمتي', 'مرقة دجاج طبيعية'],
        isCooked: false,
      ),
      MealPlanModel(
        id: uuid.v4(),
        dayOfWeek: 0,
        mealType: MealType.kidsSnack,
        title: 'أصابع الخيار والجزر مع غموس الزبادي 🥒',
        description: 'سناك بارد ومقرمش ومنعش للأطفال الصغار',
        prepTimeMinutes: 5,
        ingredients: ['خيار', 'جزر', 'زبادي', 'رشة زعتر أو نعناع مجفف'],
        isCooked: false,
      ),
      MealPlanModel(
        id: uuid.v4(),
        dayOfWeek: 1, // Monday
        mealType: MealType.lunch,
        title: 'صينية بطاطس بالفرن مع كفتة لحم وسلطة خضراء 🥔',
        description: 'وجبة دافئة وسريعة التحضير في صينية واحدة',
        prepTimeMinutes: 40,
        ingredients: ['لحم مفروم', 'بطاطس', 'طماطم وبصل', 'بهارات خفيفة'],
        isCooked: false,
      ),
      MealPlanModel(
        id: uuid.v4(),
        dayOfWeek: 2, // Tuesday
        mealType: MealType.lunch,
        title: 'مكرونة بصوص الطماطم والسبانخ وجبن الموزاريلا 🍝',
        description: 'طريقة ذكية لتقديم السبانخ والخضار للأطفال بطعم رائع',
        prepTimeMinutes: 20,
        ingredients: ['مكرونة أقلام', 'صلصة طماطم طازجة', 'سبانخ مفرومة', 'جبن موزاريلا'],
        isCooked: false,
      ),
    ];
  }

  static List<AIMessageModel> getInitialAIMessages() {
    return [
      AIMessageModel(
        id: uuid.v4(),
        content: 'مرحباً بكِ يا سوبر ماما! 🌸 أنا مستشاركِ الذكي ومساعدكِ اليومي في رعاية أطفالكِ، إدارة البيت، واقتراح أفكار سريعة ومريحة لكِ. كيف يمكنني مساعدتكِ الآن؟',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        type: AIMessageType.generalChat,
      ),
    ];
  }
}

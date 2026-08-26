import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/services/storage_service.dart';
import '../core/constants/mock_data.dart';
import '../core/services/ai_assistant_service.dart';
import '../models/child_model.dart';
import '../models/feeding_log_model.dart';
import '../models/sleep_log_model.dart';
import '../models/health_vaccine_model.dart';
import '../models/growth_log_model.dart';
import '../models/home_task_model.dart';
import '../models/grocery_item_model.dart';
import '../models/meal_plan_model.dart';
import '../models/ai_message_model.dart';

class AppState extends ChangeNotifier {
  final StorageService _storage;
  final _uuid = const Uuid();

  AppState(this._storage);

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  int _currentNavIndex = 0;
  int get currentNavIndex => _currentNavIndex;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  List<ChildModel> _children = [];
  String? _activeChildId;

  List<FeedingLogModel> _feedingLogs = [];
  List<SleepLogModel> _sleepLogs = [];
  List<HealthVaccineModel> _healthRecords = [];
  List<GrowthLogModel> _growthLogs = [];
  List<HomeTaskModel> _homeTasks = [];
  List<GroceryItemModel> _groceryItems = [];
  List<MealPlanModel> _mealPlans = [];
  List<AIMessageModel> _aiMessages = [];

  bool _isAiThinking = false;
  bool get isAiThinking => _isAiThinking;

  // Getters
  List<ChildModel> get children => _children;
  String? get activeChildId => _activeChildId;

  ChildModel? get activeChild {
    if (_children.isEmpty) return null;
    return _children.firstWhere(
      (c) => c.id == _activeChildId,
      orElse: () => _children.first,
    );
  }

  List<FeedingLogModel> get feedingLogsForActiveChild {
    if (_activeChildId == null) return _feedingLogs;
    return _feedingLogs.where((l) => l.childId == _activeChildId).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  List<SleepLogModel> get sleepLogsForActiveChild {
    if (_activeChildId == null) return _sleepLogs;
    return _sleepLogs.where((l) => l.childId == _activeChildId).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  List<HealthVaccineModel> get healthRecordsForActiveChild {
    if (_activeChildId == null) return _healthRecords;
    return _healthRecords.where((r) => r.childId == _activeChildId).toList();
  }

  List<GrowthLogModel> get growthLogsForActiveChild {
    if (_activeChildId == null) return _growthLogs;
    return _growthLogs.where((g) => g.childId == _activeChildId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<HomeTaskModel> get homeTasks => _homeTasks;
  List<GroceryItemModel> get groceryItems => _groceryItems;
  List<MealPlanModel> get mealPlans => _mealPlans;
  List<AIMessageModel> get aiMessages => _aiMessages;

  // Metric Helpers for Dashboard
  int get completedTasksCount => _homeTasks.where((t) => t.isCompleted).length;
  int get totalTasksCount => _homeTasks.length;
  double get taskProgress => _homeTasks.isEmpty ? 0 : completedTasksCount / totalTasksCount;

  FeedingLogModel? get lastFeedingLog {
    final list = feedingLogsForActiveChild;
    return list.isNotEmpty ? list.first : null;
  }

  SleepLogModel? get lastSleepLog {
    final list = sleepLogsForActiveChild;
    return list.isNotEmpty ? list.first : null;
  }

  HealthVaccineModel? get nextUpcomingVaccine {
    final list = healthRecordsForActiveChild.where((r) => !r.isCompleted && r.type == HealthRecordType.vaccine).toList();
    return list.isNotEmpty ? list.first : null;
  }

  int get unboughtGroceriesCount => _groceryItems.where((g) => !g.isBought).length;

  int get todaySleepTotalMinutes {
    final now = DateTime.now();
    final todayLogs = sleepLogsForActiveChild.where((s) {
      return s.startTime.year == now.year && s.startTime.month == now.month && s.startTime.day == now.day;
    });
    int total = 0;
    for (var log in todayLogs) {
      total += log.duration.inMinutes;
    }
    return total;
  }

  // Initialization
  Future<void> init() async {
    _isDarkMode = _storage.loadIsDarkMode();

    // Load or populate children
    final loadedChildren = _storage.loadChildren();
    if (loadedChildren != null && loadedChildren.isNotEmpty) {
      _children = loadedChildren;
    } else {
      _children = MockData.getInitialChildren();
      await _storage.saveChildren(_children);
    }

    _activeChildId = _storage.loadActiveChildId() ?? (_children.isNotEmpty ? _children.first.id : null);

    // Load or populate logs
    final activeId = _activeChildId ?? '';

    _feedingLogs = _storage.loadFeedingLogs() ?? MockData.getInitialFeedingLogs(activeId);
    _sleepLogs = _storage.loadSleepLogs() ?? MockData.getInitialSleepLogs(activeId);
    _healthRecords = _storage.loadHealthRecords() ?? MockData.getInitialHealthRecords(activeId);
    _growthLogs = _storage.loadGrowthLogs() ?? MockData.getInitialGrowthLogs(activeId);
    _homeTasks = _storage.loadHomeTasks() ?? MockData.getInitialHomeTasks();
    _groceryItems = _storage.loadGroceryItems() ?? MockData.getInitialGroceryItems();
    _mealPlans = _storage.loadMealPlans() ?? MockData.getInitialMealPlans();
    _aiMessages = _storage.loadAIMessages() ?? MockData.getInitialAIMessages();

    _isInitialized = true;
    notifyListeners();
  }

  // Navigation & Theme
  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _storage.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Child Profile Management
  Future<void> setActiveChild(String childId) async {
    _activeChildId = childId;
    await _storage.saveActiveChildId(childId);
    notifyListeners();
  }

  Future<void> addChild(ChildModel child) async {
    _children.add(child);
    _activeChildId = child.id;
    await _storage.saveChildren(_children);
    await _storage.saveActiveChildId(child.id);
    notifyListeners();
  }

  Future<void> updateChild(ChildModel updated) async {
    final idx = _children.indexWhere((c) => c.id == updated.id);
    if (idx != -1) {
      _children[idx] = updated;
      await _storage.saveChildren(_children);
      notifyListeners();
    }
  }

  // Feeding Actions
  Future<void> addFeedingLog(FeedingLogModel log) async {
    _feedingLogs.insert(0, log);
    await _storage.saveFeedingLogs(_feedingLogs);
    notifyListeners();
  }

  Future<void> deleteFeedingLog(String id) async {
    _feedingLogs.removeWhere((l) => l.id == id);
    await _storage.saveFeedingLogs(_feedingLogs);
    notifyListeners();
  }

  // Sleep Actions
  Future<void> addSleepLog(SleepLogModel log) async {
    _sleepLogs.insert(0, log);
    await _storage.saveSleepLogs(_sleepLogs);
    notifyListeners();
  }

  Future<void> updateSleepLog(SleepLogModel log) async {
    final idx = _sleepLogs.indexWhere((l) => l.id == log.id);
    if (idx != -1) {
      _sleepLogs[idx] = log;
      await _storage.saveSleepLogs(_sleepLogs);
      notifyListeners();
    }
  }

  Future<void> deleteSleepLog(String id) async {
    _sleepLogs.removeWhere((l) => l.id == id);
    await _storage.saveSleepLogs(_sleepLogs);
    notifyListeners();
  }

  // Health Actions
  Future<void> toggleHealthRecordCompletion(String id) async {
    final idx = _healthRecords.indexWhere((r) => r.id == id);
    if (idx != -1) {
      final old = _healthRecords[idx];
      _healthRecords[idx] = old.copyWith(
        isCompleted: !old.isCompleted,
        completedDate: !old.isCompleted ? DateTime.now() : null,
      );
      await _storage.saveHealthRecords(_healthRecords);
      notifyListeners();
    }
  }

  Future<void> addHealthRecord(HealthVaccineModel record) async {
    _healthRecords.add(record);
    await _storage.saveHealthRecords(_healthRecords);
    notifyListeners();
  }

  // Growth Actions
  Future<void> addGrowthLog(GrowthLogModel log) async {
    _growthLogs.add(log);
    // update child weight & height
    final child = activeChild;
    if (child != null) {
      updateChild(child.copyWith(
        currentWeightKg: log.weightKg,
        currentHeightCm: log.heightCm,
      ));
    }
    await _storage.saveGrowthLogs(_growthLogs);
    notifyListeners();
  }

  // Home Tasks Actions
  Future<void> toggleHomeTask(String id) async {
    final idx = _homeTasks.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final old = _homeTasks[idx];
      _homeTasks[idx] = old.copyWith(
        isCompleted: !old.isCompleted,
        completedAt: !old.isCompleted ? DateTime.now() : null,
      );
      await _storage.saveHomeTasks(_homeTasks);
      notifyListeners();
    }
  }

  Future<void> addHomeTask(HomeTaskModel task) async {
    _homeTasks.insert(0, task);
    await _storage.saveHomeTasks(_homeTasks);
    notifyListeners();
  }

  Future<void> deleteHomeTask(String id) async {
    _homeTasks.removeWhere((t) => t.id == id);
    await _storage.saveHomeTasks(_homeTasks);
    notifyListeners();
  }

  // Groceries Actions
  Future<void> toggleGroceryItem(String id) async {
    final idx = _groceryItems.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final old = _groceryItems[idx];
      _groceryItems[idx] = old.copyWith(isBought: !old.isBought);
      await _storage.saveGroceryItems(_groceryItems);
      notifyListeners();
    }
  }

  Future<void> addGroceryItem(GroceryItemModel item) async {
    _groceryItems.insert(0, item);
    await _storage.saveGroceryItems(_groceryItems);
    notifyListeners();
  }

  Future<void> deleteGroceryItem(String id) async {
    _groceryItems.removeWhere((g) => g.id == id);
    await _storage.saveGroceryItems(_groceryItems);
    notifyListeners();
  }

  Future<void> clearBoughtGroceries() async {
    _groceryItems.removeWhere((g) => g.isBought);
    await _storage.saveGroceryItems(_groceryItems);
    notifyListeners();
  }

  // Meal Plans Actions
  Future<void> toggleMealCooked(String id) async {
    final idx = _mealPlans.indexWhere((m) => m.id == id);
    if (idx != -1) {
      final old = _mealPlans[idx];
      _mealPlans[idx] = old.copyWith(isCooked: !old.isCooked);
      await _storage.saveMealPlans(_mealPlans);
      notifyListeners();
    }
  }

  Future<void> addMealPlan(MealPlanModel plan) async {
    _mealPlans.add(plan);
    await _storage.saveMealPlans(_mealPlans);
    notifyListeners();
  }

  // AI Assistant Actions
  Future<void> sendUserChatMessage(String query) async {
    final userMsg = AIMessageModel(
      id: _uuid.v4(),
      content: query,
      isUser: true,
      timestamp: DateTime.now(),
      type: AIMessageType.parentingAdvice,
    );
    _aiMessages.add(userMsg);
    _isAiThinking = true;
    notifyListeners();

    try {
      final advice = await AIAssistantService.getParentingAdvice(query);
      final aiMsg = AIMessageModel(
        id: _uuid.v4(),
        content: advice,
        isUser: false,
        timestamp: DateTime.now(),
        type: AIMessageType.parentingAdvice,
      );
      _aiMessages.add(aiMsg);
      await _storage.saveAIMessages(_aiMessages);
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  Future<String> generateBedtimeStory({
    required String childName,
    required String childAge,
    required String theme,
    required String moralValue,
  }) async {
    _isAiThinking = true;
    notifyListeners();

    try {
      final storyText = await AIAssistantService.generateBedtimeStory(
        childName: childName,
        childAge: childAge,
        theme: theme,
        moralValue: moralValue,
      );

      final msg = AIMessageModel(
        id: _uuid.v4(),
        title: 'قصة: $childName في $theme',
        content: storyText,
        isUser: false,
        timestamp: DateTime.now(),
        type: AIMessageType.bedtimeStory,
        metadata: {
          'childName': childName,
          'theme': theme,
          'moralValue': moralValue,
        },
      );
      _aiMessages.add(msg);
      await _storage.saveAIMessages(_aiMessages);
      return storyText;
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  Future<String> generateFridgeRecipe(List<String> ingredients) async {
    _isAiThinking = true;
    notifyListeners();

    try {
      final recipeText = await AIAssistantService.generateFridgeRecipe(ingredients: ingredients);
      final msg = AIMessageModel(
        id: _uuid.v4(),
        title: 'وصفة سريعة بالمكونات المتوفرة',
        content: recipeText,
        isUser: false,
        timestamp: DateTime.now(),
        type: AIMessageType.fridgeRecipe,
        metadata: {'ingredients': ingredients},
      );
      _aiMessages.add(msg);
      await _storage.saveAIMessages(_aiMessages);
      return recipeText;
    } finally {
      _isAiThinking = false;
      notifyListeners();
    }
  }

  Future<void> resetAllData() async {
    await _storage.clearAll();
    await init();
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/child_model.dart';
import '../../models/feeding_log_model.dart';
import '../../models/sleep_log_model.dart';
import '../../models/health_vaccine_model.dart';
import '../../models/growth_log_model.dart';
import '../../models/home_task_model.dart';
import '../../models/grocery_item_model.dart';
import '../../models/meal_plan_model.dart';
import '../../models/ai_message_model.dart';

class StorageService {
  static const String _keyChildren = 'mom_care_children';
  static const String _keyActiveChildId = 'mom_care_active_child_id';
  static const String _keyFeedingLogs = 'mom_care_feeding_logs';
  static const String _keySleepLogs = 'mom_care_sleep_logs';
  static const String _keyHealthRecords = 'mom_care_health_records';
  static const String _keyGrowthLogs = 'mom_care_growth_logs';
  static const String _keyHomeTasks = 'mom_care_home_tasks';
  static const String _keyGroceryItems = 'mom_care_grocery_items';
  static const String _keyMealPlans = 'mom_care_meal_plans';
  static const String _keyAIMessages = 'mom_care_ai_messages';
  static const String _keyThemeMode = 'mom_care_theme_mode';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  // Children
  Future<void> saveChildren(List<ChildModel> children) async {
    final list = children.map((c) => jsonEncode(c.toJson())).toList();
    await _prefs.setStringList(_keyChildren, list);
  }

  List<ChildModel>? loadChildren() {
    final list = _prefs.getStringList(_keyChildren);
    if (list == null) return null;
    return list.map((item) => ChildModel.fromJson(jsonDecode(item))).toList();
  }

  // Active Child ID
  Future<void> saveActiveChildId(String id) async {
    await _prefs.setString(_keyActiveChildId, id);
  }

  String? loadActiveChildId() {
    return _prefs.getString(_keyActiveChildId);
  }

  // Feeding Logs
  Future<void> saveFeedingLogs(List<FeedingLogModel> logs) async {
    final list = logs.map((l) => jsonEncode(l.toJson())).toList();
    await _prefs.setStringList(_keyFeedingLogs, list);
  }

  List<FeedingLogModel>? loadFeedingLogs() {
    final list = _prefs.getStringList(_keyFeedingLogs);
    if (list == null) return null;
    return list.map((item) => FeedingLogModel.fromJson(jsonDecode(item))).toList();
  }

  // Sleep Logs
  Future<void> saveSleepLogs(List<SleepLogModel> logs) async {
    final list = logs.map((l) => jsonEncode(l.toJson())).toList();
    await _prefs.setStringList(_keySleepLogs, list);
  }

  List<SleepLogModel>? loadSleepLogs() {
    final list = _prefs.getStringList(_keySleepLogs);
    if (list == null) return null;
    return list.map((item) => SleepLogModel.fromJson(jsonDecode(item))).toList();
  }

  // Health & Vaccines
  Future<void> saveHealthRecords(List<HealthVaccineModel> records) async {
    final list = records.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_keyHealthRecords, list);
  }

  List<HealthVaccineModel>? loadHealthRecords() {
    final list = _prefs.getStringList(_keyHealthRecords);
    if (list == null) return null;
    return list.map((item) => HealthVaccineModel.fromJson(jsonDecode(item))).toList();
  }

  // Growth Logs
  Future<void> saveGrowthLogs(List<GrowthLogModel> logs) async {
    final list = logs.map((l) => jsonEncode(l.toJson())).toList();
    await _prefs.setStringList(_keyGrowthLogs, list);
  }

  List<GrowthLogModel>? loadGrowthLogs() {
    final list = _prefs.getStringList(_keyGrowthLogs);
    if (list == null) return null;
    return list.map((item) => GrowthLogModel.fromJson(jsonDecode(item))).toList();
  }

  // Home Tasks
  Future<void> saveHomeTasks(List<HomeTaskModel> tasks) async {
    final list = tasks.map((t) => jsonEncode(t.toJson())).toList();
    await _prefs.setStringList(_keyHomeTasks, list);
  }

  List<HomeTaskModel>? loadHomeTasks() {
    final list = _prefs.getStringList(_keyHomeTasks);
    if (list == null) return null;
    return list.map((item) => HomeTaskModel.fromJson(jsonDecode(item))).toList();
  }

  // Groceries
  Future<void> saveGroceryItems(List<GroceryItemModel> items) async {
    final list = items.map((i) => jsonEncode(i.toJson())).toList();
    await _prefs.setStringList(_keyGroceryItems, list);
  }

  List<GroceryItemModel>? loadGroceryItems() {
    final list = _prefs.getStringList(_keyGroceryItems);
    if (list == null) return null;
    return list.map((item) => GroceryItemModel.fromJson(jsonDecode(item))).toList();
  }

  // Meal Plans
  Future<void> saveMealPlans(List<MealPlanModel> plans) async {
    final list = plans.map((p) => jsonEncode(p.toJson())).toList();
    await _prefs.setStringList(_keyMealPlans, list);
  }

  List<MealPlanModel>? loadMealPlans() {
    final list = _prefs.getStringList(_keyMealPlans);
    if (list == null) return null;
    return list.map((item) => MealPlanModel.fromJson(jsonDecode(item))).toList();
  }

  // AI Messages
  Future<void> saveAIMessages(List<AIMessageModel> messages) async {
    final list = messages.map((m) => jsonEncode(m.toJson())).toList();
    await _prefs.setStringList(_keyAIMessages, list);
  }

  List<AIMessageModel>? loadAIMessages() {
    final list = _prefs.getStringList(_keyAIMessages);
    if (list == null) return null;
    return list.map((item) => AIMessageModel.fromJson(jsonDecode(item))).toList();
  }

  // Theme Mode
  Future<void> saveIsDarkMode(bool isDark) async {
    await _prefs.setBool(_keyThemeMode, isDark);
  }

  bool loadIsDarkMode() {
    return _prefs.getBool(_keyThemeMode) ?? false;
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mom_care_ai/models/child_model.dart';
import 'package:mom_care_ai/models/feeding_log_model.dart';
import 'package:mom_care_ai/models/sleep_log_model.dart';
import 'package:mom_care_ai/models/home_task_model.dart';
import 'package:mom_care_ai/models/grocery_item_model.dart';
import 'package:mom_care_ai/core/services/ai_assistant_service.dart';

void main() {
  group('MomCare AI Models & Services Tests', () {
    test('ChildModel calculates age description correctly', () {
      final child = ChildModel(
        id: '1',
        name: 'زيد',
        birthDate: DateTime.now().subtract(const Duration(days: 180)),
        gender: 'boy',
        avatar: '👶',
      );

      expect(child.name, 'زيد');
      expect(child.gender, 'boy');
      expect(child.avatar, '👶');
      expect(child.ageInMonths, greaterThanOrEqualTo(5));
      expect(child.ageDescription.isNotEmpty, true);
    });

    test('FeedingLogModel summary formats correctly', () {
      final breastLog = FeedingLogModel(
        id: 'f1',
        childId: 'c1',
        timestamp: DateTime.now(),
        type: FeedingType.breastBoth,
        durationSeconds: 900,
      );
      expect(breastLog.summary, '15 دقيقة');

      final bottleLog = FeedingLogModel(
        id: 'f2',
        childId: 'c1',
        timestamp: DateTime.now(),
        type: FeedingType.bottleFormula,
        amountMl: 150,
      );
      expect(bottleLog.summary, '150 مل');
    });

    test('SleepLogModel calculates duration correctly', () {
      final start = DateTime(2026, 1, 1, 10, 0);
      final end = DateTime(2026, 1, 1, 11, 30);
      final sleepLog = SleepLogModel(
        id: 's1',
        childId: 'c1',
        startTime: start,
        endTime: end,
        quality: SleepQuality.peaceful,
      );

      expect(sleepLog.duration.inMinutes, 90);
      expect(sleepLog.durationFormatted, '1 س 30 د');
    });

    test('HomeTaskModel and GroceryItemModel toggle properly', () {
      final task = HomeTaskModel(
        id: 't1',
        title: 'تنظيف ألعاب الطفل',
        room: TaskRoom.kidsRoom,
      );
      expect(task.isCompleted, false);

      final completedTask = task.copyWith(isCompleted: true);
      expect(completedTask.isCompleted, true);

      final grocery = GroceryItemModel(
        id: 'g1',
        name: 'حفاضات أطفال',
        category: GroceryCategory.babySupplies,
        addedDate: DateTime.now(),
      );
      expect(grocery.isBought, false);
      final boughtGrocery = grocery.copyWith(isBought: true);
      expect(boughtGrocery.isBought, true);
    });

    test('AIAssistantService generates parenting advice and bedtime story', () async {
      final advice = await AIAssistantService.getParentingAdvice('كيف أتعامل مع نوبة غضب طفلي؟');
      expect(advice.contains('غضب'), true);

      final story = await AIAssistantService.generateBedtimeStory(
        childName: 'زيد',
        childAge: '4',
        theme: 'عالم البحار',
        moralValue: 'الصدق',
      );
      expect(story.contains('زيد'), true);
      expect(story.contains('الصدق'), true);
    });
  });
}

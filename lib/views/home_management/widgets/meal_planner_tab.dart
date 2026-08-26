import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/meal_plan_model.dart';
import '../../../state/app_state.dart';

class MealPlannerTab extends StatefulWidget {
  const MealPlannerTab({super.key});

  @override
  State<MealPlannerTab> createState() => _MealPlannerTabState();
}

class _MealPlannerTabState extends State<MealPlannerTab> {
  int _selectedDay = 0; // 0 = Sunday

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dayMeals = state.mealPlans.where((m) => m.dayOfWeek == _selectedDay).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days of Week Horizontal Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final isSelected = _selectedDay == index;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(MealPlanModel.getDayName(index)),
                    selected: isSelected,
                    selectedColor: AppColors.amberSoft,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? AppColors.amber : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (_) => setState(() => _selectedDay = index),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          // Header for selected day
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'جدول وجبات يوم ${MealPlanModel.getDayName(_selectedDay)} 🍽️',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddMealDialog(context, state),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة وجبة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (dayMeals.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  const Text('🍳', style: TextStyle(fontSize: 40)),
                  const SizedBox(height: 12),
                  Text(
                    'لم يتم تخطيط وجبات لهذا اليوم بعد 🌸\nاضغطي على "إضافة وجبة" أو استعيني بمساعد الذكاء الاصطناعي لاقتراح أفكار سريعة!',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => state.setNavIndex(3),
                    icon: const Icon(Icons.auto_awesome_rounded),
                    label: const Text('اقترحي لي وجبات بالذكاء الاصطناعي'),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dayMeals.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final meal = dayMeals[index];
                return _buildMealCard(context, meal, state, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, MealPlanModel meal, AppState state, bool isDark) {
    Color typeColor;
    Color bgColor;

    switch (meal.mealType) {
      case MealType.breakfast:
        typeColor = AppColors.amber;
        bgColor = AppColors.amberSoft;
        break;
      case MealType.lunch:
        typeColor = AppColors.primary;
        bgColor = AppColors.primarySoft;
        break;
      case MealType.dinner:
        typeColor = AppColors.secondary;
        bgColor = AppColors.secondarySoft;
        break;
      case MealType.kidsSnack:
        typeColor = AppColors.mint;
        bgColor = AppColors.mintSoft;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: meal.isCooked ? AppColors.mint.withOpacity(0.4) : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  meal.mealTypeLabel,
                  style: AppTypography.labelSmall.copyWith(color: typeColor, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    '${meal.prepTimeMinutes} دقيقة',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            meal.title,
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.bold,
              decoration: meal.isCooked ? TextDecoration.lineThrough : null,
            ),
          ),
          if (meal.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              meal.description,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
          if (meal.ingredients.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: meal.ingredients.map((ing) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Text(ing, style: AppTypography.labelSmall),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => state.toggleMealCooked(meal.id),
                icon: Icon(
                  meal.isCooked ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                  size: 18,
                  color: meal.isCooked ? AppColors.mint : Colors.grey,
                ),
                label: Text(
                  meal.isCooked ? 'تم الطهي والتقديم ✅' : 'تعليم كمنجز',
                  style: TextStyle(
                    color: meal.isCooked ? AppColors.mint : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final ingController = TextEditingController();
    MealType type = MealType.lunch;
    int prepTime = 25;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('إضافة وجبة لجدول اليوم 🍲', style: AppTypography.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<MealType>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'نوع الوجبة'),
                  items: MealType.values.map((t) {
                    return DropdownMenuItem(
                      value: t,
                      child: Text(MealPlanModel(id: '', dayOfWeek: 0, mealType: t, title: '').mealTypeLabel),
                    );
                  }).toList(),
                  onChanged: (val) => setDialogState(() => type = val ?? MealType.lunch),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'اسم الوجبة *',
                    hintText: 'مثال: صينية خضار بالفرن، كريب صحي...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'وصف الوجبة',
                    hintText: 'مثال: خفيفة وسريعة غنية بالبروتين...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ingController,
                  decoration: const InputDecoration(
                    labelText: 'المكونات (مفصولة بفواصل)',
                    hintText: 'مثال: شوفان، موز، حليب، بيض',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  final ings = ingController.text
                      .split(RegExp(r'[,،]'))
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  state.addMealPlan(MealPlanModel(
                    id: const Uuid().v4(),
                    dayOfWeek: _selectedDay,
                    mealType: type,
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    prepTimeMinutes: prepTime,
                    ingredients: ings,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ الوجبة'),
            ),
          ],
        ),
      ),
    );
  }
}

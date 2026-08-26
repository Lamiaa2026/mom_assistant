import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/feeding_log_model.dart';
import '../../../models/home_task_model.dart';
import '../../../models/grocery_item_model.dart';
import '../../../state/app_state.dart';

class QuickActionBottomSheet extends StatelessWidget {
  const QuickActionBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeChild = state.activeChild;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'تسجيل وإجراء سريع ⚡',
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (activeChild != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeChild.avatar} ${activeChild.name}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            children: [
              _buildActionButton(
                context,
                title: 'سجل رضاعة طبيعية',
                subtitle: '15 دقيقة فورية',
                icon: Icons.child_care_rounded,
                color: AppColors.primary,
                bgColor: AppColors.primarySoft,
                onTap: () {
                  Navigator.pop(context);
                  _quickLogBreastfeeding(context, state);
                },
              ),
              _buildActionButton(
                context,
                title: 'ببرونة حليب 120مل',
                subtitle: 'تسجيل نقرة واحدة',
                icon: Icons.local_drink_rounded,
                color: AppColors.skyBlue,
                bgColor: AppColors.skyBlueSoft,
                onTap: () {
                  Navigator.pop(context);
                  _quickLogBottle(context, state);
                },
              ),
              _buildActionButton(
                context,
                title: 'إضافة غرض للمقاضي',
                subtitle: 'تسوق البيت',
                icon: Icons.shopping_basket_rounded,
                color: AppColors.mint,
                bgColor: AppColors.mintSoft,
                onTap: () {
                  Navigator.pop(context);
                  _showAddGroceryDialog(context, state);
                },
              ),
              _buildActionButton(
                context,
                title: 'مهمة تنظيف سريعة',
                subtitle: '10 دقائق',
                icon: Icons.cleaning_services_rounded,
                color: AppColors.amber,
                bgColor: AppColors.amberSoft,
                onTap: () {
                  Navigator.pop(context);
                  _showAddTaskDialog(context, state);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _quickLogBreastfeeding(BuildContext context, AppState state) {
    if (state.activeChild == null) return;
    state.addFeedingLog(FeedingLogModel(
      id: const Uuid().v4(),
      childId: state.activeChild!.id,
      timestamp: DateTime.now(),
      type: FeedingType.breastBoth,
      durationSeconds: 15 * 60,
      notes: 'تسجيل سريع من الصفحة الرئيسية',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل الرضاعة الطبيعية بنجاح 🌸'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _quickLogBottle(BuildContext context, AppState state) {
    if (state.activeChild == null) return;
    state.addFeedingLog(FeedingLogModel(
      id: const Uuid().v4(),
      childId: state.activeChild!.id,
      timestamp: DateTime.now(),
      type: FeedingType.bottleFormula,
      amountMl: 120,
      notes: 'تسجيل سريع للرضعة 🍼',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل رضعة الحليب 120 مل 🍼'),
        backgroundColor: AppColors.skyBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showAddGroceryDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة غرض للمقاضي 🛒', style: AppTypography.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'مثال: حفاضات، حليب، خضار...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.addGroceryItem(GroceryItemModel(
                  id: const Uuid().v4(),
                  name: controller.text.trim(),
                  category: GroceryCategory.babySupplies,
                  addedDate: DateTime.now(),
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت الإضافة لقائمة المقاضي! ✨')),
                );
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AppState state) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('إضافة مهمة منزلية سريعة 🧹', style: AppTypography.titleMedium),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'مثال: تعقيم الألعاب، تشغيل الغسالة...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                state.addHomeTask(HomeTaskModel(
                  id: const Uuid().v4(),
                  title: controller.text.trim(),
                  room: TaskRoom.general,
                  frequency: TaskFrequency.daily,
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تمت إضافة المهمة لجدول البيت! 🏡')),
                );
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}

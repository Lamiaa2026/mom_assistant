import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/growth_log_model.dart';
import '../../../state/app_state.dart';

class GrowthMilestonesTab extends StatelessWidget {
  const GrowthMilestonesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final child = state.activeChild;
    final logs = state.growthLogsForActiveChild;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Growth Stats Row
          Row(
            children: [
              Expanded(
                child: _buildMetricBox(
                  context,
                  title: 'الوزن الحالي',
                  value: child?.currentWeightKg != null ? '${child!.currentWeightKg} كجم' : '--',
                  icon: Icons.scale_rounded,
                  color: AppColors.primary,
                  bgColor: AppColors.primarySoft,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricBox(
                  context,
                  title: 'الطول الحالي',
                  value: child?.currentHeightCm != null ? '${child!.currentHeightCm} سم' : '--',
                  icon: Icons.height_rounded,
                  color: AppColors.skyBlue,
                  bgColor: AppColors.skyBlueSoft,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Title & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل قياسات النمو والذكريات 📈✨',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddGrowthDialog(context, state),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('تسجيل قياس'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          if (logs.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'لا توجد سجلات نمو مسجلة بعد، اضغطي على تسجيل قياس لإضافة وزن وطول الطفل 👶',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: logs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final log = logs[logs.length - 1 - index]; // newest first
                return _buildGrowthCard(context, log, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildMetricBox(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(BuildContext context, GrowthLogModel log, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('yyyy/MM/dd', 'ar').format(log.date),
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (log.milestoneNote != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.amberSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    log.milestoneNote!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMetricPill('الوزن', '${log.weightKg} كجم', AppColors.primary),
              const SizedBox(width: 12),
              _buildMetricPill('الطول', '${log.heightCm} سم', AppColors.skyBlue),
              if (log.headCircumferenceCm != null) ...[
                const SizedBox(width: 12),
                _buildMetricPill('محيط الرأس', '${log.headCircumferenceCm} سم', AppColors.mint),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: AppTypography.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          Text(value, style: AppTypography.bodySmall.copyWith(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showAddGrowthDialog(BuildContext context, AppState state) {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headController = TextEditingController();
    final milestoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('تسجيل قياس نمو جديد 📏', style: AppTypography.titleMedium),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'الوزن بالكيلوجرام (كجم) *',
                  hintText: 'مثال: 8.2',
                  prefixIcon: Icon(Icons.scale_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: heightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'الطول بالسنتيمتر (سم) *',
                  hintText: 'مثال: 70.5',
                  prefixIcon: Icon(Icons.height_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: headController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'محيط الرأس (سم)',
                  hintText: 'مثال: 44.0',
                  prefixIcon: Icon(Icons.circle_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: milestoneController,
                decoration: const InputDecoration(
                  labelText: 'ذكرى أو إنجاز جديد (اختياري)',
                  hintText: 'مثال: أول خطوة، أول كلمة ماما...',
                  prefixIcon: Icon(Icons.star_outline_rounded),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text.trim());
              final height = double.tryParse(heightController.text.trim());
              final head = double.tryParse(headController.text.trim());

              if (weight != null && height != null && state.activeChild != null) {
                state.addGrowthLog(GrowthLogModel(
                  id: const Uuid().v4(),
                  childId: state.activeChild!.id,
                  date: DateTime.now(),
                  weightKg: weight,
                  heightCm: height,
                  headCircumferenceCm: head,
                  milestoneNote: milestoneController.text.trim().isEmpty ? null : milestoneController.text.trim(),
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

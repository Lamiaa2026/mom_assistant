import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/health_vaccine_model.dart';
import '../../../state/app_state.dart';

class HealthVaccineTab extends StatefulWidget {
  const HealthVaccineTab({super.key});

  @override
  State<HealthVaccineTab> createState() => _HealthVaccineTabState();
}

class _HealthVaccineTabState extends State<HealthVaccineTab> {
  int _selectedFilter = 0; // 0 = الكل, 1 = التطعيمات, 2 = الأدوية والفيتامينات

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allRecords = state.healthRecordsForActiveChild;

    List<HealthVaccineModel> filteredRecords;
    if (_selectedFilter == 1) {
      filteredRecords = allRecords.where((r) => r.type == HealthRecordType.vaccine).toList();
    } else if (_selectedFilter == 2) {
      filteredRecords = allRecords.where((r) => r.type == HealthRecordType.medicine).toList();
    } else {
      filteredRecords = allRecords;
    }

    final completedCount = allRecords.where((r) => r.isCompleted).length;
    final totalCount = allRecords.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Progress Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.nightGradient : AppColors.mintGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withOpacity(0.2),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سجل التطعيمات والصحة 🩺',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'تم إنجاز $completedCount من أصل $totalCount تطعيم وجرعة',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${totalCount > 0 ? ((completedCount / totalCount) * 100).toInt() : 0}%',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.mint,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Filters & Add Button
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(label: 'الكل ($totalCount)', index: 0),
                      const SizedBox(width: 8),
                      _buildFilterChip(label: 'التطعيمات 💉', index: 1),
                      const SizedBox(width: 8),
                      _buildFilterChip(label: 'الأدوية 💊', index: 2),
                    ],
                  ),
                ),
              ),
              IconButton.filled(
                onPressed: () => _showAddRecordDialog(context, state),
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(backgroundColor: AppColors.mint),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (filteredRecords.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'لا توجد سجلات مطابقة، يمكنك إضافة تطعيم أو دواء جديد 🌸',
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
              itemCount: filteredRecords.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final record = filteredRecords[index];
                return _buildRecordTile(context, record, state, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required int index}) {
    final isSelected = _selectedFilter == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.mintSoft,
      labelStyle: AppTypography.labelSmall.copyWith(
        color: isSelected ? AppColors.mint : AppColors.textSecondaryLight,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => setState(() => _selectedFilter = index),
    );
  }

  Widget _buildRecordTile(BuildContext context, HealthVaccineModel record, AppState state, bool isDark) {
    final isVaccine = record.type == HealthRecordType.vaccine;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: record.isCompleted ? AppColors.mint.withOpacity(0.4) : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: record.isCompleted ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion Checkbox Button
          InkWell(
            onTap: () => state.toggleHealthRecordCompletion(record.id),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: record.isCompleted ? AppColors.mint : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: record.isCompleted ? AppColors.mint : AppColors.textMutedLight,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 18,
                color: record.isCompleted ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        record.title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: record.isCompleted ? TextDecoration.lineThrough : null,
                          color: record.isCompleted
                              ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                        ),
                      ),
                    ),
                    if (record.ageBadge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isVaccine ? AppColors.mintSoft : AppColors.amberSoft,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          record.ageBadge,
                          style: AppTypography.labelSmall.copyWith(
                            color: isVaccine ? AppColors.mint : AppColors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  record.description,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                if (record.dosage != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.medication_rounded, size: 14, color: AppColors.amber),
                      const SizedBox(width: 4),
                      Text(
                        'الجرعة: ${record.dosage!}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                if (record.isCompleted && record.completedDate != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'تم في: ${DateFormat('yyyy/MM/dd', 'ar').format(record.completedDate!)} ✅',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mint,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddRecordDialog(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final dosageController = TextEditingController();
    HealthRecordType type = HealthRecordType.vaccine;
    int ageMonths = 6;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('إضافة تطعيم أو دواء جديد 💉', style: AppTypography.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('تطعيم 💉')),
                        selected: type == HealthRecordType.vaccine,
                        onSelected: (_) => setDialogState(() => type = HealthRecordType.vaccine),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Center(child: Text('دواء / فيتامين 💊')),
                        selected: type == HealthRecordType.medicine,
                        onSelected: (_) => setDialogState(() => type = HealthRecordType.medicine),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'اسم التطعيم أو الدواء *',
                    hintText: 'مثال: تطعيم 9 أشهر، فيتامين د...',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'الوصف أو الملاحظات',
                    hintText: 'تفاصيل الموعد أو المركز الصحي...',
                  ),
                ),
                if (type == HealthRecordType.medicine) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(
                      labelText: 'الجرعة والمواعيد',
                      hintText: 'مثال: 5 مل مرتين يومياً بعد الأكل...',
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty && state.activeChild != null) {
                  state.addHealthRecord(HealthVaccineModel(
                    id: const Uuid().v4(),
                    childId: state.activeChild!.id,
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    type: type,
                    scheduledAgeMonths: ageMonths,
                    dosage: dosageController.text.trim().isEmpty ? null : dosageController.text.trim(),
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/home_task_model.dart';
import '../../../state/app_state.dart';

class CleaningScheduleTab extends StatefulWidget {
  const CleaningScheduleTab({super.key});

  @override
  State<CleaningScheduleTab> createState() => _CleaningScheduleTabState();
}

class _CleaningScheduleTabState extends State<CleaningScheduleTab> {
  TaskRoom? _selectedRoom;
  TaskFrequency _selectedFrequency = TaskFrequency.daily;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var tasks = state.homeTasks.where((t) => t.frequency == _selectedFrequency).toList();
    if (_selectedRoom != null) {
      tasks = tasks.where((t) => t.room == _selectedRoom).toList();
    }

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Progress Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.nightGradient : AppColors.warmCardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'إنجاز مهام وتنظيف البيت 🧹',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '$completedCount / $totalCount منجز',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Frequency Switcher (يومي / أسبوعي / شهري)
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('مهام يومية ☀️')),
                  selected: _selectedFrequency == TaskFrequency.daily,
                  selectedColor: AppColors.primarySoft,
                  onSelected: (_) => setState(() => _selectedFrequency = TaskFrequency.daily),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('مهام أسبوعية 📅')),
                  selected: _selectedFrequency == TaskFrequency.weekly,
                  selectedColor: AppColors.primarySoft,
                  onSelected: (_) => setState(() => _selectedFrequency = TaskFrequency.weekly),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Room Filter Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('كل الغرف 🏠'),
                  selected: _selectedRoom == null,
                  onSelected: (_) => setState(() => _selectedRoom = null),
                ),
                const SizedBox(width: 8),
                ...TaskRoom.values.where((r) => r != TaskRoom.general).map((room) {
                  final isSelected = _selectedRoom == room;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(HomeTaskModel(id: '', title: '', room: room).roomLabel),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedRoom = isSelected ? null : room),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Tasks List Header & Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'قائمة المهام (${tasks.length})',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddTaskDialog(context, state),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('إضافة مهمة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (tasks.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'لا توجد مهام متبقية في هذا القسم، عمل رائع يا ماما! 🌸',
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
              itemCount: tasks.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskTile(context, task, state, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, HomeTaskModel task, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.isCompleted ? AppColors.mint.withOpacity(0.4) : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () => state.toggleHomeTask(task.id),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.mint : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? AppColors.mint : AppColors.textMutedLight,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: task.isCompleted ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    color: task.isCompleted
                        ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      task.roomLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('•', style: AppTypography.bodySmall),
                    const SizedBox(width: 8),
                    Text(
                      '~ ${task.estimatedMinutes} دقيقة',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
            onPressed: () => state.deleteHomeTask(task.id),
          ),
        ],
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context, AppState state) {
    final titleController = TextEditingController();
    TaskRoom room = _selectedRoom ?? TaskRoom.kitchen;
    TaskFrequency freq = _selectedFrequency;
    int estMinutes = 15;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('إضافة مهمة منزلية جديدة 🧹', style: AppTypography.titleMedium),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'اسم المهمة *',
                    hintText: 'مثال: مسح الأرضيات، ترتيب الألعاب...',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TaskRoom>(
                  value: room,
                  decoration: const InputDecoration(labelText: 'الغرفة / القسم'),
                  items: TaskRoom.values
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(HomeTaskModel(id: '', title: '', room: r).roomLabel),
                          ))
                      .toList(),
                  onChanged: (val) => setDialogState(() => room = val ?? TaskRoom.general),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TaskFrequency>(
                  value: freq,
                  decoration: const InputDecoration(labelText: 'التكرار'),
                  items: TaskFrequency.values
                      .map((f) => DropdownMenuItem(
                            value: f,
                            child: Text(HomeTaskModel(id: '', title: '', frequency: f).frequencyLabel),
                          ))
                      .toList(),
                  onChanged: (val) => setDialogState(() => freq = val ?? TaskFrequency.daily),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  state.addHomeTask(HomeTaskModel(
                    id: const Uuid().v4(),
                    title: titleController.text.trim(),
                    room: room,
                    frequency: freq,
                    estimatedMinutes: estMinutes,
                  ));
                  Navigator.pop(ctx);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        ),
      ),
    );
  }
}

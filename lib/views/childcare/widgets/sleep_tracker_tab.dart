import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/sleep_log_model.dart';
import '../../../state/app_state.dart';

class SleepTrackerTab extends StatefulWidget {
  const SleepTrackerTab({super.key});

  @override
  State<SleepTrackerTab> createState() => _SleepTrackerTabState();
}

class _SleepTrackerTabState extends State<SleepTrackerTab> {
  DateTime? _napStartTime;
  Timer? _timer;
  int _elapsedSeconds = 0;

  void _startNap() {
    setState(() {
      _napStartTime = DateTime.now();
      _elapsedSeconds = 0;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds = DateTime.now().difference(_napStartTime!).inSeconds;
      });
    });
  }

  void _endNapAndSave(AppState state) {
    if (_napStartTime == null || state.activeChild == null) return;

    final endTime = DateTime.now();
    _timer?.cancel();

    state.addSleepLog(SleepLogModel(
      id: const Uuid().v4(),
      childId: state.activeChild!.id,
      startTime: _napStartTime!,
      endTime: endTime,
      quality: SleepQuality.peaceful,
      isNap: true,
      notes: 'غفوة مسجلة بالمؤقت المباشر 😴',
    ));

    setState(() {
      _napStartTime = null;
      _elapsedSeconds = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('نوم الهناء! تم حفظ الغفوة بنجاح 🌙'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatElapsed(int sec) {
    final h = (sec / 3600).floor().toString().padLeft(2, '0');
    final m = ((sec % 3600) / 60).floor().toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logs = state.sleepLogsForActiveChild;
    final isSleeping = _napStartTime != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Nap Timer Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.nightGradient : AppColors.lavenderGradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bedtime_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      isSleeping ? 'الطفل نائم الآن 💤' : 'مؤقت نوم وغفوة الطفل 🌙',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  isSleeping ? _formatElapsed(_elapsedSeconds) : '00:00:00',
                  style: AppTypography.displayLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 20),
                if (!isSleeping)
                  ElevatedButton.icon(
                    onPressed: _startNap,
                    icon: const Icon(Icons.play_arrow_rounded, size: 22),
                    label: const Text('بدء الغفوة الآن 😴'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: () => _endNapAndSave(state),
                    icon: const Icon(Icons.wb_sunny_rounded, size: 22),
                    label: const Text('استيقظ الطفل (حفظ الغفوة) ☀️'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.amber,
                      foregroundColor: AppColors.textPrimaryLight,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Manual Add Button & Today's Summary
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إجمالي نوم اليوم', style: AppTypography.labelSmall.copyWith(color: AppColors.secondary)),
                      const SizedBox(height: 4),
                      Text(
                        '${(state.todaySleepTotalMinutes / 60).toStringAsFixed(1)} ساعة',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _showManualSleepDialog(context, state),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('تسجيل يدوي'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Sleep History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل أوقات النوم والغفوات 🛌',
                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${logs.length} سجلات',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (logs.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'لا توجد سجلات نوم بعد، ابدئي بتشغيل المؤقت عند نوم الطفل 😴',
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final log = logs[index];
                return _buildSleepTile(context, log, state, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSleepTile(BuildContext context, SleepLogModel log, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              log.isNap ? Icons.wb_twilight_rounded : Icons.bedtime_rounded,
              color: AppColors.secondary,
              size: 20,
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
                    Text(
                      log.isNap ? 'غفوة نهارية' : 'نوم ليلي',
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('dd/MM - hh:mm a', 'ar').format(log.startTime),
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'المدة: ${log.durationFormatted}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      log.qualityLabel,
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                if (log.notes != null && log.notes!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    log.notes!,
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
            onPressed: () => state.deleteSleepLog(log.id),
          ),
        ],
      ),
    );
  }

  void _showManualSleepDialog(BuildContext context, AppState state) {
    int durationMinutes = 90;
    bool isNap = true;
    SleepQuality quality = SleepQuality.peaceful;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تسجيل نوم يدوي 🛌', style: AppTypography.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('غفوة نهارية')),
                      selected: isNap,
                      onSelected: (val) => setDialogState(() => isNap = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('نوم ليلي')),
                      selected: !isNap,
                      onSelected: (val) => setDialogState(() => isNap = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'مدة النوم: ${(durationMinutes / 60).toStringAsFixed(1)} ساعة ($durationMinutes دقيقة)',
                style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              Slider(
                value: durationMinutes.toDouble(),
                min: 15,
                max: 720,
                divisions: 47,
                activeColor: AppColors.secondary,
                onChanged: (val) => setDialogState(() => durationMinutes = val.round()),
              ),
              const SizedBox(height: 8),
              Text('جودة النوم:', style: AppTypography.labelSmall),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ChoiceChip(
                    label: const Text('هادئ 😴'),
                    selected: quality == SleepQuality.peaceful,
                    onSelected: (_) => setDialogState(() => quality = SleepQuality.peaceful),
                  ),
                  ChoiceChip(
                    label: const Text('عادي 😌'),
                    selected: quality == SleepQuality.normal,
                    onSelected: (_) => setDialogState(() => quality = SleepQuality.normal),
                  ),
                  ChoiceChip(
                    label: const Text('متقطع 🥺'),
                    selected: quality == SleepQuality.restless,
                    onSelected: (_) => setDialogState(() => quality = SleepQuality.restless),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (state.activeChild != null) {
                  final start = DateTime.now().subtract(Duration(minutes: durationMinutes));
                  state.addSleepLog(SleepLogModel(
                    id: const Uuid().v4(),
                    childId: state.activeChild!.id,
                    startTime: start,
                    endTime: DateTime.now(),
                    quality: quality,
                    isNap: isNap,
                    notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                  ));
                }
                Navigator.pop(ctx);
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

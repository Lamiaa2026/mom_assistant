import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/feeding_log_model.dart';
import '../../../state/app_state.dart';

class FeedingTrackerTab extends StatefulWidget {
  const FeedingTrackerTab({super.key});

  @override
  State<FeedingTrackerTab> createState() => _FeedingTrackerTabState();
}

class _FeedingTrackerTabState extends State<FeedingTrackerTab> {
  // Live Timer State
  Timer? _timer;
  int _secondsLeft = 0;
  int _secondsRight = 0;
  bool _isTimingLeft = false;
  bool _isTimingRight = false;

  void _startTimer(bool isLeft) {
    _timer?.cancel();
    setState(() {
      if (isLeft) {
        _isTimingLeft = true;
        _isTimingRight = false;
      } else {
        _isTimingRight = true;
        _isTimingLeft = false;
      }
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_isTimingLeft) _secondsLeft++;
        if (_isTimingRight) _secondsRight++;
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isTimingLeft = false;
      _isTimingRight = false;
    });
  }

  void _saveBreastfeedingLog(AppState state) {
    final child = state.activeChild;
    if (child == null) return;

    final totalSeconds = _secondsLeft + _secondsRight;
    if (totalSeconds == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تشغيل المؤقت أولاً')),
      );
      return;
    }

    FeedingType type;
    if (_secondsLeft > 0 && _secondsRight > 0) {
      type = FeedingType.breastBoth;
    } else if (_secondsLeft > 0) {
      type = FeedingType.breastLeft;
    } else {
      type = FeedingType.breastRight;
    }

    final notes = 'يسار: ${_formatSeconds(_secondsLeft)} | يمين: ${_formatSeconds(_secondsRight)}';

    state.addFeedingLog(FeedingLogModel(
      id: const Uuid().v4(),
      childId: child.id,
      timestamp: DateTime.now(),
      type: type,
      durationSeconds: totalSeconds,
      notes: notes,
    ));

    _pauseTimer();
    setState(() {
      _secondsLeft = 0;
      _secondsRight = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ جلسة الرضاعة الطبيعية بنجاح 🌸'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _formatSeconds(int sec) {
    final m = (sec / 60).floor().toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final logs = state.feedingLogsForActiveChild;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breastfeeding Live Timer Box
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'مؤقت الرضاعة الطبيعية المباشر ⏱️',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Left & Right timer displays
                Row(
                  children: [
                    // Left Breast
                    Expanded(
                      child: _buildSideTimerCard(
                        context,
                        title: 'الثدي الأيسر',
                        timeStr: _formatSeconds(_secondsLeft),
                        isActive: _isTimingLeft,
                        onTap: () {
                          if (_isTimingLeft) {
                            _pauseTimer();
                          } else {
                            _startTimer(true);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Right Breast
                    Expanded(
                      child: _buildSideTimerCard(
                        context,
                        title: 'الثدي الأيمن',
                        timeStr: _formatSeconds(_secondsRight),
                        isActive: _isTimingRight,
                        onTap: () {
                          if (_isTimingRight) {
                            _pauseTimer();
                          } else {
                            _startTimer(false);
                          }
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Timer Action Buttons
                Row(
                  children: [
                    if (_isTimingLeft || _isTimingRight)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _pauseTimer,
                          icon: const Icon(Icons.pause_rounded),
                          label: const Text('إيقاف مؤقت'),
                        ),
                      ),
                    if (_isTimingLeft || _isTimingRight) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _saveBreastfeedingLog(state),
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('حفظ الجلسة'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Other Log Buttons (Bottle & Solid)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showBottleDialog(context, state),
                  icon: const Icon(Icons.local_drink_rounded, size: 18),
                  label: const Text('تسجيل ببرونة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.skyBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSolidFoodDialog(context, state),
                  icon: const Icon(Icons.restaurant_rounded, size: 18),
                  label: const Text('وجبة طعام صلب'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mint,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Feeding History Log Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل الرضعات والوجبات 📋',
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
                'لا توجد سجلات تغذية بعد، ابدئي بتشغيل المؤقت أو تسجيل رضعة 🍼',
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
                return _buildLogTile(context, log, state, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSideTimerCard(
    BuildContext context, {
    required String title,
    required String timeStr,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySoft : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.borderLight,
            width: isActive ? 2 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                color: isActive ? AppColors.primaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              timeStr,
              style: AppTypography.displayMedium.copyWith(
                color: isActive ? AppColors.primary : AppColors.textPrimaryLight,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                  color: isActive ? AppColors.primary : AppColors.textMutedLight,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  isActive ? 'جارِ الرضاعة...' : 'اضغطي للبدء',
                  style: AppTypography.labelSmall.copyWith(
                    color: isActive ? AppColors.primary : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogTile(BuildContext context, FeedingLogModel log, AppState state, bool isDark) {
    IconData icon;
    Color color;
    Color bgColor;

    switch (log.type) {
      case FeedingType.breastLeft:
      case FeedingType.breastRight:
      case FeedingType.breastBoth:
        icon = Icons.child_care_rounded;
        color = AppColors.primary;
        bgColor = AppColors.primarySoft;
        break;
      case FeedingType.bottleFormula:
      case FeedingType.bottleBreastMilk:
        icon = Icons.local_drink_rounded;
        color = AppColors.skyBlue;
        bgColor = AppColors.skyBlueSoft;
        break;
      case FeedingType.solidFood:
        icon = Icons.restaurant_rounded;
        color = AppColors.mint;
        bgColor = AppColors.mintSoft;
        break;
    }

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
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 20),
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
                      log.typeLabel,
                      style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('hh:mm a', 'ar').format(log.timestamp),
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'الكمية / المدة: ${log.summary}',
                  style: AppTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
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
            onPressed: () => state.deleteFeedingLog(log.id),
          ),
        ],
      ),
    );
  }

  void _showBottleDialog(BuildContext context, AppState state) {
    int amount = 120;
    bool isFormula = true;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text('تسجيل ببرونة حليب 🍼', style: AppTypography.titleMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('حليب صناعي')),
                      selected: isFormula,
                      selectedColor: AppColors.skyBlueSoft,
                      onSelected: (val) => setDialogState(() => isFormula = true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('حليب مسحوب')),
                      selected: !isFormula,
                      selectedColor: AppColors.primarySoft,
                      onSelected: (val) => setDialogState(() => isFormula = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('الكمية: $amount مل', style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              Slider(
                value: amount.toDouble(),
                min: 30,
                max: 300,
                divisions: 27,
                activeColor: AppColors.skyBlue,
                onChanged: (val) => setDialogState(() => amount = val.round()),
              ),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  hintText: 'مثال: شربها بسرعة...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (state.activeChild != null) {
                  state.addFeedingLog(FeedingLogModel(
                    id: const Uuid().v4(),
                    childId: state.activeChild!.id,
                    timestamp: DateTime.now(),
                    type: isFormula ? FeedingType.bottleFormula : FeedingType.bottleBreastMilk,
                    amountMl: amount,
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

  void _showSolidFoodDialog(BuildContext context, AppState state) {
    final foodController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('تسجيل وجبة طعام صلب 🥕', style: AppTypography.titleMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: foodController,
              decoration: const InputDecoration(
                labelText: 'مكونات الوجبة *',
                hintText: 'مثال: مهروس تفاح وشوفان، كوسة وجزر...',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'تفاعل الطفل والشهية',
                hintText: 'مثال: أكل الطبق كله، أحب الطعم...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (foodController.text.trim().isNotEmpty && state.activeChild != null) {
                state.addFeedingLog(FeedingLogModel(
                  id: const Uuid().v4(),
                  childId: state.activeChild!.id,
                  timestamp: DateTime.now(),
                  type: FeedingType.solidFood,
                  solidFoodDetails: foodController.text.trim(),
                  notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
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

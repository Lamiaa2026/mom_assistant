import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';
import 'widgets/quick_metric_card.dart';
import 'widgets/quick_action_bottom_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeChild = state.activeChild;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header Sliver
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.nightGradient : AppColors.warmCardGradient,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Greeting & Notification/Settings Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Text('🌸', style: TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'صباح الخير يا ماما 💖',
                                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                DateFormat('EEEE، d MMMM', 'ar').format(DateTime.now()),
                                style: AppTypography.bodySmall.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () => state.toggleDarkMode(),
                        icon: Icon(
                          isDark ? Icons.wb_sunny_rounded : Icons.nightlight_round,
                          color: isDark ? AppColors.amber : AppColors.secondary,
                        ),
                        tooltip: isDark ? 'الوضع النهاري' : 'الوضع الليلي للرضاعة',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Active Child Pill & Switcher
                  if (state.children.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: state.children.map((child) {
                          final isSelected = child.id == activeChild?.id;
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: FilterChip(
                              selected: isSelected,
                              label: Text('${child.avatar} ${child.name} (${child.ageDescription})'),
                              labelStyle: AppTypography.labelSmall.copyWith(
                                color: isSelected ? Colors.white : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              backgroundColor: isDark ? AppColors.cardDark : Colors.white,
                              selectedColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
                                ),
                              ),
                              onSelected: (_) => state.setActiveChild(child.id),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Content Sliver
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Mom Daily Affirmation Card
                _buildDailyAffirmation(context, isDark),

                const SizedBox(height: 24),

                // Section Title: Overview
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'نظرة سريعة على اليوم 📊',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (_) => const QuickActionBottomSheet(),
                        );
                      },
                      icon: const Icon(Icons.flash_on_rounded, size: 16, color: AppColors.primary),
                      label: Text(
                        'تسجيل سريع',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // 4 Grid Metric Cards
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.15,
                  children: [
                    // Feeding Metric
                    QuickMetricCard(
                      title: 'آخر رضاعة',
                      value: state.lastFeedingLog != null ? state.lastFeedingLog!.summary : 'لا يوجد سجل',
                      subtitle: state.lastFeedingLog != null
                          ? '${state.lastFeedingLog!.typeShortLabel} • ${_formatTimeAgo(state.lastFeedingLog!.timestamp)}'
                          : 'اضغطي للتسجيل',
                      icon: Icons.child_care_rounded,
                      iconColor: AppColors.primary,
                      backgroundColor: AppColors.primarySoft,
                      onTap: () => state.setNavIndex(1),
                    ),

                    // Sleep Metric
                    QuickMetricCard(
                      title: 'نوم الطفل اليوم',
                      value: '${(state.todaySleepTotalMinutes / 60).toStringAsFixed(1)} س',
                      subtitle: state.lastSleepLog != null
                          ? 'آخر غفوة: ${state.lastSleepLog!.durationFormatted}'
                          : 'تسجيل وقت النوم',
                      icon: Icons.bedtime_rounded,
                      iconColor: AppColors.secondary,
                      backgroundColor: AppColors.secondarySoft,
                      onTap: () => state.setNavIndex(1),
                    ),

                    // Chores Metric
                    QuickMetricCard(
                      title: 'مهام البيت',
                      value: '${state.completedTasksCount} من ${state.totalTasksCount}',
                      subtitle: '${(state.taskProgress * 100).toInt()}% نسبة الإنجاز اليوم',
                      icon: Icons.cleaning_services_rounded,
                      iconColor: AppColors.mint,
                      backgroundColor: AppColors.mintSoft,
                      onTap: () => state.setNavIndex(2),
                    ),

                    // Next Vaccine / Med Metric
                    QuickMetricCard(
                      title: 'الموعد القادم',
                      value: state.nextUpcomingVaccine != null ? state.nextUpcomingVaccine!.ageBadge : 'مكتمل ✅',
                      subtitle: state.nextUpcomingVaccine != null ? state.nextUpcomingVaccine!.title : 'صحة طفلك ممتازة',
                      icon: Icons.vaccines_rounded,
                      iconColor: AppColors.amber,
                      backgroundColor: AppColors.amberSoft,
                      onTap: () => state.setNavIndex(1),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // AI Assistant Teaser Banner
                _buildAITeaserCard(context, state, isDark),

                const SizedBox(height: 28),

                // Timeline of Today's Activities
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'سجل نشاطات اليوم ⏱️',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'محدّث تلقائياً',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildRecentActivitiesList(context, state, isDark),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyAffirmation(BuildContext context, bool isDark) {
    final affirmation = AppConstants.dailyMomAffirmations.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.favorite_rounded, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'همسة اليوم لكِ 💖',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  affirmation,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITeaserCard(BuildContext context, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.lavenderGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المساعد الذكي للأم 🤖✨',
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'استشارات تربوية، قصص نوم مخصصة، ووصفات سريعة',
                      style: AppTypography.bodySmall.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => state.setNavIndex(3),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('اسألي المستشار الذكي'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesList(BuildContext context, AppState state, bool isDark) {
    final feedings = state.feedingLogsForActiveChild.take(3).toList();
    final tasks = state.homeTasks.where((t) => t.isCompleted).take(2).toList();

    if (feedings.isEmpty && tasks.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        child: Text(
          'لا توجد نشاطات مسجلة اليوم بعد 🌸',
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      );
    }

    return Column(
      children: [
        ...feedings.map((log) => _buildActivityTile(
              context,
              icon: Icons.child_care_rounded,
              color: AppColors.primary,
              bgColor: AppColors.primarySoft,
              title: log.typeLabel,
              subtitle: log.summary,
              time: DateFormat('hh:mm a', 'ar').format(log.timestamp),
              isDark: isDark,
            )),
        ...tasks.map((task) => _buildActivityTile(
              context,
              icon: Icons.check_circle_rounded,
              color: AppColors.mint,
              bgColor: AppColors.mintSoft,
              title: 'تم إنجاز: ${task.title}',
              subtitle: task.roomLabel,
              time: task.completedAt != null ? DateFormat('hh:mm a', 'ar').format(task.completedAt!) : 'اليوم',
              isDark: isDark,
            )),
      ],
    );
  }

  Widget _buildActivityTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String time,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
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
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة';
    } else if (diff.inHours < 24) {
      return 'منذ ${diff.inHours} ساعة';
    } else {
      return DateFormat('dd/MM', 'ar').format(dt);
    }
  }
}

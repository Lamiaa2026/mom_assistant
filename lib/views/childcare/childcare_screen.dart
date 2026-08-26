import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../state/app_state.dart';
import 'widgets/feeding_tracker_tab.dart';
import 'widgets/sleep_tracker_tab.dart';
import 'widgets/health_vaccine_tab.dart';
import 'widgets/growth_milestones_tab.dart';
import 'widgets/add_child_dialog.dart';

class ChildcareScreen extends StatefulWidget {
  const ChildcareScreen({super.key});

  @override
  State<ChildcareScreen> createState() => _ChildcareScreenState();
}

class _ChildcareScreenState extends State<ChildcareScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeChild = state.activeChild;

    return Scaffold(
      appBar: AppBar(
        title: Text('رعاية الأطفال 👶', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            tooltip: 'إضافة طفل جديد',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const AddChildDialog(),
              );
            },
          ),
          if (activeChild != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: AppColors.textMutedLight),
              tooltip: 'تعديل بيانات الطفل الحالي',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddChildDialog(childToEdit: activeChild),
                );
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(105),
          child: Column(
            children: [
              // Child Profile Bar
              if (activeChild != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          shape: BoxShape.circle,
                        ),
                        child: Text(activeChild.avatar, style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeChild.name,
                            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            activeChild.ageDescription,
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (activeChild.bloodType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primarySoft,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'فصيلة: ${activeChild.bloodType!}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // TabBar
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: AppColors.primary,
                unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'الرضاعة والتغذية 🍼'),
                  Tab(text: 'سجل النوم 🌙'),
                  Tab(text: 'الصحة والتطعيمات 💉'),
                  Tab(text: 'النمو والمعالم 📈'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FeedingTrackerTab(),
          SleepTrackerTab(),
          HealthVaccineTab(),
          GrowthMilestonesTab(),
        ],
      ),
    );
  }
}

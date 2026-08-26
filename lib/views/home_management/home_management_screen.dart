import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/cleaning_schedule_tab.dart';
import 'widgets/smart_grocery_tab.dart';
import 'widgets/meal_planner_tab.dart';

class HomeManagementScreen extends StatefulWidget {
  const HomeManagementScreen({super.key});

  @override
  State<HomeManagementScreen> createState() => _HomeManagementScreenState();
}

class _HomeManagementScreenState extends State<HomeManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة وتنظيم البيت 🏡', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'مهام وتنظيف البيت 🧹'),
            Tab(text: 'المقاضي والتسوق 🛒'),
            Tab(text: 'جدول الوجبات 🍽️'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          CleaningScheduleTab(),
          SmartGroceryTab(),
          MealPlannerTab(),
        ],
      ),
    );
  }
}

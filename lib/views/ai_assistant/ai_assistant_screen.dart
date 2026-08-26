import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import 'widgets/parenting_chat_tab.dart';
import 'widgets/bedtime_story_tab.dart';
import 'widgets/fridge_recipe_tab.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, color: AppColors.secondary, size: 22),
            const SizedBox(width: 8),
            Text(
              'المساعد الذكي للأم 🤖',
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.secondary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          indicatorColor: AppColors.secondary,
          indicatorWeight: 3,
          labelStyle: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'المستشار التربوي 💬'),
            Tab(text: 'قصص النوم 🌙'),
            Tab(text: 'طباخ الثلاجة 🍳'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ParentingChatTab(),
          BedtimeStoryTab(),
          FridgeRecipeTab(),
        ],
      ),
    );
  }
}

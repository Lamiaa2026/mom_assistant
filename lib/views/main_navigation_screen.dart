import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../state/app_state.dart';
import 'dashboard/dashboard_screen.dart';
import 'childcare/childcare_screen.dart';
import 'home_management/home_management_screen.dart';
import 'ai_assistant/ai_assistant_screen.dart';
import 'settings/settings_screen.dart';
import 'dashboard/widgets/quick_action_bottom_sheet.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  static const List<Widget> _screens = [
    DashboardScreen(),
    ChildcareScreen(),
    HomeManagementScreen(),
    AIAssistantScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: state.currentNavIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => const QuickActionBottomSheet(),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        color: isDark ? AppColors.surfaceDark : Colors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              index: 0,
              icon: Icons.home_rounded,
              label: 'الرئيسية',
              state: state,
            ),
            _buildNavItem(
              context,
              index: 1,
              icon: Icons.child_care_rounded,
              label: 'أطفالي',
              state: state,
            ),
            const SizedBox(width: 44), // Space for floating button notch
            _buildNavItem(
              context,
              index: 2,
              icon: Icons.cleaning_services_rounded,
              label: 'البيت',
              state: state,
            ),
            _buildNavItem(
              context,
              index: 3,
              icon: Icons.auto_awesome_rounded,
              label: 'المساعد الذكي',
              state: state,
            ),
            _buildNavItem(
              context,
              index: 4,
              icon: Icons.settings_rounded,
              label: 'الإعدادات',
              state: state,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required AppState state,
  }) {
    final isSelected = state.currentNavIndex == index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final color = isSelected
        ? AppColors.primary
        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight);

    return InkWell(
      onTap: () => state.setNavIndex(index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

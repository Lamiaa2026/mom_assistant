import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../state/app_state.dart';
import '../childcare/widgets/add_child_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات والملف ⚙️', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Mom Profile Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.nightGradient : AppColors.warmCardGradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Text('🌸', style: TextStyle(fontSize: 32)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بكِ يا سوبر ماما 💖',
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'لديكِ ${state.children.length} أطفال مسجلين بالتطبيق',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 1: Children Profiles
          Text('ملفات الأطفال 👶', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                ...state.children.map((child) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primarySoft,
                      child: Text(child.avatar),
                    ),
                    title: Text(child.name, style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                    subtitle: Text(child.ageDescription, style: AppTypography.bodySmall),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddChildDialog(childToEdit: child),
                        );
                      },
                    ),
                  );
                }),
                const Divider(height: 1),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.mintSoft,
                    child: Icon(Icons.add_rounded, color: AppColors.mint),
                  ),
                  title: Text('إضافة طفل جديد', style: AppTypography.labelMedium.copyWith(color: AppColors.mint, fontWeight: FontWeight.bold)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AddChildDialog(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 2: Preferences & Theme
          Text('المظهر والتفضيلات 🎨', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.secondarySoft : AppColors.amberSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      color: isDark ? AppColors.secondary : AppColors.amber,
                    ),
                  ),
                  title: Text('الوضع الليلي الهادئ 🌙', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('مريح للعين أثناء الرضاعة وتفقد الطفل ليلاً', style: AppTypography.bodySmall),
                  value: state.isDarkMode,
                  onChanged: (_) => state.toggleDarkMode(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 3: Mother Self-Care & Emergency
          Text('العناية بالأم والطوارئ 🩺', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite_outline_rounded, color: AppColors.primary),
                  ),
                  title: Text('نصائح ذهبية لراحة وصحة الأم 💖', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('إرشادات للتغلب على إرهاق الأمومة وضغوط البيت', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showSelfCareModal(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.mintSoft,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.emergency_outlined, color: AppColors.mint),
                  ),
                  title: Text('إرشادات الطوارئ السريعة للأطفال 🚨', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text('التصرف السريع عند ارتفاع الحرارة، التشنجات، أو الغصة', style: AppTypography.bodySmall),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () => _showEmergencyModal(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section 4: Data & Reset
          Text('البيانات 💾', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.refresh_rounded, color: Colors.red),
              ),
              title: Text('إعادة ضبط البيانات الافتراضية', style: AppTypography.labelMedium.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
              subtitle: Text('استعادة البيانات النموذجية للتطبيق', style: AppTypography.bodySmall),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('تأكيد إعادة الضبط'),
                    content: const Text('هل ترغبين في استعادة البيانات النموذجية الأولية؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                      ElevatedButton(
                        onPressed: () {
                          state.resetAllData();
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تمت إعادة الضبط بنجاح 🌸')),
                          );
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('تأكيد'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 32),

          // App Version & Credits
          Center(
            child: Column(
              children: [
                Text(
                  '${AppConstants.appName} v1.0.0',
                  style: AppTypography.labelMedium.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'صُمم بكل حب لدعم كل أم بطلة 🌸✨',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showSelfCareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('نصائح ذهبية لراحة قلبكِ وجسدكِ 💖', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildBulletPoint('💧 حافظي على شرب الماء بكثرة خاصة أثناء الرضاعة.'),
              _buildBulletPoint('😴 نامي عندما ينام طفلكِ حتى لو كانت غفوة 20 دقيقة.'),
              _buildBulletPoint('🤝 لا تخجلي من طلب المساعدة وتقاسم المهام مع شريككِ.'),
              _buildBulletPoint('🌿 التراجع خطوة إلى الوراء والتنفس بعمق عند اشتداد البكاء.'),
              _buildBulletPoint('☕ خصصي وقتاً يومياً قصيراً جداً تفعلين فيه شيئاً يسعدكِ أنتِ فقط.'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('شكراً، سأعتني بنفسي 🌸'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmergencyModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('إرشادات الطوارئ السريعة 🚨', style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 16),
              _buildBulletPoint('🌡️ **ارتفاع الحرارة فوق 38.5**: كمادات ماء فاتر (تجنبي الماء البارد أو الكحول) ومسكن خافض مناسب بجرعة الطبيب.'),
              _buildBulletPoint('🫁 **صعوبة التنفس**: إذا كان هناك توسع في فتحات الأنف أو صوت أزيز أو انكماش في الصدر، توجهي فوراً للطوارئ.'),
              _buildBulletPoint('🤮 **الجفاف**: عدم وجود دموع عند البكاء، جفاف الفم، أو قلة الحفاضات المبللة (أقل من 4 يومياً) يستوجب استشارة الطبيب فوراً.'),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('حفظ الإرشادات'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(text, style: AppTypography.bodyMedium.copyWith(height: 1.6)),
    );
  }
}

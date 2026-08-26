import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../state/app_state.dart';

class BedtimeStoryTab extends StatefulWidget {
  const BedtimeStoryTab({super.key});

  @override
  State<BedtimeStoryTab> createState() => _BedtimeStoryTabState();
}

class _BedtimeStoryTabState extends State<BedtimeStoryTab> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;

  String _selectedTheme = AppConstants.storyThemes.first;
  String _selectedMoral = AppConstants.moralValues.first;
  String? _generatedStory;
  double _storyFontSize = 16.0;

  @override
  void initState() {
    super.initState();
    final child = context.read<AppState>().activeChild;
    _nameController = TextEditingController(text: child?.name ?? 'زيد');
    _ageController = TextEditingController(text: child != null ? '${(child.ageInMonths / 12).floor()}' : '3');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _generateStory(AppState state) async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();

    final story = await state.generateBedtimeStory(
      childName: name,
      childAge: age,
      theme: _selectedTheme,
      moralValue: _selectedMoral,
    );

    setState(() {
      _generatedStory = story;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.lavenderGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_stories_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مولّد قصص النوم المخصصة 📖✨',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'قصة فريدة باسم طفلكِ وعمره تحثه على القيم الطيبة وتساعده على نوم هادئ ومريح',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.95),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Child Name & Age Input
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم بطل القصة *',
                    hintText: 'مثال: زيد، لينا...',
                    prefixIcon: Icon(Icons.face_rounded),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'العمر (سنوات)',
                    hintText: '3',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Story Theme Selector
          Text('اختاري عالم وموضوع المغامرة:', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.storyThemes.map((theme) {
              final isSelected = _selectedTheme == theme;
              return ChoiceChip(
                label: Text(theme),
                selected: isSelected,
                selectedColor: AppColors.secondarySoft,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.secondary : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => setState(() => _selectedTheme = theme),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Moral Value Selector
          Text('القيمة الأخلاقية أو الدرس المستفاد:', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.moralValues.map((moral) {
              final isSelected = _selectedMoral == moral;
              return ChoiceChip(
                label: Text(moral),
                selected: isSelected,
                selectedColor: AppColors.mintSoft,
                labelStyle: AppTypography.bodySmall.copyWith(
                  color: isSelected ? AppColors.mint : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => setState(() => _selectedMoral = moral),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Generate Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isAiThinking ? null : () => _generateStory(state),
              icon: state.isAiThinking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(state.isAiThinking ? 'جارِ تأليف القصة الساحرة...' : 'توليد قصة النوم الآن 🌙✨'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),

          if (_generatedStory != null) ...[
            const SizedBox(height: 32),

            // Reading View Box
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : const Color(0xFFFCF9F2),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.amber.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.amber.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Reader Controls (Font Size, Copy, Close)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, color: AppColors.amber, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'وضع القراءة الليلي المريح 📖',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.text_decrease_rounded, size: 18),
                            onPressed: () {
                              if (_storyFontSize > 13) setState(() => _storyFontSize -= 1);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.text_increase_rounded, size: 18),
                            onPressed: () {
                              if (_storyFontSize < 24) setState(() => _storyFontSize += 1);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  SelectableText(
                    _generatedStory!,
                    style: AppTypography.bodyLarge.copyWith(
                      fontSize: _storyFontSize,
                      height: 1.8,
                      color: isDark ? AppColors.textPrimaryDark : const Color(0xFF332D27),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../state/app_state.dart';

class FridgeRecipeTab extends StatefulWidget {
  const FridgeRecipeTab({super.key});

  @override
  State<FridgeRecipeTab> createState() => _FridgeRecipeTabState();
}

class _FridgeRecipeTabState extends State<FridgeRecipeTab> {
  final List<String> _selectedIngredients = ['بيض', 'طماطم', 'جبن موزاريلا'];
  final TextEditingController _customIngredientController = TextEditingController();
  String? _generatedRecipe;

  @override
  void dispose() {
    _customIngredientController.dispose();
    super.dispose();
  }

  void _toggleIngredient(String item) {
    setState(() {
      if (_selectedIngredients.contains(item)) {
        _selectedIngredients.remove(item);
      } else {
        _selectedIngredients.add(item);
      }
    });
  }

  void _addCustomIngredient() {
    final text = _customIngredientController.text.trim();
    if (text.isNotEmpty && !_selectedIngredients.contains(text)) {
      setState(() {
        _selectedIngredients.add(text);
      });
      _customIngredientController.clear();
    }
  }

  Future<void> _generateRecipe(AppState state) async {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار أو كتابة مكون واحد على الأقل من الثلاجة 🥦')),
      );
      return;
    }

    final recipe = await state.generateFridgeRecipe(_selectedIngredients);
    setState(() {
      _generatedRecipe = recipe;
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
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
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
                  child: const Icon(Icons.kitchen_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طباخ الثلاجة الذكي 🍳',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'حددي ما يتوفر لديكِ في الثلاجة وسيقترح الذكاء الاصطناعي وجبة صحية ولذيذة في أقل من 15 دقيقة للأم والأطفال',
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

          // Selected Ingredients Box
          Text(
            'المكونات المختارة (${_selectedIngredients.length}):',
            style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          if (_selectedIngredients.isEmpty)
            Text(
              'لم تختاري أي مكون بعد، اضغطي على المكونات المقترحة بالأسفل 👇',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textMutedLight),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedIngredients.map((item) {
                return Chip(
                  label: Text(item, style: const TextStyle(fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.primarySoft,
                  side: const BorderSide(color: AppColors.primary, width: 1.2),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16, color: AppColors.primaryDark),
                  onDeleted: () => _toggleIngredient(item),
                );
              }).toList(),
            ),

          const SizedBox(height: 16),

          // Custom Ingredient Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customIngredientController,
                  onSubmitted: (_) => _addCustomIngredient(),
                  decoration: const InputDecoration(
                    hintText: 'إضافة مكون آخر بالاسم...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _addCustomIngredient,
                icon: const Icon(Icons.add_rounded),
                style: IconButton.styleFrom(backgroundColor: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Suggested Pantry items
          Text(
            'مكونات شائعة وسريعة في البيت:',
            style: AppTypography.labelMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.fridgeIngredientSuggestions.map((item) {
              final isSelected = _selectedIngredients.contains(item);
              return FilterChip(
                label: Text(item),
                selected: isSelected,
                selectedColor: AppColors.primarySoft,
                onSelected: (_) => _toggleIngredient(item),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Generate Recipe Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: state.isAiThinking ? null : () => _generateRecipe(state),
              icon: state.isAiThinking
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.restaurant_rounded),
              label: Text(state.isAiThinking ? 'جارِ ابتكار الوصفة السحرية...' : 'ابتكار وصفة سريعة وصحية 🍳'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),

          if (_generatedRecipe != null) ...[
            const SizedBox(height: 30),

            // Recipe Display Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SelectableText(
                _generatedRecipe!,
                style: AppTypography.bodyMedium.copyWith(
                  height: 1.7,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

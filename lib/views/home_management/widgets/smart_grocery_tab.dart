import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/grocery_item_model.dart';
import '../../../state/app_state.dart';

class SmartGroceryTab extends StatefulWidget {
  const SmartGroceryTab({super.key});

  @override
  State<SmartGroceryTab> createState() => _SmartGroceryTabState();
}

class _SmartGroceryTabState extends State<SmartGroceryTab> {
  final TextEditingController _quickAddController = TextEditingController();
  GroceryCategory _selectedCategory = GroceryCategory.babySupplies;
  GroceryCategory? _filterCategory;

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

  void _addQuickItem(AppState state) {
    final text = _quickAddController.text.trim();
    if (text.isEmpty) return;

    state.addGroceryItem(GroceryItemModel(
      id: const Uuid().v4(),
      name: text,
      category: _selectedCategory,
      addedDate: DateTime.now(),
    ));

    _quickAddController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allItems = state.groceryItems;

    var items = allItems;
    if (_filterCategory != null) {
      items = items.where((i) => i.category == _filterCategory).toList();
    }

    final unboughtCount = allItems.where((i) => !i.isBought).length;
    final boughtCount = allItems.where((i) => i.isBought).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Shopping Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.nightGradient : AppColors.mintGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.mint.withOpacity(0.2),
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
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'قائمة المقاضي والتسوق الذكية 🛒',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'متبقي $unboughtCount غرض للشراء • $boughtCount تم شراؤها',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Quick Add Input Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quickAddController,
                    onSubmitted: (_) => _addQuickItem(state),
                    decoration: const InputDecoration(
                      hintText: 'اكتبي غرضاً لإضافته بسرعة للمقاضي...',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                DropdownButton<GroceryCategory>(
                  value: _selectedCategory,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.category_outlined, size: 20),
                  items: GroceryCategory.values.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(
                        GroceryItemModel(id: '', name: '', category: cat, addedDate: DateTime.now()).categoryShortLabel,
                        style: AppTypography.bodySmall,
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(width: 6),
                IconButton.filled(
                  onPressed: () => _addQuickItem(state),
                  icon: const Icon(Icons.add_rounded, size: 20),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Category Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('كل الأقسام 🛍️'),
                  selected: _filterCategory == null,
                  onSelected: (_) => setState(() => _filterCategory = null),
                ),
                const SizedBox(width: 8),
                ...GroceryCategory.values.map((cat) {
                  final isSelected = _filterCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(GroceryItemModel(id: '', name: '', category: cat, addedDate: DateTime.now()).categoryLabel),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _filterCategory = isSelected ? null : cat),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // List Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الأغراض (${items.length})',
                style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.bold),
              ),
              if (boughtCount > 0)
                TextButton.icon(
                  onPressed: () => state.clearBoughtGroceries(),
                  icon: const Icon(Icons.cleaning_services_outlined, size: 16, color: Colors.grey),
                  label: const Text('مسح المكتمل', style: TextStyle(color: Colors.grey)),
                ),
            ],
          ),

          const SizedBox(height: 10),

          if (items.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Text(
                'قائمة المقاضي فارغة! أضيفي الاحتياجات لتتذكريها أثناء التسوق 🛒',
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
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = items[index];
                return _buildGroceryTile(context, item, state, isDark);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildGroceryTile(BuildContext context, GroceryItemModel item, AppState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.isBought ? AppColors.mint.withOpacity(0.4) : (isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      child: Row(
        children: [
          // Checkbox
          InkWell(
            onTap: () => state.toggleGroceryItem(item.id),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: item.isBought ? AppColors.mint : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.isBought ? AppColors.mint : AppColors.textMutedLight,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: item.isBought ? Colors.white : Colors.transparent,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: item.isBought ? TextDecoration.lineThrough : null,
                    color: item.isBought
                        ? (isDark ? AppColors.textMutedDark : AppColors.textMutedLight)
                        : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      item.categoryShortLabel,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.quantity.isNotEmpty && item.quantity != '1') ...[
                      const SizedBox(width: 8),
                      Text('•', style: AppTypography.bodySmall),
                      const SizedBox(width: 8),
                      Text(
                        'الكمية: ${item.quantity}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.grey),
            onPressed: () => state.deleteGroceryItem(item.id),
          ),
        ],
      ),
    );
  }
}

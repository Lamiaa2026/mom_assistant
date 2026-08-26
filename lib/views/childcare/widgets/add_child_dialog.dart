import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/child_model.dart';
import '../../../state/app_state.dart';

class AddChildDialog extends StatefulWidget {
  final ChildModel? childToEdit;

  const AddChildDialog({super.key, this.childToEdit});

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _allergiesController;
  late TextEditingController _notesController;

  late DateTime _birthDate;
  late String _gender;
  late String _avatar;
  String? _bloodType;

  @override
  void initState() {
    super.initState();
    final child = widget.childToEdit;
    _nameController = TextEditingController(text: child?.name ?? '');
    _weightController = TextEditingController(text: child?.currentWeightKg?.toString() ?? '');
    _heightController = TextEditingController(text: child?.currentHeightCm?.toString() ?? '');
    _allergiesController = TextEditingController(text: child?.allergies ?? '');
    _notesController = TextEditingController(text: child?.notes ?? '');

    _birthDate = child?.birthDate ?? DateTime.now();
    _gender = child?.gender ?? 'boy';
    _avatar = child?.avatar ?? '👶';
    _bloodType = child?.bloodType ?? 'O+';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _allergiesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.childToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEditing ? 'تعديل بيانات الطفل 📝' : 'إضافة طفل جديد 👶',
                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Avatar Selector
              Text('اختاري أيقونة الطفل:', style: AppTypography.labelMedium),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AppConstants.childAvatars.map((icon) {
                    final isSelected = _avatar == icon;
                    return GestureDetector(
                      onTap: () => setState(() => _avatar = icon),
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primarySoft : (isDark ? AppColors.cardDark : AppColors.backgroundLight),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(icon, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Name Field
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم الطفل *',
                  hintText: 'مثال: زيد، لينا...',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),

              const SizedBox(height: 12),

              // Gender Selector
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('ولد 👦')),
                      selected: _gender == 'boy',
                      selectedColor: AppColors.skyBlueSoft,
                      onSelected: (val) => setState(() => _gender = 'boy'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('بنت 👧')),
                      selected: _gender == 'girl',
                      selectedColor: AppColors.primarySoft,
                      onSelected: (val) => setState(() => _gender = 'girl'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Birth Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('تاريخ الميلاد:', style: AppTypography.labelMedium),
                subtitle: Text(
                  DateFormat('yyyy/MM/dd', 'ar').format(_birthDate),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(2015),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _birthDate = picked);
                  }
                },
              ),

              const SizedBox(height: 8),

              // Weight & Height
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'الوزن (كجم)',
                        hintText: '7.5',
                        prefixIcon: Icon(Icons.scale_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'الطول (سم)',
                        hintText: '68',
                        prefixIcon: Icon(Icons.height_rounded),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Allergies
              TextField(
                controller: _allergiesController,
                decoration: const InputDecoration(
                  labelText: 'أي حساسية معروفة',
                  hintText: 'مثال: حساسية حليب الأبقار، فراولة...',
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _saveChild,
                    child: Text(isEditing ? 'حفظ التعديلات' : 'إضافة الطفل'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChild() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء كتابة اسم الطفل')),
      );
      return;
    }

    final state = context.read<AppState>();
    final weight = double.tryParse(_weightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());

    if (widget.childToEdit != null) {
      state.updateChild(widget.childToEdit!.copyWith(
        name: name,
        birthDate: _birthDate,
        gender: _gender,
        avatar: _avatar,
        currentWeightKg: weight,
        currentHeightCm: height,
        bloodType: _bloodType,
        allergies: _allergiesController.text.trim(),
        notes: _notesController.text.trim(),
      ));
    } else {
      final newChild = ChildModel(
        id: const Uuid().v4(),
        name: name,
        birthDate: _birthDate,
        gender: _gender,
        avatar: _avatar,
        currentWeightKg: weight,
        currentHeightCm: height,
        bloodType: _bloodType,
        allergies: _allergiesController.text.trim(),
        notes: _notesController.text.trim(),
      );
      state.addChild(newChild);
    }

    Navigator.pop(context);
  }
}

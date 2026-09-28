import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../models/nutrition_data.dart';

const List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

/// Width (at a text scale of 1.0) needed to keep the three macros in a row.
const double _macrosMinWidth = 300;

/// Child of Nutrition: log a meal by hand and return it to the dashboard.
class ManualEntryScreen extends StatefulWidget {
  const ManualEntryScreen({super.key, this.dayLabel = 'Today'});

  final String dayLabel;

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _kcalController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();

  String _mealType = _mealTypes.first;

  @override
  void dispose() {
    _nameController.dispose();
    _kcalController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  int _parseGrams(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return 0;
    return int.tryParse(trimmed) ?? 0;
  }

  void _onSave() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final meal = MealEntry(
      mealType: _mealType,
      name: _nameController.text.trim(),
      kcal: int.parse(_kcalController.text.trim()),
      proteinGrams: _parseGrams(_proteinController.text),
      carbsGrams: _parseGrams(_carbsController.text),
      fatGrams: _parseGrams(_fatController.text),
    );
    Navigator.of(context).pop(meal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Manual Entry'),
      ),
      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Logging for ${widget.dayLabel.toLowerCase()}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.xl),
                _DropdownField(
                  label: 'Meal',
                  value: _mealType,
                  options: _mealTypes,
                  onChanged: (value) => setState(() => _mealType = value),
                ),
                const SizedBox(height: AppSpacing.xl),
                _TextField(
                  label: 'Food name',
                  controller: _nameController,
                  hint: 'e.g. Oats & Banana',
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter a food name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _TextField(
                  label: 'Calories',
                  controller: _kcalController,
                  hint: '0',
                  suffix: 'kcal',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) {
                    final parsed = int.tryParse(value?.trim() ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter calories greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
                _MacroFields(
                  proteinController: _proteinController,
                  carbsController: _carbsController,
                  fatController: _fatController,
                ),
                const SizedBox(height: AppSpacing.xxl),
                ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: const Text('Add Meal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          dropdownColor: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.button),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.secondaryText,
          ),
          style: textTheme.bodyLarge,
          items: [
            for (final option in options)
              DropdownMenuItem(value: option, child: Text(option)),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ],
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.hint,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
          ),
        ),
      ],
    );
  }
}

class _MacroFields extends StatelessWidget {
  const _MacroFields({
    required this.proteinController,
    required this.carbsController,
    required this.fatController,
  });

  final TextEditingController proteinController;
  final TextEditingController carbsController;
  final TextEditingController fatController;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final protein = _TextField(
          label: 'Protein',
          controller: proteinController,
          hint: '0',
          suffix: 'g',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
        final carbs = _TextField(
          label: 'Carbs',
          controller: carbsController,
          hint: '0',
          suffix: 'g',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
        final fat = _TextField(
          label: 'Fat',
          controller: fatController,
          hint: '0',
          suffix: 'g',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        );
        final rowBreakpoint = MediaQuery.textScalerOf(
          context,
        ).scale(_macrosMinWidth);

        if (constraints.maxWidth < rowBreakpoint) {
          return Column(
            children: [
              protein,
              const SizedBox(height: AppSpacing.xl),
              carbs,
              const SizedBox(height: AppSpacing.xl),
              fat,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: protein),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: carbs),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: fat),
          ],
        );
      },
    );
  }
}

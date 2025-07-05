import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/customization/data/repositories/ui_customization_repository.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}

class CustomColorPicker extends StatelessWidget {
  final String label;
  final Color currentColor;
  final Function(Color) onColorChanged;
  final String keyValue;

  const CustomColorPicker({
    super.key,
    required this.label,
    required this.currentColor,
    required this.onColorChanged,
    required this.keyValue,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: Key(keyValue),
      title: Text(label),
      trailing: GestureDetector(
        onTap: () => _showColorPicker(context),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: currentColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    Color pickerColor = currentColor;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Pick $label'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  setDialogState(() {
                    pickerColor = color;
                  });
                },
                enableAlpha: false,
                displayThumbColor: true,
                pickerAreaBorderRadius:
                    const BorderRadius.all(Radius.circular(10)),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onColorChanged(pickerColor);
                },
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class CustomSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final Function(double) onChanged;
  final int? divisions;
  final String keyValue;

  const CustomSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    required this.keyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(keyValue),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: value.toStringAsFixed(1),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final List<T> items;
  final Function(T?) onChanged;
  final String keyValue;

  const CustomDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.keyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: Key(keyValue),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(_getDisplayName(item)),
                  ))
              .toList(),
          onChanged: onChanged,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  String _getDisplayName(dynamic value) {
    if (value is String) {
      // Capitalize first letter
      if (value.isEmpty) return value;
      return value[0].toUpperCase() + value.substring(1);
    }
    return value.toString().split('.').last;
  }
}

class PresetThemes extends ConsumerWidget {
  final Function(String) onPresetSelected;

  const PresetThemes({
    super.key,
    required this.onPresetSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repository = ref.read(uiCustomizationRepositoryProvider);
    final presets = repository.getAvailablePresets();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: presets.entries.map((preset) {
        return ChoiceChip(
          key: Key('preset_${preset.key}'),
          label: Text(preset.value),
          selected: false,
          onSelected: (selected) {
            if (selected) {
              onPresetSelected(preset.key);
            }
          },
        );
      }).toList(),
    );
  }
}

class ResetDialog extends StatelessWidget {
  final Function() onReset;

  const ResetDialog({
    super.key,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reset to Defaults'),
      content: const Text(
          'This will reset all customizations to the minimal theme. Are you sure?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            onReset();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Reset'),
        ),
      ],
    );
  }

  static void show(BuildContext context, Function() onReset) {
    showDialog(
      context: context,
      builder: (context) => ResetDialog(onReset: onReset),
    );
  }
}

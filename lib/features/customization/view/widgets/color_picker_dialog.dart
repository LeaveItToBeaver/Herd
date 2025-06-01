import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class EnhancedColorPickerDialog extends StatefulWidget {
  final String label;
  final Color initialColor;
  final Function(Color) onColorSelected;
  final Map<String, Color>? allColors; // Optional: all theme colors for preview

  const EnhancedColorPickerDialog({
    super.key,
    required this.label,
    required this.initialColor,
    required this.onColorSelected,
    this.allColors,
  });

  @override
  State<EnhancedColorPickerDialog> createState() =>
      _EnhancedColorPickerDialogState();
}

class _EnhancedColorPickerDialogState extends State<EnhancedColorPickerDialog> {
  late Color _currentColor;
  late Color _tempColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _tempColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Pick ${widget.label}'),
          // Show color comparison
          Row(
            children: [
              _buildColorChip('Original', widget.initialColor),
              const SizedBox(width: 8),
              _buildColorChip('New', _tempColor),
            ],
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Color picker
            ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                  _tempColor = color;
                });
              },
              enableAlpha: false,
              displayThumbColor: true,
              pickerAreaBorderRadius:
                  const BorderRadius.all(Radius.circular(10)),
              pickerAreaHeightPercent: 0.6,
            ),

            const SizedBox(height: 16),

            // Preview section
            _buildPreviewSection(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onColorSelected(_tempColor);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildColorChip(String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade400),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    // Calculate contrasting text color
    final textColor =
        _tempColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tempColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Preview',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          // Mini UI preview
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home, color: textColor, size: 20),
                Icon(Icons.search, color: textColor, size: 20),
                Icon(Icons.person, color: textColor, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is how text will look',
            style: TextStyle(color: textColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Extension method to use the enhanced color picker
extension ColorPickerExtension on State {
  Future<void> showEnhancedColorPicker({
    required String label,
    required Color currentColor,
    required Function(Color) onColorSelected,
    Map<String, Color>? allColors,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => EnhancedColorPickerDialog(
        label: label,
        initialColor: currentColor,
        onColorSelected: onColorSelected,
        allColors: allColors,
      ),
    );
  }
}

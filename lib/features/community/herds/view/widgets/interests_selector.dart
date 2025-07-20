import 'package:flutter/material.dart';

/// Widget for selecting herd interests
class InterestsSelector extends StatelessWidget {
  final List<String> availableInterests;
  final List<String> selectedInterests;
  final Function(String) onToggleInterest;

  const InterestsSelector({
    super.key,
    required this.availableInterests,
    required this.selectedInterests,
    required this.onToggleInterest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Herd Interests',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose interests that define what your herd is about',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableInterests.map((interest) {
              final isSelected = selectedInterests.contains(interest);
              return FilterChip(
                label: Text(
                  interest,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onToggleInterest(interest),
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
                showCheckmark: false,
                elevation: isSelected ? 4 : 1,
                shadowColor: isSelected
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.3)
                    : Colors.black.withValues(alpha: 0.1),
                side: isSelected
                    ? BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      )
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

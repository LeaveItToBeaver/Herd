import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/ui/customization/view/providers/optimistic_slider_provider.dart';

class OptimisticSlider<T extends num> extends ConsumerWidget {
  final AutoDisposeNotifierProvider<OptimisticSliderNotifier<T>,
      OptimisticSliderState<T>> provider;
  final String label;
  final T min;
  final T max;
  final int? divisions;
  final String Function(T)? valueFormatter;
  final Widget? errorWidget;

  const OptimisticSlider({
    super.key,
    required this.provider,
    required this.label,
    required this.min,
    required this.max,
    this.divisions,
    this.valueFormatter,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sliderState = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valueFormatter?.call(sliderState.displayValue) ??
                      sliderState.displayValue.toStringAsFixed(1),
                ),
                if (sliderState.isPersisting) ...[
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ],
                if (sliderState.optimisticValue != null &&
                    !sliderState.isPersisting) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ],
            ),
          ],
        ),
        Slider(
          value: sliderState.displayValue.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: divisions,
          label: valueFormatter?.call(sliderState.displayValue) ??
              sliderState.displayValue.toStringAsFixed(1),
          onChanged: (value) {
            final typedValue = T == int ? value.round() as T : value as T;
            notifier.updateValue(typedValue);
          },
        ),
        if (sliderState.error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: errorWidget ??
                Text(
                  'Failed to save: ${sliderState.error}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
          ),
      ],
    );
  }
}

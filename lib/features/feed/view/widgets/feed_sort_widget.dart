import 'package:flutter/material.dart';
import 'package:herdapp/features/feed/data/models/feed_sort_type.dart';

class FeedSortWidget extends StatelessWidget {
  final FeedSortType currentSort;
  final Function(FeedSortType) onSortChanged;
  final bool isLoading;

  const FeedSortWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: FeedSortType.values.map((sortType) {
                  final isSelected = currentSort == sortType;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _SortChip(
                      label: sortType.displayName,
                      isSelected: isSelected,
                      onTap: isLoading
                          ? null
                          : () {
                              if (!isSelected) {
                                onSortChanged(sortType);
                              }
                            },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _SortChip({
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class FeedSortSegmentedButton extends StatelessWidget {
  final FeedSortType currentSort;
  final Function(FeedSortType) onSortChanged;
  final bool isLoading;

  const FeedSortSegmentedButton({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SegmentedButton<FeedSortType>(
        segments: FeedSortType.values.map((sortType) {
          // Add elevation for selected segment with drop shadow
          final isSelected = currentSort == sortType;
          final elevation = isSelected ? 2.0 : 0.0;
          return ButtonSegment<FeedSortType>(
            value: sortType,
            label: Text(sortType.displayName),
            icon: _getIconForSort(sortType),
          );
        }).toList(),
        selected: {currentSort},
        onSelectionChanged: isLoading
            ? null
            : (Set<FeedSortType> selected) {
                if (selected.isNotEmpty) {
                  onSortChanged(selected.first);
                }
              },
        showSelectedIcon: false,
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(WidgetState.selected)) {
                return Theme.of(context).colorScheme.primary;
              }
              return Theme.of(context).colorScheme.surfaceContainerHighest;
            },
          ),
        ),
      ),
    );
  }

  Widget? _getIconForSort(FeedSortType sortType) {
    switch (sortType) {
      case FeedSortType.hot:
        return const Icon(Icons.whatshot_outlined, size: 18);
      case FeedSortType.latest:
        return const Icon(Icons.access_time, size: 18);
      case FeedSortType.trending:
        return const Icon(Icons.trending_up, size: 18);
      case FeedSortType.top:
        return const Icon(Icons.star_outline, size: 18);
    }
  }
}

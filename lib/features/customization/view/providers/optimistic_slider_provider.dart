import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

// Generic state for any slider value
@immutable
class OptimisticSliderState<T> {
  final T persistedValue;
  final T? optimisticValue;
  final bool isPersisting;
  final String? error;

  const OptimisticSliderState({
    required this.persistedValue,
    this.optimisticValue,
    this.isPersisting = false,
    this.error,
  });

  // The current value to display (optimistic if available, otherwise persisted)
  T get displayValue => optimisticValue ?? persistedValue;

  OptimisticSliderState<T> copyWith({
    T? persistedValue,
    T? optimisticValue,
    bool? isPersisting,
    String? error,
    bool clearOptimistic = false,
    bool clearError = false,
  }) {
    return OptimisticSliderState<T>(
      persistedValue: persistedValue ?? this.persistedValue,
      optimisticValue:
          clearOptimistic ? null : (optimisticValue ?? this.optimisticValue),
      isPersisting: isPersisting ?? this.isPersisting,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// Generic notifier for optimistic slider updates
class OptimisticSliderNotifier<T>
    extends AutoDisposeNotifier<OptimisticSliderState<T>> {
  Timer? _debounceTimer;
  final Duration debounceDuration;
  final Future<void> Function(T value, Ref ref) persistFunction;
  final T initialValue;

  OptimisticSliderNotifier({
    required this.persistFunction,
    required this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 300),
  });

  @override
  OptimisticSliderState<T> build() {
    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return OptimisticSliderState<T>(persistedValue: initialValue);
  }

  // Update the persisted value (called when the source data changes)
  void updatePersistedValue(T value) {
    state = state.copyWith(
      persistedValue: value,
      clearOptimistic: true,
      clearError: true,
    );
  }

  // Optimistic update with debounced persistence
  void updateValue(T value) {
    // Immediate optimistic update
    state = state.copyWith(
      optimisticValue: value,
      clearError: true,
    );

    // Cancel existing timer
    _debounceTimer?.cancel();

    // Debounced persistence
    _debounceTimer = Timer(debounceDuration, () async {
      await _persistValue(value);
    });
  }

  Future<void> _persistValue(T value) async {
    state = state.copyWith(isPersisting: true);

    try {
      await persistFunction(value, ref);

      // Success: clear optimistic value and update persisted
      state = state.copyWith(
        persistedValue: value,
        isPersisting: false,
        clearOptimistic: true,
        clearError: true,
      );
    } catch (error) {
      // Error: keep optimistic value and show error
      state = state.copyWith(
        isPersisting: false,
        error: error.toString(),
      );
    }
  }

  // Force immediate persistence (for when user navigates away, etc.)
  Future<void> flush() async {
    _debounceTimer?.cancel();
    if (state.optimisticValue != null) {
      await _persistValue(state.optimisticValue as T);
    }
  }
}

// Provider factory for creating slider providers
typedef SliderProviderFactory<T> = AutoDisposeNotifierProvider<
    OptimisticSliderNotifier<T>, OptimisticSliderState<T>>;

SliderProviderFactory<T> createOptimisticSliderProvider<T>({
  required String name,
  required Future<void> Function(T value, Ref ref) persistFunction,
  required T initialValue,
  Duration debounceDuration = const Duration(milliseconds: 300),
}) {
  return NotifierProvider.autoDispose<OptimisticSliderNotifier<T>,
      OptimisticSliderState<T>>(
    () => OptimisticSliderNotifier<T>(
      persistFunction: persistFunction,
      initialValue: initialValue,
      debounceDuration: debounceDuration,
    ),
    name: name,
  );
}

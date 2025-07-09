import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

// Generic state for any slider value
@immutable
class OptimisticSliderState<T> {
  final T persistedValue;
  final T? optimisticValue;
  final bool isPersisting;
  final String? error;
  final Duration debounceDuration;
  final Future<void> Function(T value, Ref ref) persistFunction;
  final T initialValue;

  const OptimisticSliderState({
    required this.persistedValue,
    this.optimisticValue,
    this.isPersisting = false,
    this.error,
    required this.debounceDuration,
    required this.persistFunction,
    required this.initialValue,
  });

  // The current value to display (optimistic if available, otherwise persisted)
  T get displayValue => optimisticValue ?? persistedValue;

  OptimisticSliderState<T> copyWith({
    T? persistedValue,
    T? optimisticValue,
    bool? isPersisting,
    String? error,
    Duration? debounceDuration,
    Future<void> Function(T value, Ref ref)? persistFunction,
    T? initialValue,
    bool clearOptimistic = false,
    bool clearError = false,
  }) {
    return OptimisticSliderState<T>(
      persistedValue: persistedValue ?? this.persistedValue,
      optimisticValue:
          clearOptimistic ? null : (optimisticValue ?? this.optimisticValue),
      isPersisting: isPersisting ?? this.isPersisting,
      error: clearError ? null : (error ?? this.error),
      debounceDuration: debounceDuration ?? this.debounceDuration,
      persistFunction: persistFunction ?? this.persistFunction,
      initialValue: initialValue ?? this.initialValue,
    );
  }
}

// Generic notifier for optimistic slider updates
class OptimisticSliderNotifier<T>
    extends AutoDisposeNotifier<OptimisticSliderState<T>> {
  Timer? _debounceTimer;

  @override
  OptimisticSliderState<T> build() {
    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // This will throw if not initialized properly - override in subclasses
    throw UnimplementedError(
        'Use createOptimisticSliderProvider to create instances');
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
    _debounceTimer = Timer(state.debounceDuration, () async {
      await _persistValue(value);
    });
  }

  Future<void> _persistValue(T value) async {
    state = state.copyWith(isPersisting: true);

    try {
      await state.persistFunction(value, ref);

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

// Concrete implementation for factory creation
class _ConcreteOptimisticSliderNotifier<T> extends OptimisticSliderNotifier<T> {
  final Duration _debounceDuration;
  final Future<void> Function(T value, Ref ref) _persistFunction;
  final T _initialValue;

  _ConcreteOptimisticSliderNotifier({
    required Duration debounceDuration,
    required Future<void> Function(T value, Ref ref) persistFunction,
    required T initialValue,
  })  : _debounceDuration = debounceDuration,
        _persistFunction = persistFunction,
        _initialValue = initialValue;

  @override
  OptimisticSliderState<T> build() {
    // Cancel timer when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return OptimisticSliderState<T>(
      persistedValue: _initialValue,
      debounceDuration: _debounceDuration,
      persistFunction: _persistFunction,
      initialValue: _initialValue,
    );
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
    () => _ConcreteOptimisticSliderNotifier<T>(
      persistFunction: persistFunction,
      initialValue: initialValue,
      debounceDuration: debounceDuration,
    ),
    name: name,
  );
}

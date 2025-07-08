// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_filter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationFilterState implements DiagnosticableTreeMixin {
  NotificationFilter get activeFilter;
  Map<NotificationFilter, int> get counts;

  /// Create a copy of NotificationFilterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationFilterStateCopyWith<NotificationFilterState> get copyWith =>
      _$NotificationFilterStateCopyWithImpl<NotificationFilterState>(
          this as NotificationFilterState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationFilterState'))
      ..add(DiagnosticsProperty('activeFilter', activeFilter))
      ..add(DiagnosticsProperty('counts', counts));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationFilterState &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter) &&
            const DeepCollectionEquality().equals(other.counts, counts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, activeFilter, const DeepCollectionEquality().hash(counts));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationFilterState(activeFilter: $activeFilter, counts: $counts)';
  }
}

/// @nodoc
abstract mixin class $NotificationFilterStateCopyWith<$Res> {
  factory $NotificationFilterStateCopyWith(NotificationFilterState value,
          $Res Function(NotificationFilterState) _then) =
      _$NotificationFilterStateCopyWithImpl;
  @useResult
  $Res call(
      {NotificationFilter activeFilter, Map<NotificationFilter, int> counts});
}

/// @nodoc
class _$NotificationFilterStateCopyWithImpl<$Res>
    implements $NotificationFilterStateCopyWith<$Res> {
  _$NotificationFilterStateCopyWithImpl(this._self, this._then);

  final NotificationFilterState _self;
  final $Res Function(NotificationFilterState) _then;

  /// Create a copy of NotificationFilterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeFilter = null,
    Object? counts = null,
  }) {
    return _then(_self.copyWith(
      activeFilter: null == activeFilter
          ? _self.activeFilter
          : activeFilter // ignore: cast_nullable_to_non_nullable
              as NotificationFilter,
      counts: null == counts
          ? _self.counts
          : counts // ignore: cast_nullable_to_non_nullable
              as Map<NotificationFilter, int>,
    ));
  }
}

/// Adds pattern-matching-related methods to [NotificationFilterState].
extension NotificationFilterStatePatterns on NotificationFilterState {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_NotificationFilterState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationFilterState() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_NotificationFilterState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationFilterState():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_NotificationFilterState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationFilterState() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(NotificationFilter activeFilter,
            Map<NotificationFilter, int> counts)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationFilterState() when $default != null:
        return $default(_that.activeFilter, _that.counts);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(NotificationFilter activeFilter,
            Map<NotificationFilter, int> counts)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationFilterState():
        return $default(_that.activeFilter, _that.counts);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(NotificationFilter activeFilter,
            Map<NotificationFilter, int> counts)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationFilterState() when $default != null:
        return $default(_that.activeFilter, _that.counts);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _NotificationFilterState
    with DiagnosticableTreeMixin
    implements NotificationFilterState {
  const _NotificationFilterState(
      {this.activeFilter = NotificationFilter.all,
      final Map<NotificationFilter, int> counts = const {}})
      : _counts = counts;

  @override
  @JsonKey()
  final NotificationFilter activeFilter;
  final Map<NotificationFilter, int> _counts;
  @override
  @JsonKey()
  Map<NotificationFilter, int> get counts {
    if (_counts is EqualUnmodifiableMapView) return _counts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_counts);
  }

  /// Create a copy of NotificationFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationFilterStateCopyWith<_NotificationFilterState> get copyWith =>
      __$NotificationFilterStateCopyWithImpl<_NotificationFilterState>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationFilterState'))
      ..add(DiagnosticsProperty('activeFilter', activeFilter))
      ..add(DiagnosticsProperty('counts', counts));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationFilterState &&
            (identical(other.activeFilter, activeFilter) ||
                other.activeFilter == activeFilter) &&
            const DeepCollectionEquality().equals(other._counts, _counts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, activeFilter, const DeepCollectionEquality().hash(_counts));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationFilterState(activeFilter: $activeFilter, counts: $counts)';
  }
}

/// @nodoc
abstract mixin class _$NotificationFilterStateCopyWith<$Res>
    implements $NotificationFilterStateCopyWith<$Res> {
  factory _$NotificationFilterStateCopyWith(_NotificationFilterState value,
          $Res Function(_NotificationFilterState) _then) =
      __$NotificationFilterStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {NotificationFilter activeFilter, Map<NotificationFilter, int> counts});
}

/// @nodoc
class __$NotificationFilterStateCopyWithImpl<$Res>
    implements _$NotificationFilterStateCopyWith<$Res> {
  __$NotificationFilterStateCopyWithImpl(this._self, this._then);

  final _NotificationFilterState _self;
  final $Res Function(_NotificationFilterState) _then;

  /// Create a copy of NotificationFilterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? activeFilter = null,
    Object? counts = null,
  }) {
    return _then(_NotificationFilterState(
      activeFilter: null == activeFilter
          ? _self.activeFilter
          : activeFilter // ignore: cast_nullable_to_non_nullable
              as NotificationFilter,
      counts: null == counts
          ? _self._counts
          : counts // ignore: cast_nullable_to_non_nullable
              as Map<NotificationFilter, int>,
    ));
  }
}

// dart format on

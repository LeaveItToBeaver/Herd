// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftPostModel implements DiagnosticableTreeMixin {
  String get id;
  String get authorId;
  String? get title;
  String get content;
  bool get isAlt;
  bool get isNSFW;
  String? get herdId;
  String? get herdName;
  DateTime? get createdAt;
  DateTime? get updatedAt;

  /// Create a copy of DraftPostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DraftPostModelCopyWith<DraftPostModel> get copyWith =>
      _$DraftPostModelCopyWithImpl<DraftPostModel>(
          this as DraftPostModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DraftPostModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('authorId', authorId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DraftPostModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
            (identical(other.herdId, herdId) || other.herdId == herdId) &&
            (identical(other.herdName, herdName) ||
                other.herdName == herdName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, authorId, title, content,
      isAlt, isNSFW, herdId, herdName, createdAt, updatedAt);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DraftPostModel(id: $id, authorId: $authorId, title: $title, content: $content, isAlt: $isAlt, isNSFW: $isNSFW, herdId: $herdId, herdName: $herdName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class $DraftPostModelCopyWith<$Res> {
  factory $DraftPostModelCopyWith(
          DraftPostModel value, $Res Function(DraftPostModel) _then) =
      _$DraftPostModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String authorId,
      String? title,
      String content,
      bool isAlt,
      bool isNSFW,
      String? herdId,
      String? herdName,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class _$DraftPostModelCopyWithImpl<$Res>
    implements $DraftPostModelCopyWith<$Res> {
  _$DraftPostModelCopyWithImpl(this._self, this._then);

  final DraftPostModel _self;
  final $Res Function(DraftPostModel) _then;

  /// Create a copy of DraftPostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? title = freezed,
    Object? content = null,
    Object? isAlt = null,
    Object? isNSFW = null,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      herdId: freezed == herdId
          ? _self.herdId
          : herdId // ignore: cast_nullable_to_non_nullable
              as String?,
      herdName: freezed == herdName
          ? _self.herdName
          : herdName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [DraftPostModel].
extension DraftPostModelPatterns on DraftPostModel {
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
    TResult Function(_DraftPostModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DraftPostModel() when $default != null:
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
    TResult Function(_DraftPostModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DraftPostModel():
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
    TResult? Function(_DraftPostModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DraftPostModel() when $default != null:
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
    TResult Function(
            String id,
            String authorId,
            String? title,
            String content,
            bool isAlt,
            bool isNSFW,
            String? herdId,
            String? herdName,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DraftPostModel() when $default != null:
        return $default(
            _that.id,
            _that.authorId,
            _that.title,
            _that.content,
            _that.isAlt,
            _that.isNSFW,
            _that.herdId,
            _that.herdName,
            _that.createdAt,
            _that.updatedAt);
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
    TResult Function(
            String id,
            String authorId,
            String? title,
            String content,
            bool isAlt,
            bool isNSFW,
            String? herdId,
            String? herdName,
            DateTime? createdAt,
            DateTime? updatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DraftPostModel():
        return $default(
            _that.id,
            _that.authorId,
            _that.title,
            _that.content,
            _that.isAlt,
            _that.isNSFW,
            _that.herdId,
            _that.herdName,
            _that.createdAt,
            _that.updatedAt);
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
    TResult? Function(
            String id,
            String authorId,
            String? title,
            String content,
            bool isAlt,
            bool isNSFW,
            String? herdId,
            String? herdName,
            DateTime? createdAt,
            DateTime? updatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DraftPostModel() when $default != null:
        return $default(
            _that.id,
            _that.authorId,
            _that.title,
            _that.content,
            _that.isAlt,
            _that.isNSFW,
            _that.herdId,
            _that.herdName,
            _that.createdAt,
            _that.updatedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DraftPostModel extends DraftPostModel with DiagnosticableTreeMixin {
  const _DraftPostModel(
      {required this.id,
      required this.authorId,
      this.title,
      required this.content,
      this.isAlt = false,
      this.isNSFW = false,
      this.herdId,
      this.herdName,
      this.createdAt,
      this.updatedAt})
      : super._();

  @override
  final String id;
  @override
  final String authorId;
  @override
  final String? title;
  @override
  final String content;
  @override
  @JsonKey()
  final bool isAlt;
  @override
  @JsonKey()
  final bool isNSFW;
  @override
  final String? herdId;
  @override
  final String? herdName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  /// Create a copy of DraftPostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DraftPostModelCopyWith<_DraftPostModel> get copyWith =>
      __$DraftPostModelCopyWithImpl<_DraftPostModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'DraftPostModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('authorId', authorId))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DraftPostModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
            (identical(other.herdId, herdId) || other.herdId == herdId) &&
            (identical(other.herdName, herdName) ||
                other.herdName == herdName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, authorId, title, content,
      isAlt, isNSFW, herdId, herdName, createdAt, updatedAt);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'DraftPostModel(id: $id, authorId: $authorId, title: $title, content: $content, isAlt: $isAlt, isNSFW: $isNSFW, herdId: $herdId, herdName: $herdName, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}

/// @nodoc
abstract mixin class _$DraftPostModelCopyWith<$Res>
    implements $DraftPostModelCopyWith<$Res> {
  factory _$DraftPostModelCopyWith(
          _DraftPostModel value, $Res Function(_DraftPostModel) _then) =
      __$DraftPostModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String authorId,
      String? title,
      String content,
      bool isAlt,
      bool isNSFW,
      String? herdId,
      String? herdName,
      DateTime? createdAt,
      DateTime? updatedAt});
}

/// @nodoc
class __$DraftPostModelCopyWithImpl<$Res>
    implements _$DraftPostModelCopyWith<$Res> {
  __$DraftPostModelCopyWithImpl(this._self, this._then);

  final _DraftPostModel _self;
  final $Res Function(_DraftPostModel) _then;

  /// Create a copy of DraftPostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? title = freezed,
    Object? content = null,
    Object? isAlt = null,
    Object? isNSFW = null,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(_DraftPostModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      herdId: freezed == herdId
          ? _self.herdId
          : herdId // ignore: cast_nullable_to_non_nullable
              as String?,
      herdName: freezed == herdName
          ? _self.herdName
          : herdName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on

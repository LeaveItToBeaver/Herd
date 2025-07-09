// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_media_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostMediaModel implements DiagnosticableTreeMixin {
  String get id;
  String get url;
  String? get thumbnailUrl;
  String get mediaType;

  /// Create a copy of PostMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostMediaModelCopyWith<PostMediaModel> get copyWith =>
      _$PostMediaModelCopyWithImpl<PostMediaModel>(
          this as PostMediaModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostMediaModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('thumbnailUrl', thumbnailUrl))
      ..add(DiagnosticsProperty('mediaType', mediaType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostMediaModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, thumbnailUrl, mediaType);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostMediaModel(id: $id, url: $url, thumbnailUrl: $thumbnailUrl, mediaType: $mediaType)';
  }
}

/// @nodoc
abstract mixin class $PostMediaModelCopyWith<$Res> {
  factory $PostMediaModelCopyWith(
          PostMediaModel value, $Res Function(PostMediaModel) _then) =
      _$PostMediaModelCopyWithImpl;
  @useResult
  $Res call({String id, String url, String? thumbnailUrl, String mediaType});
}

/// @nodoc
class _$PostMediaModelCopyWithImpl<$Res>
    implements $PostMediaModelCopyWith<$Res> {
  _$PostMediaModelCopyWithImpl(this._self, this._then);

  final PostMediaModel _self;
  final $Res Function(PostMediaModel) _then;

  /// Create a copy of PostMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? mediaType = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: null == mediaType
          ? _self.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostMediaModel].
extension PostMediaModelPatterns on PostMediaModel {
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
    TResult Function(_PostMediaModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostMediaModel() when $default != null:
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
    TResult Function(_PostMediaModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostMediaModel():
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
    TResult? Function(_PostMediaModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostMediaModel() when $default != null:
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
            String id, String url, String? thumbnailUrl, String mediaType)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostMediaModel() when $default != null:
        return $default(
            _that.id, _that.url, _that.thumbnailUrl, _that.mediaType);
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
            String id, String url, String? thumbnailUrl, String mediaType)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostMediaModel():
        return $default(
            _that.id, _that.url, _that.thumbnailUrl, _that.mediaType);
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
            String id, String url, String? thumbnailUrl, String mediaType)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostMediaModel() when $default != null:
        return $default(
            _that.id, _that.url, _that.thumbnailUrl, _that.mediaType);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PostMediaModel extends PostMediaModel with DiagnosticableTreeMixin {
  const _PostMediaModel(
      {required this.id,
      required this.url,
      this.thumbnailUrl,
      this.mediaType = 'image'})
      : super._();

  @override
  final String id;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  @JsonKey()
  final String mediaType;

  /// Create a copy of PostMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostMediaModelCopyWith<_PostMediaModel> get copyWith =>
      __$PostMediaModelCopyWithImpl<_PostMediaModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostMediaModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('thumbnailUrl', thumbnailUrl))
      ..add(DiagnosticsProperty('mediaType', mediaType));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostMediaModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, thumbnailUrl, mediaType);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostMediaModel(id: $id, url: $url, thumbnailUrl: $thumbnailUrl, mediaType: $mediaType)';
  }
}

/// @nodoc
abstract mixin class _$PostMediaModelCopyWith<$Res>
    implements $PostMediaModelCopyWith<$Res> {
  factory _$PostMediaModelCopyWith(
          _PostMediaModel value, $Res Function(_PostMediaModel) _then) =
      __$PostMediaModelCopyWithImpl;
  @override
  @useResult
  $Res call({String id, String url, String? thumbnailUrl, String mediaType});
}

/// @nodoc
class __$PostMediaModelCopyWithImpl<$Res>
    implements _$PostMediaModelCopyWith<$Res> {
  __$PostMediaModelCopyWithImpl(this._self, this._then);

  final _PostMediaModel _self;
  final $Res Function(_PostMediaModel) _then;

  /// Create a copy of PostMediaModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? mediaType = null,
  }) {
    return _then(_PostMediaModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _self.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: null == mediaType
          ? _self.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

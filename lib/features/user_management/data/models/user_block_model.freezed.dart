// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_block_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserBlockModel {
  String get userId; // The blocked user's ID
  DateTime get createdAt;
  bool get isAlt; // Whether this user is considered an alt account
  String? get username; // The blocked user's username
  String? get firstName; // The blocked user's first name
  String? get lastName; // The blocked user's last name
  bool get reported; // Whether this user was also reported
  String? get notes;

  /// Create a copy of UserBlockModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserBlockModelCopyWith<UserBlockModel> get copyWith =>
      _$UserBlockModelCopyWithImpl<UserBlockModel>(
          this as UserBlockModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserBlockModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.reported, reported) ||
                other.reported == reported) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, createdAt, isAlt,
      username, firstName, lastName, reported, notes);

  @override
  String toString() {
    return 'UserBlockModel(userId: $userId, createdAt: $createdAt, isAlt: $isAlt, username: $username, firstName: $firstName, lastName: $lastName, reported: $reported, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class $UserBlockModelCopyWith<$Res> {
  factory $UserBlockModelCopyWith(
          UserBlockModel value, $Res Function(UserBlockModel) _then) =
      _$UserBlockModelCopyWithImpl;
  @useResult
  $Res call(
      {String userId,
      DateTime createdAt,
      bool isAlt,
      String? username,
      String? firstName,
      String? lastName,
      bool reported,
      String? notes});
}

/// @nodoc
class _$UserBlockModelCopyWithImpl<$Res>
    implements $UserBlockModelCopyWith<$Res> {
  _$UserBlockModelCopyWithImpl(this._self, this._then);

  final UserBlockModel _self;
  final $Res Function(UserBlockModel) _then;

  /// Create a copy of UserBlockModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? isAlt = null,
    Object? username = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? reported = null,
    Object? notes = freezed,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      username: freezed == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      reported: null == reported
          ? _self.reported
          : reported // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserBlockModel].
extension UserBlockModelPatterns on UserBlockModel {
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
    TResult Function(_UserBlockModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserBlockModel() when $default != null:
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
    TResult Function(_UserBlockModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserBlockModel():
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
    TResult? Function(_UserBlockModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserBlockModel() when $default != null:
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
            String userId,
            DateTime createdAt,
            bool isAlt,
            String? username,
            String? firstName,
            String? lastName,
            bool reported,
            String? notes)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserBlockModel() when $default != null:
        return $default(
            _that.userId,
            _that.createdAt,
            _that.isAlt,
            _that.username,
            _that.firstName,
            _that.lastName,
            _that.reported,
            _that.notes);
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
            String userId,
            DateTime createdAt,
            bool isAlt,
            String? username,
            String? firstName,
            String? lastName,
            bool reported,
            String? notes)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserBlockModel():
        return $default(
            _that.userId,
            _that.createdAt,
            _that.isAlt,
            _that.username,
            _that.firstName,
            _that.lastName,
            _that.reported,
            _that.notes);
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
            String userId,
            DateTime createdAt,
            bool isAlt,
            String? username,
            String? firstName,
            String? lastName,
            bool reported,
            String? notes)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserBlockModel() when $default != null:
        return $default(
            _that.userId,
            _that.createdAt,
            _that.isAlt,
            _that.username,
            _that.firstName,
            _that.lastName,
            _that.reported,
            _that.notes);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _UserBlockModel extends UserBlockModel {
  const _UserBlockModel(
      {required this.userId,
      required this.createdAt,
      required this.isAlt,
      this.username,
      this.firstName,
      this.lastName,
      this.reported = false,
      this.notes})
      : super._();

  @override
  final String userId;
// The blocked user's ID
  @override
  final DateTime createdAt;
  @override
  final bool isAlt;
// Whether this user is considered an alt account
  @override
  final String? username;
// The blocked user's username
  @override
  final String? firstName;
// The blocked user's first name
  @override
  final String? lastName;
// The blocked user's last name
  @override
  @JsonKey()
  final bool reported;
// Whether this user was also reported
  @override
  final String? notes;

  /// Create a copy of UserBlockModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserBlockModelCopyWith<_UserBlockModel> get copyWith =>
      __$UserBlockModelCopyWithImpl<_UserBlockModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserBlockModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.reported, reported) ||
                other.reported == reported) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @override
  int get hashCode => Object.hash(runtimeType, userId, createdAt, isAlt,
      username, firstName, lastName, reported, notes);

  @override
  String toString() {
    return 'UserBlockModel(userId: $userId, createdAt: $createdAt, isAlt: $isAlt, username: $username, firstName: $firstName, lastName: $lastName, reported: $reported, notes: $notes)';
  }
}

/// @nodoc
abstract mixin class _$UserBlockModelCopyWith<$Res>
    implements $UserBlockModelCopyWith<$Res> {
  factory _$UserBlockModelCopyWith(
          _UserBlockModel value, $Res Function(_UserBlockModel) _then) =
      __$UserBlockModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String userId,
      DateTime createdAt,
      bool isAlt,
      String? username,
      String? firstName,
      String? lastName,
      bool reported,
      String? notes});
}

/// @nodoc
class __$UserBlockModelCopyWithImpl<$Res>
    implements _$UserBlockModelCopyWith<$Res> {
  __$UserBlockModelCopyWithImpl(this._self, this._then);

  final _UserBlockModel _self;
  final $Res Function(_UserBlockModel) _then;

  /// Create a copy of UserBlockModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? createdAt = null,
    Object? isAlt = null,
    Object? username = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? reported = null,
    Object? notes = freezed,
  }) {
    return _then(_UserBlockModel(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      username: freezed == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      reported: null == reported
          ? _self.reported
          : reported // ignore: cast_nullable_to_non_nullable
              as bool,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on

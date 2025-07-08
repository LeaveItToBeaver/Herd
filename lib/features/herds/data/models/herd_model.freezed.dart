// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'herd_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HerdModel implements DiagnosticableTreeMixin {
  String get id;
  String get name;
  String get description;
  List<String?> get interests;
  String get rules;
  String get faq;
  DateTime? get createdAt;
  String get creatorId;
  String? get profileImageURL;
  String? get coverImageURL;
  List<String?> get moderatorIds;
  List<String?> get bannedUserIds;
  List<ModerationAction> get moderationLog;
  List<String?> get reportedPosts;
  int get memberCount;
  int get postCount;
  Map<String, dynamic> get customization;
  bool get isPrivate;
  List<String?> get pinnedPosts;

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HerdModelCopyWith<HerdModel> get copyWith =>
      _$HerdModelCopyWithImpl<HerdModel>(this as HerdModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'HerdModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('interests', interests))
      ..add(DiagnosticsProperty('rules', rules))
      ..add(DiagnosticsProperty('faq', faq))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('creatorId', creatorId))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('moderatorIds', moderatorIds))
      ..add(DiagnosticsProperty('bannedUserIds', bannedUserIds))
      ..add(DiagnosticsProperty('moderationLog', moderationLog))
      ..add(DiagnosticsProperty('reportedPosts', reportedPosts))
      ..add(DiagnosticsProperty('memberCount', memberCount))
      ..add(DiagnosticsProperty('postCount', postCount))
      ..add(DiagnosticsProperty('customization', customization))
      ..add(DiagnosticsProperty('isPrivate', isPrivate))
      ..add(DiagnosticsProperty('pinnedPosts', pinnedPosts));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HerdModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality().equals(other.interests, interests) &&
            (identical(other.rules, rules) || other.rules == rules) &&
            (identical(other.faq, faq) || other.faq == faq) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            const DeepCollectionEquality()
                .equals(other.moderatorIds, moderatorIds) &&
            const DeepCollectionEquality()
                .equals(other.bannedUserIds, bannedUserIds) &&
            const DeepCollectionEquality()
                .equals(other.moderationLog, moderationLog) &&
            const DeepCollectionEquality()
                .equals(other.reportedPosts, reportedPosts) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            const DeepCollectionEquality()
                .equals(other.customization, customization) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            const DeepCollectionEquality()
                .equals(other.pinnedPosts, pinnedPosts));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        const DeepCollectionEquality().hash(interests),
        rules,
        faq,
        createdAt,
        creatorId,
        profileImageURL,
        coverImageURL,
        const DeepCollectionEquality().hash(moderatorIds),
        const DeepCollectionEquality().hash(bannedUserIds),
        const DeepCollectionEquality().hash(moderationLog),
        const DeepCollectionEquality().hash(reportedPosts),
        memberCount,
        postCount,
        const DeepCollectionEquality().hash(customization),
        isPrivate,
        const DeepCollectionEquality().hash(pinnedPosts)
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HerdModel(id: $id, name: $name, description: $description, interests: $interests, rules: $rules, faq: $faq, createdAt: $createdAt, creatorId: $creatorId, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, moderatorIds: $moderatorIds, bannedUserIds: $bannedUserIds, moderationLog: $moderationLog, reportedPosts: $reportedPosts, memberCount: $memberCount, postCount: $postCount, customization: $customization, isPrivate: $isPrivate, pinnedPosts: $pinnedPosts)';
  }
}

/// @nodoc
abstract mixin class $HerdModelCopyWith<$Res> {
  factory $HerdModelCopyWith(HerdModel value, $Res Function(HerdModel) _then) =
      _$HerdModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<String?> interests,
      String rules,
      String faq,
      DateTime? createdAt,
      String creatorId,
      String? profileImageURL,
      String? coverImageURL,
      List<String?> moderatorIds,
      List<String?> bannedUserIds,
      List<ModerationAction> moderationLog,
      List<String?> reportedPosts,
      int memberCount,
      int postCount,
      Map<String, dynamic> customization,
      bool isPrivate,
      List<String?> pinnedPosts});
}

/// @nodoc
class _$HerdModelCopyWithImpl<$Res> implements $HerdModelCopyWith<$Res> {
  _$HerdModelCopyWithImpl(this._self, this._then);

  final HerdModel _self;
  final $Res Function(HerdModel) _then;

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? interests = null,
    Object? rules = null,
    Object? faq = null,
    Object? createdAt = freezed,
    Object? creatorId = null,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? moderatorIds = null,
    Object? bannedUserIds = null,
    Object? moderationLog = null,
    Object? reportedPosts = null,
    Object? memberCount = null,
    Object? postCount = null,
    Object? customization = null,
    Object? isPrivate = null,
    Object? pinnedPosts = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _self.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      rules: null == rules
          ? _self.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as String,
      faq: null == faq
          ? _self.faq
          : faq // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorId: null == creatorId
          ? _self.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageURL: freezed == profileImageURL
          ? _self.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _self.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      moderatorIds: null == moderatorIds
          ? _self.moderatorIds
          : moderatorIds // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      bannedUserIds: null == bannedUserIds
          ? _self.bannedUserIds
          : bannedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      moderationLog: null == moderationLog
          ? _self.moderationLog
          : moderationLog // ignore: cast_nullable_to_non_nullable
              as List<ModerationAction>,
      reportedPosts: null == reportedPosts
          ? _self.reportedPosts
          : reportedPosts // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      memberCount: null == memberCount
          ? _self.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      postCount: null == postCount
          ? _self.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      customization: null == customization
          ? _self.customization
          : customization // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isPrivate: null == isPrivate
          ? _self.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      pinnedPosts: null == pinnedPosts
          ? _self.pinnedPosts
          : pinnedPosts // ignore: cast_nullable_to_non_nullable
              as List<String?>,
    ));
  }
}

/// Adds pattern-matching-related methods to [HerdModel].
extension HerdModelPatterns on HerdModel {
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
    TResult Function(_HerdModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HerdModel() when $default != null:
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
    TResult Function(_HerdModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HerdModel():
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
    TResult? Function(_HerdModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HerdModel() when $default != null:
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
            String name,
            String description,
            List<String?> interests,
            String rules,
            String faq,
            DateTime? createdAt,
            String creatorId,
            String? profileImageURL,
            String? coverImageURL,
            List<String?> moderatorIds,
            List<String?> bannedUserIds,
            List<ModerationAction> moderationLog,
            List<String?> reportedPosts,
            int memberCount,
            int postCount,
            Map<String, dynamic> customization,
            bool isPrivate,
            List<String?> pinnedPosts)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HerdModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.interests,
            _that.rules,
            _that.faq,
            _that.createdAt,
            _that.creatorId,
            _that.profileImageURL,
            _that.coverImageURL,
            _that.moderatorIds,
            _that.bannedUserIds,
            _that.moderationLog,
            _that.reportedPosts,
            _that.memberCount,
            _that.postCount,
            _that.customization,
            _that.isPrivate,
            _that.pinnedPosts);
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
            String name,
            String description,
            List<String?> interests,
            String rules,
            String faq,
            DateTime? createdAt,
            String creatorId,
            String? profileImageURL,
            String? coverImageURL,
            List<String?> moderatorIds,
            List<String?> bannedUserIds,
            List<ModerationAction> moderationLog,
            List<String?> reportedPosts,
            int memberCount,
            int postCount,
            Map<String, dynamic> customization,
            bool isPrivate,
            List<String?> pinnedPosts)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HerdModel():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.interests,
            _that.rules,
            _that.faq,
            _that.createdAt,
            _that.creatorId,
            _that.profileImageURL,
            _that.coverImageURL,
            _that.moderatorIds,
            _that.bannedUserIds,
            _that.moderationLog,
            _that.reportedPosts,
            _that.memberCount,
            _that.postCount,
            _that.customization,
            _that.isPrivate,
            _that.pinnedPosts);
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
            String name,
            String description,
            List<String?> interests,
            String rules,
            String faq,
            DateTime? createdAt,
            String creatorId,
            String? profileImageURL,
            String? coverImageURL,
            List<String?> moderatorIds,
            List<String?> bannedUserIds,
            List<ModerationAction> moderationLog,
            List<String?> reportedPosts,
            int memberCount,
            int postCount,
            Map<String, dynamic> customization,
            bool isPrivate,
            List<String?> pinnedPosts)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HerdModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.interests,
            _that.rules,
            _that.faq,
            _that.createdAt,
            _that.creatorId,
            _that.profileImageURL,
            _that.coverImageURL,
            _that.moderatorIds,
            _that.bannedUserIds,
            _that.moderationLog,
            _that.reportedPosts,
            _that.memberCount,
            _that.postCount,
            _that.customization,
            _that.isPrivate,
            _that.pinnedPosts);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _HerdModel extends HerdModel with DiagnosticableTreeMixin {
  const _HerdModel(
      {required this.id,
      required this.name,
      required this.description,
      final List<String?> interests = const [],
      this.rules = '',
      this.faq = '',
      this.createdAt,
      required this.creatorId,
      this.profileImageURL,
      this.coverImageURL,
      final List<String?> moderatorIds = const [],
      final List<String?> bannedUserIds = const [],
      final List<ModerationAction> moderationLog = const [],
      final List<String?> reportedPosts = const [],
      this.memberCount = 0,
      this.postCount = 0,
      final Map<String, dynamic> customization = const {},
      this.isPrivate = false,
      final List<String?> pinnedPosts = const []})
      : _interests = interests,
        _moderatorIds = moderatorIds,
        _bannedUserIds = bannedUserIds,
        _moderationLog = moderationLog,
        _reportedPosts = reportedPosts,
        _customization = customization,
        _pinnedPosts = pinnedPosts,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  final List<String?> _interests;
  @override
  @JsonKey()
  List<String?> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  @override
  @JsonKey()
  final String rules;
  @override
  @JsonKey()
  final String faq;
  @override
  final DateTime? createdAt;
  @override
  final String creatorId;
  @override
  final String? profileImageURL;
  @override
  final String? coverImageURL;
  final List<String?> _moderatorIds;
  @override
  @JsonKey()
  List<String?> get moderatorIds {
    if (_moderatorIds is EqualUnmodifiableListView) return _moderatorIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moderatorIds);
  }

  final List<String?> _bannedUserIds;
  @override
  @JsonKey()
  List<String?> get bannedUserIds {
    if (_bannedUserIds is EqualUnmodifiableListView) return _bannedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bannedUserIds);
  }

  final List<ModerationAction> _moderationLog;
  @override
  @JsonKey()
  List<ModerationAction> get moderationLog {
    if (_moderationLog is EqualUnmodifiableListView) return _moderationLog;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moderationLog);
  }

  final List<String?> _reportedPosts;
  @override
  @JsonKey()
  List<String?> get reportedPosts {
    if (_reportedPosts is EqualUnmodifiableListView) return _reportedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reportedPosts);
  }

  @override
  @JsonKey()
  final int memberCount;
  @override
  @JsonKey()
  final int postCount;
  final Map<String, dynamic> _customization;
  @override
  @JsonKey()
  Map<String, dynamic> get customization {
    if (_customization is EqualUnmodifiableMapView) return _customization;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customization);
  }

  @override
  @JsonKey()
  final bool isPrivate;
  final List<String?> _pinnedPosts;
  @override
  @JsonKey()
  List<String?> get pinnedPosts {
    if (_pinnedPosts is EqualUnmodifiableListView) return _pinnedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pinnedPosts);
  }

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HerdModelCopyWith<_HerdModel> get copyWith =>
      __$HerdModelCopyWithImpl<_HerdModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'HerdModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('interests', interests))
      ..add(DiagnosticsProperty('rules', rules))
      ..add(DiagnosticsProperty('faq', faq))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('creatorId', creatorId))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('moderatorIds', moderatorIds))
      ..add(DiagnosticsProperty('bannedUserIds', bannedUserIds))
      ..add(DiagnosticsProperty('moderationLog', moderationLog))
      ..add(DiagnosticsProperty('reportedPosts', reportedPosts))
      ..add(DiagnosticsProperty('memberCount', memberCount))
      ..add(DiagnosticsProperty('postCount', postCount))
      ..add(DiagnosticsProperty('customization', customization))
      ..add(DiagnosticsProperty('isPrivate', isPrivate))
      ..add(DiagnosticsProperty('pinnedPosts', pinnedPosts));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HerdModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            const DeepCollectionEquality()
                .equals(other._interests, _interests) &&
            (identical(other.rules, rules) || other.rules == rules) &&
            (identical(other.faq, faq) || other.faq == faq) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            const DeepCollectionEquality()
                .equals(other._moderatorIds, _moderatorIds) &&
            const DeepCollectionEquality()
                .equals(other._bannedUserIds, _bannedUserIds) &&
            const DeepCollectionEquality()
                .equals(other._moderationLog, _moderationLog) &&
            const DeepCollectionEquality()
                .equals(other._reportedPosts, _reportedPosts) &&
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            const DeepCollectionEquality()
                .equals(other._customization, _customization) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            const DeepCollectionEquality()
                .equals(other._pinnedPosts, _pinnedPosts));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        const DeepCollectionEquality().hash(_interests),
        rules,
        faq,
        createdAt,
        creatorId,
        profileImageURL,
        coverImageURL,
        const DeepCollectionEquality().hash(_moderatorIds),
        const DeepCollectionEquality().hash(_bannedUserIds),
        const DeepCollectionEquality().hash(_moderationLog),
        const DeepCollectionEquality().hash(_reportedPosts),
        memberCount,
        postCount,
        const DeepCollectionEquality().hash(_customization),
        isPrivate,
        const DeepCollectionEquality().hash(_pinnedPosts)
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HerdModel(id: $id, name: $name, description: $description, interests: $interests, rules: $rules, faq: $faq, createdAt: $createdAt, creatorId: $creatorId, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, moderatorIds: $moderatorIds, bannedUserIds: $bannedUserIds, moderationLog: $moderationLog, reportedPosts: $reportedPosts, memberCount: $memberCount, postCount: $postCount, customization: $customization, isPrivate: $isPrivate, pinnedPosts: $pinnedPosts)';
  }
}

/// @nodoc
abstract mixin class _$HerdModelCopyWith<$Res>
    implements $HerdModelCopyWith<$Res> {
  factory _$HerdModelCopyWith(
          _HerdModel value, $Res Function(_HerdModel) _then) =
      __$HerdModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      List<String?> interests,
      String rules,
      String faq,
      DateTime? createdAt,
      String creatorId,
      String? profileImageURL,
      String? coverImageURL,
      List<String?> moderatorIds,
      List<String?> bannedUserIds,
      List<ModerationAction> moderationLog,
      List<String?> reportedPosts,
      int memberCount,
      int postCount,
      Map<String, dynamic> customization,
      bool isPrivate,
      List<String?> pinnedPosts});
}

/// @nodoc
class __$HerdModelCopyWithImpl<$Res> implements _$HerdModelCopyWith<$Res> {
  __$HerdModelCopyWithImpl(this._self, this._then);

  final _HerdModel _self;
  final $Res Function(_HerdModel) _then;

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? interests = null,
    Object? rules = null,
    Object? faq = null,
    Object? createdAt = freezed,
    Object? creatorId = null,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? moderatorIds = null,
    Object? bannedUserIds = null,
    Object? moderationLog = null,
    Object? reportedPosts = null,
    Object? memberCount = null,
    Object? postCount = null,
    Object? customization = null,
    Object? isPrivate = null,
    Object? pinnedPosts = null,
  }) {
    return _then(_HerdModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _self._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      rules: null == rules
          ? _self.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as String,
      faq: null == faq
          ? _self.faq
          : faq // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorId: null == creatorId
          ? _self.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageURL: freezed == profileImageURL
          ? _self.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _self.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      moderatorIds: null == moderatorIds
          ? _self._moderatorIds
          : moderatorIds // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      bannedUserIds: null == bannedUserIds
          ? _self._bannedUserIds
          : bannedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      moderationLog: null == moderationLog
          ? _self._moderationLog
          : moderationLog // ignore: cast_nullable_to_non_nullable
              as List<ModerationAction>,
      reportedPosts: null == reportedPosts
          ? _self._reportedPosts
          : reportedPosts // ignore: cast_nullable_to_non_nullable
              as List<String?>,
      memberCount: null == memberCount
          ? _self.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      postCount: null == postCount
          ? _self.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      customization: null == customization
          ? _self._customization
          : customization // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isPrivate: null == isPrivate
          ? _self.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      pinnedPosts: null == pinnedPosts
          ? _self._pinnedPosts
          : pinnedPosts // ignore: cast_nullable_to_non_nullable
              as List<String?>,
    ));
  }
}

// dart format on

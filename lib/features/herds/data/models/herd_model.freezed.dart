// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
  String get rules;
  String get faq;
  DateTime? get createdAt;
  String get creatorId;
  String? get profileImageURL;
  String? get coverImageURL;
  List<String> get moderatorIds;
  int get memberCount;
  int get postCount;
  Map<String, dynamic> get customization;
  bool get isPrivate;

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
      ..add(DiagnosticsProperty('rules', rules))
      ..add(DiagnosticsProperty('faq', faq))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('creatorId', creatorId))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('moderatorIds', moderatorIds))
      ..add(DiagnosticsProperty('memberCount', memberCount))
      ..add(DiagnosticsProperty('postCount', postCount))
      ..add(DiagnosticsProperty('customization', customization))
      ..add(DiagnosticsProperty('isPrivate', isPrivate));
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
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            const DeepCollectionEquality()
                .equals(other.customization, customization) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      rules,
      faq,
      createdAt,
      creatorId,
      profileImageURL,
      coverImageURL,
      const DeepCollectionEquality().hash(moderatorIds),
      memberCount,
      postCount,
      const DeepCollectionEquality().hash(customization),
      isPrivate);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HerdModel(id: $id, name: $name, description: $description, rules: $rules, faq: $faq, createdAt: $createdAt, creatorId: $creatorId, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, moderatorIds: $moderatorIds, memberCount: $memberCount, postCount: $postCount, customization: $customization, isPrivate: $isPrivate)';
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
      String rules,
      String faq,
      DateTime? createdAt,
      String creatorId,
      String? profileImageURL,
      String? coverImageURL,
      List<String> moderatorIds,
      int memberCount,
      int postCount,
      Map<String, dynamic> customization,
      bool isPrivate});
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
    Object? rules = null,
    Object? faq = null,
    Object? createdAt = freezed,
    Object? creatorId = null,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? moderatorIds = null,
    Object? memberCount = null,
    Object? postCount = null,
    Object? customization = null,
    Object? isPrivate = null,
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
              as List<String>,
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
    ));
  }
}

/// @nodoc

class _HerdModel extends HerdModel with DiagnosticableTreeMixin {
  const _HerdModel(
      {required this.id,
      required this.name,
      required this.description,
      this.rules = '',
      this.faq = '',
      this.createdAt,
      required this.creatorId,
      this.profileImageURL,
      this.coverImageURL,
      final List<String> moderatorIds = const [],
      this.memberCount = 0,
      this.postCount = 0,
      final Map<String, dynamic> customization = const {},
      this.isPrivate = false})
      : _moderatorIds = moderatorIds,
        _customization = customization,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
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
  final List<String> _moderatorIds;
  @override
  @JsonKey()
  List<String> get moderatorIds {
    if (_moderatorIds is EqualUnmodifiableListView) return _moderatorIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moderatorIds);
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
      ..add(DiagnosticsProperty('rules', rules))
      ..add(DiagnosticsProperty('faq', faq))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('creatorId', creatorId))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('moderatorIds', moderatorIds))
      ..add(DiagnosticsProperty('memberCount', memberCount))
      ..add(DiagnosticsProperty('postCount', postCount))
      ..add(DiagnosticsProperty('customization', customization))
      ..add(DiagnosticsProperty('isPrivate', isPrivate));
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
            (identical(other.memberCount, memberCount) ||
                other.memberCount == memberCount) &&
            (identical(other.postCount, postCount) ||
                other.postCount == postCount) &&
            const DeepCollectionEquality()
                .equals(other._customization, _customization) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      rules,
      faq,
      createdAt,
      creatorId,
      profileImageURL,
      coverImageURL,
      const DeepCollectionEquality().hash(_moderatorIds),
      memberCount,
      postCount,
      const DeepCollectionEquality().hash(_customization),
      isPrivate);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'HerdModel(id: $id, name: $name, description: $description, rules: $rules, faq: $faq, createdAt: $createdAt, creatorId: $creatorId, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, moderatorIds: $moderatorIds, memberCount: $memberCount, postCount: $postCount, customization: $customization, isPrivate: $isPrivate)';
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
      String rules,
      String faq,
      DateTime? createdAt,
      String creatorId,
      String? profileImageURL,
      String? coverImageURL,
      List<String> moderatorIds,
      int memberCount,
      int postCount,
      Map<String, dynamic> customization,
      bool isPrivate});
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
    Object? rules = null,
    Object? faq = null,
    Object? createdAt = freezed,
    Object? creatorId = null,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? moderatorIds = null,
    Object? memberCount = null,
    Object? postCount = null,
    Object? customization = null,
    Object? isPrivate = null,
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
              as List<String>,
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
    ));
  }
}

// dart format on

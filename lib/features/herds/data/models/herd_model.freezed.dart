// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'herd_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HerdModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get rules => throw _privateConstructorUsedError;
  String get faq => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  String get creatorId => throw _privateConstructorUsedError;
  String? get profileImageURL => throw _privateConstructorUsedError;
  String? get coverImageURL => throw _privateConstructorUsedError;
  List<String> get moderatorIds => throw _privateConstructorUsedError;
  int get memberCount => throw _privateConstructorUsedError;
  int get postCount => throw _privateConstructorUsedError;
  Map<String, dynamic> get customization => throw _privateConstructorUsedError;
  bool get isPrivate => throw _privateConstructorUsedError;

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HerdModelCopyWith<HerdModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HerdModelCopyWith<$Res> {
  factory $HerdModelCopyWith(HerdModel value, $Res Function(HerdModel) then) =
      _$HerdModelCopyWithImpl<$Res, HerdModel>;
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
class _$HerdModelCopyWithImpl<$Res, $Val extends HerdModel>
    implements $HerdModelCopyWith<$Res> {
  _$HerdModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as String,
      faq: null == faq
          ? _value.faq
          : faq // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageURL: freezed == profileImageURL
          ? _value.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _value.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      moderatorIds: null == moderatorIds
          ? _value.moderatorIds
          : moderatorIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      customization: null == customization
          ? _value.customization
          : customization // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HerdModelImplCopyWith<$Res>
    implements $HerdModelCopyWith<$Res> {
  factory _$$HerdModelImplCopyWith(
          _$HerdModelImpl value, $Res Function(_$HerdModelImpl) then) =
      __$$HerdModelImplCopyWithImpl<$Res>;
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
class __$$HerdModelImplCopyWithImpl<$Res>
    extends _$HerdModelCopyWithImpl<$Res, _$HerdModelImpl>
    implements _$$HerdModelImplCopyWith<$Res> {
  __$$HerdModelImplCopyWithImpl(
      _$HerdModelImpl _value, $Res Function(_$HerdModelImpl) _then)
      : super(_value, _then);

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
    return _then(_$HerdModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      rules: null == rules
          ? _value.rules
          : rules // ignore: cast_nullable_to_non_nullable
              as String,
      faq: null == faq
          ? _value.faq
          : faq // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      creatorId: null == creatorId
          ? _value.creatorId
          : creatorId // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageURL: freezed == profileImageURL
          ? _value.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _value.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      moderatorIds: null == moderatorIds
          ? _value._moderatorIds
          : moderatorIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      memberCount: null == memberCount
          ? _value.memberCount
          : memberCount // ignore: cast_nullable_to_non_nullable
              as int,
      postCount: null == postCount
          ? _value.postCount
          : postCount // ignore: cast_nullable_to_non_nullable
              as int,
      customization: null == customization
          ? _value._customization
          : customization // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      isPrivate: null == isPrivate
          ? _value.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$HerdModelImpl extends _HerdModel {
  const _$HerdModelImpl(
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

  @override
  String toString() {
    return 'HerdModel(id: $id, name: $name, description: $description, rules: $rules, faq: $faq, createdAt: $createdAt, creatorId: $creatorId, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, moderatorIds: $moderatorIds, memberCount: $memberCount, postCount: $postCount, customization: $customization, isPrivate: $isPrivate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HerdModelImpl &&
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

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HerdModelImplCopyWith<_$HerdModelImpl> get copyWith =>
      __$$HerdModelImplCopyWithImpl<_$HerdModelImpl>(this, _$identity);
}

abstract class _HerdModel extends HerdModel {
  const factory _HerdModel(
      {required final String id,
      required final String name,
      required final String description,
      final String rules,
      final String faq,
      final DateTime? createdAt,
      required final String creatorId,
      final String? profileImageURL,
      final String? coverImageURL,
      final List<String> moderatorIds,
      final int memberCount,
      final int postCount,
      final Map<String, dynamic> customization,
      final bool isPrivate}) = _$HerdModelImpl;
  const _HerdModel._() : super._();

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get rules;
  @override
  String get faq;
  @override
  DateTime? get createdAt;
  @override
  String get creatorId;
  @override
  String? get profileImageURL;
  @override
  String? get coverImageURL;
  @override
  List<String> get moderatorIds;
  @override
  int get memberCount;
  @override
  int get postCount;
  @override
  Map<String, dynamic> get customization;
  @override
  bool get isPrivate;

  /// Create a copy of HerdModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HerdModelImplCopyWith<_$HerdModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

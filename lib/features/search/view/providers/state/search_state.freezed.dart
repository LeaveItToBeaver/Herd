// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchState implements DiagnosticableTreeMixin {
  List<UserModel> get users; // Users based on current feed type
  List<UserModel> get publicUsers; // Public profile users
  List<UserModel> get altUsers; // Alt profile users
  List<HerdModel> get herds; // Herds list
  SearchStatus get status;
  SearchType get type; // Type of search
  String get lastQuery;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchStateCopyWith<SearchState> get copyWith =>
      _$SearchStateCopyWithImpl<SearchState>(this as SearchState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SearchState'))
      ..add(DiagnosticsProperty('users', users))
      ..add(DiagnosticsProperty('publicUsers', publicUsers))
      ..add(DiagnosticsProperty('altUsers', altUsers))
      ..add(DiagnosticsProperty('herds', herds))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('lastQuery', lastQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchState &&
            const DeepCollectionEquality().equals(other.users, users) &&
            const DeepCollectionEquality()
                .equals(other.publicUsers, publicUsers) &&
            const DeepCollectionEquality().equals(other.altUsers, altUsers) &&
            const DeepCollectionEquality().equals(other.herds, herds) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.lastQuery, lastQuery) ||
                other.lastQuery == lastQuery));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(users),
      const DeepCollectionEquality().hash(publicUsers),
      const DeepCollectionEquality().hash(altUsers),
      const DeepCollectionEquality().hash(herds),
      status,
      type,
      lastQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchState(users: $users, publicUsers: $publicUsers, altUsers: $altUsers, herds: $herds, status: $status, type: $type, lastQuery: $lastQuery)';
  }
}

/// @nodoc
abstract mixin class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) _then) =
      _$SearchStateCopyWithImpl;
  @useResult
  $Res call(
      {List<UserModel> users,
      List<UserModel> publicUsers,
      List<UserModel> altUsers,
      List<HerdModel> herds,
      SearchStatus status,
      SearchType type,
      String lastQuery});
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res> implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._self, this._then);

  final SearchState _self;
  final $Res Function(SearchState) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? users = null,
    Object? publicUsers = null,
    Object? altUsers = null,
    Object? herds = null,
    Object? status = null,
    Object? type = null,
    Object? lastQuery = null,
  }) {
    return _then(_self.copyWith(
      users: null == users
          ? _self.users
          : users // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      publicUsers: null == publicUsers
          ? _self.publicUsers
          : publicUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      altUsers: null == altUsers
          ? _self.altUsers
          : altUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      herds: null == herds
          ? _self.herds
          : herds // ignore: cast_nullable_to_non_nullable
              as List<HerdModel>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SearchStatus,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as SearchType,
      lastQuery: null == lastQuery
          ? _self.lastQuery
          : lastQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _SearchState with DiagnosticableTreeMixin implements SearchState {
  const _SearchState(
      {final List<UserModel> users = const [],
      final List<UserModel> publicUsers = const [],
      final List<UserModel> altUsers = const [],
      final List<HerdModel> herds = const [],
      this.status = SearchStatus.initial,
      this.type = SearchType.all,
      this.lastQuery = ''})
      : _users = users,
        _publicUsers = publicUsers,
        _altUsers = altUsers,
        _herds = herds;

  final List<UserModel> _users;
  @override
  @JsonKey()
  List<UserModel> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

// Users based on current feed type
  final List<UserModel> _publicUsers;
// Users based on current feed type
  @override
  @JsonKey()
  List<UserModel> get publicUsers {
    if (_publicUsers is EqualUnmodifiableListView) return _publicUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_publicUsers);
  }

// Public profile users
  final List<UserModel> _altUsers;
// Public profile users
  @override
  @JsonKey()
  List<UserModel> get altUsers {
    if (_altUsers is EqualUnmodifiableListView) return _altUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altUsers);
  }

// Alt profile users
  final List<HerdModel> _herds;
// Alt profile users
  @override
  @JsonKey()
  List<HerdModel> get herds {
    if (_herds is EqualUnmodifiableListView) return _herds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_herds);
  }

// Herds list
  @override
  @JsonKey()
  final SearchStatus status;
  @override
  @JsonKey()
  final SearchType type;
// Type of search
  @override
  @JsonKey()
  final String lastQuery;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SearchStateCopyWith<_SearchState> get copyWith =>
      __$SearchStateCopyWithImpl<_SearchState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'SearchState'))
      ..add(DiagnosticsProperty('users', users))
      ..add(DiagnosticsProperty('publicUsers', publicUsers))
      ..add(DiagnosticsProperty('altUsers', altUsers))
      ..add(DiagnosticsProperty('herds', herds))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('lastQuery', lastQuery));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SearchState &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            const DeepCollectionEquality()
                .equals(other._publicUsers, _publicUsers) &&
            const DeepCollectionEquality().equals(other._altUsers, _altUsers) &&
            const DeepCollectionEquality().equals(other._herds, _herds) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.lastQuery, lastQuery) ||
                other.lastQuery == lastQuery));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_users),
      const DeepCollectionEquality().hash(_publicUsers),
      const DeepCollectionEquality().hash(_altUsers),
      const DeepCollectionEquality().hash(_herds),
      status,
      type,
      lastQuery);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'SearchState(users: $users, publicUsers: $publicUsers, altUsers: $altUsers, herds: $herds, status: $status, type: $type, lastQuery: $lastQuery)';
  }
}

/// @nodoc
abstract mixin class _$SearchStateCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$SearchStateCopyWith(
          _SearchState value, $Res Function(_SearchState) _then) =
      __$SearchStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<UserModel> users,
      List<UserModel> publicUsers,
      List<UserModel> altUsers,
      List<HerdModel> herds,
      SearchStatus status,
      SearchType type,
      String lastQuery});
}

/// @nodoc
class __$SearchStateCopyWithImpl<$Res> implements _$SearchStateCopyWith<$Res> {
  __$SearchStateCopyWithImpl(this._self, this._then);

  final _SearchState _self;
  final $Res Function(_SearchState) _then;

  /// Create a copy of SearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? users = null,
    Object? publicUsers = null,
    Object? altUsers = null,
    Object? herds = null,
    Object? status = null,
    Object? type = null,
    Object? lastQuery = null,
  }) {
    return _then(_SearchState(
      users: null == users
          ? _self._users
          : users // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      publicUsers: null == publicUsers
          ? _self._publicUsers
          : publicUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      altUsers: null == altUsers
          ? _self._altUsers
          : altUsers // ignore: cast_nullable_to_non_nullable
              as List<UserModel>,
      herds: null == herds
          ? _self._herds
          : herds // ignore: cast_nullable_to_non_nullable
              as List<HerdModel>,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as SearchStatus,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as SearchType,
      lastQuery: null == lastQuery
          ? _self.lastQuery
          : lastQuery // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on

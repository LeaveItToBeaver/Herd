import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../herds/data/models/herd_model.dart';
import '../../../../../user/user_profile/data/models/user_model.dart';

part 'search_state.freezed.dart';

enum SearchStatus { initial, loading, loaded, error }

enum SearchType { users, publicUsers, altUsers, herds, all }

@freezed
abstract class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<UserModel> users, // Users based on current feed type
    @Default([]) List<UserModel> publicUsers, // Public profile users
    @Default([]) List<UserModel> altUsers, // Alt profile users
    @Default([]) List<HerdModel> herds, // Herds list
    @Default(SearchStatus.initial) SearchStatus status,
    @Default(SearchType.all) SearchType type, // Type of search
    @Default('') String lastQuery, // Store the last search query
  }) = _SearchState;

  factory SearchState.initial() => const SearchState();
}

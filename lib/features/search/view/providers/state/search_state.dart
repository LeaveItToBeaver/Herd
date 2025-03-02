import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../user/data/models/user_model.dart';

part 'search_state.freezed.dart';
// Remove the JSON serialization part
// part 'search_state.g.dart';

enum SearchStatus { initial, loading, loaded, error }

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<UserModel> users,
    @Default(SearchStatus.initial) SearchStatus status,
  }) = _SearchState;

  // Remove JSON serialization
  // factory SearchState.fromJson(Map<String, dynamic> json) => _$SearchStateFromJson(json);

  factory SearchState.initial() => const SearchState();
}
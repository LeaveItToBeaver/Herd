import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../herds/data/models/herd_model.dart';
import '../../../../user/data/models/user_model.dart';

part 'search_state.freezed.dart';

enum SearchStatus { initial, loading, loaded, error }
enum SearchType { users, herds, all } // Add a type to control search scope

@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default([]) List<UserModel> users,
    @Default([]) List<HerdModel> herds, // Add herds list
    @Default(SearchStatus.initial) SearchStatus status,
    @Default(SearchType.all) SearchType type, // Type of search
  }) = _SearchState;

  factory SearchState.initial() => const SearchState();
}
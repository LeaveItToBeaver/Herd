import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/search/view/providers/state/search_state.dart';
import '../user/data/repositories/user_repository.dart';

final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  return SearchController(userRepository: userRepository);
});

class SearchController extends StateNotifier<SearchState> {
  final UserRepository _userRepository;

  SearchController({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(SearchState.initial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final users = await _userRepository.searchUsers(query);
      state = state.copyWith(users: users, status: SearchStatus.loaded);
    } catch (err) {
      state = state.copyWith(
        status: SearchStatus.error,
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(users: [], status: SearchStatus.initial);
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/search/view/providers/state/search_state.dart';
import '../herds/data/models/herd_model.dart';
import '../herds/data/repositories/herd_repository.dart';
import '../herds/view/providers/herd_providers.dart';
import '../user/data/models/user_model.dart';
import '../user/data/repositories/user_repository.dart';

final searchControllerProvider = StateNotifierProvider<SearchController, SearchState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);
  return SearchController(
    userRepository: userRepository,
    herdRepository: herdRepository,
  );
});

class SearchController extends StateNotifier<SearchState> {
  final UserRepository _userRepository;
  final HerdRepository _herdRepository;

  SearchController({
    required UserRepository userRepository,
    required HerdRepository herdRepository,
  })  : _userRepository = userRepository,
        _herdRepository = herdRepository,
        super(SearchState.initial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final users = await _userRepository.searchUsers(query);
      state = state.copyWith(
        users: users,
        status: SearchStatus.loaded,
        type: SearchType.users,
      );
    } catch (err) {
      state = state.copyWith(
        status: SearchStatus.error,
      );
    }
  }

  Future<void> searchHerds(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final herds = await _herdRepository.searchHerds(query);
      state = state.copyWith(
        herds: herds,
        status: SearchStatus.loaded,
        type: SearchType.herds,
      );
    } catch (err) {
      state = state.copyWith(
        status: SearchStatus.error,
      );
    }
  }

  Future<void> searchAll(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      // Start both searches (they'll run concurrently)
      final usersResultFuture = _userRepository.searchUsers(query);
      final herdsResultFuture = _herdRepository.searchHerds(query);

      // Wait for each one with proper typing
      final List<UserModel> users = await usersResultFuture;
      final List<HerdModel> herds = await herdsResultFuture;

      state = state.copyWith(
        users: users,
        herds: herds,
        status: SearchStatus.loaded,
        type: SearchType.all,
      );
    } catch (err) {
      state = state.copyWith(
        status: SearchStatus.error,
      );
    }
  }

  void clearSearch() {
    state = state.copyWith(
      users: [],
      herds: [],
      status: SearchStatus.initial,
    );
  }

  void setSearchType(SearchType type) {
    state = state.copyWith(type: type);
  }
}
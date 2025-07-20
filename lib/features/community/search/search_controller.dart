import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/community/herds/data/models/herd_model.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);
  final feedType = ref.watch(currentFeedProvider);
  return SearchController(
    userRepository: userRepository,
    herdRepository: herdRepository,
    feedType: feedType,
  );
});

class SearchController extends StateNotifier<SearchState> {
  final UserRepository _userRepository;
  final HerdRepository _herdRepository;
  final FeedType _feedType;

  SearchController({
    required UserRepository userRepository,
    required HerdRepository herdRepository,
    required FeedType feedType,
  })  : _userRepository = userRepository,
        _herdRepository = herdRepository,
        _feedType = feedType,
        super(SearchState.initial());

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final users =
          await _userRepository.searchUsers(query, profileType: _feedType);
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

  Future<void> searchPublicUsers(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final users = await _userRepository.searchUsers(query,
          profileType: FeedType.public);
      state = state.copyWith(
        publicUsers: users,
        status: SearchStatus.loaded,
        type: SearchType.publicUsers,
      );
    } catch (err) {
      state = state.copyWith(
        status: SearchStatus.error,
      );
    }
  }

  Future<void> searchAltUsers(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final users =
          await _userRepository.searchUsers(query, profileType: FeedType.alt);
      state = state.copyWith(
        altUsers: users,
        status: SearchStatus.loaded,
        type: SearchType.altUsers,
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
      // Execute all searches in parallel
      final List<UserModel> publicUsersResult = await _userRepository
          .searchUsers(query, profileType: FeedType.public);

      final List<UserModel> altUsersResult =
          await _userRepository.searchUsers(query, profileType: FeedType.alt);

      final List<HerdModel> herdsResult =
          await _herdRepository.searchHerds(query);

      // Update state with all results
      state = state.copyWith(
        publicUsers: publicUsersResult,
        altUsers: altUsersResult,
        herds: herdsResult,
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
      publicUsers: [],
      altUsers: [],
      status: SearchStatus.initial,
    );
  }

  void setSearchType(SearchType type) {
    state = state.copyWith(type: type);
  }
}

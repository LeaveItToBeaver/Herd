import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/search/view/providers/state/search_state.dart';

import '../herds/data/models/herd_model.dart';
import '../herds/data/repositories/herd_repository.dart';
import '../herds/view/providers/herd_providers.dart';
import '../user/data/models/user_model.dart';
import '../user/data/repositories/user_repository.dart';

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
      // Start searches concurrently based on current feed type
      final usersResultFuture =
          _userRepository.searchUsers(query, profileType: _feedType);
      final herdsResultFuture = _herdRepository.searchHerds(query);

      // Get both public and alt profiles if using the "All" tab
      final publicUsersResultFuture = _feedType == FeedType.alt
          ? _userRepository.searchUsers(query, profileType: FeedType.public)
          : Future.value(<UserModel>[]);

      final altUsersResultFuture = _feedType == FeedType.public
          ? _userRepository.searchUsers(query, profileType: FeedType.alt)
          : Future.value(<UserModel>[]);

      // Wait for each one with proper typing
      final List<UserModel> users = await usersResultFuture;
      final List<HerdModel> herds = await herdsResultFuture;
      final List<UserModel> publicUsers = await publicUsersResultFuture;
      final List<UserModel> altUsers = await altUsersResultFuture;

      state = state.copyWith(
        users: users,
        herds: herds,
        publicUsers: publicUsers,
        altUsers: altUsers,
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

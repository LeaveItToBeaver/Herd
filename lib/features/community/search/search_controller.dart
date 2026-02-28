import 'package:herdapp/features/community/herds/data/repositories/herd_repository.dart';
import 'package:herdapp/features/community/herds/view/providers/herd_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/community/herds/data/models/herd_model.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

part 'search_controller.g.dart';

@riverpod
class Search extends _$Search {
  late UserRepository _userRepository;
  late HerdRepository _herdRepository;
  late FeedType _feedType;

  @override
  SearchState build() {
    _userRepository = ref.watch(userRepositoryProvider);
    _herdRepository = ref.watch(herdRepositoryProvider);
    _feedType = ref.watch(currentFeedProvider);
    return SearchState.initial();
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      clearSearch();
      return;
    }

    state = state.copyWith(status: SearchStatus.loading);

    try {
      final users =
          await _userRepository.searchUsers(query, profileType: _feedType);

      if (!ref.mounted) return;

      state = state.copyWith(
        users: users,
        status: SearchStatus.loaded,
        type: SearchType.users,
      );
    } catch (err) {
      if (!ref.mounted) return;

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

      if (!ref.mounted) return;

      state = state.copyWith(
        publicUsers: users,
        status: SearchStatus.loaded,
        type: SearchType.publicUsers,
      );
    } catch (err) {
      if (!ref.mounted) return;

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

      if (!ref.mounted) return;

      state = state.copyWith(
        altUsers: users,
        status: SearchStatus.loaded,
        type: SearchType.altUsers,
      );
    } catch (err) {
      if (!ref.mounted) return;

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

      if (!ref.mounted) return;

      state = state.copyWith(
        herds: herds,
        status: SearchStatus.loaded,
        type: SearchType.herds,
      );
    } catch (err) {
      if (!ref.mounted) return;

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

      if (!ref.mounted) return;

      final List<UserModel> altUsersResult =
          await _userRepository.searchUsers(query, profileType: FeedType.alt);

      if (!ref.mounted) return;

      final List<HerdModel> herdsResult =
          await _herdRepository.searchHerds(query);

      if (!ref.mounted) return;

      // Update state with all results
      state = state.copyWith(
        publicUsers: publicUsersResult,
        altUsers: altUsersResult,
        herds: herdsResult,
        status: SearchStatus.loaded,
        type: SearchType.all,
      );
    } catch (err) {
      if (!ref.mounted) return;

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

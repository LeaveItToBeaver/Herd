import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';

import '../../../herds/data/models/herd_model.dart';
import '../../../navigation/view/widgets/BottomNavPadding.dart';
import '../../../user/data/models/user_model.dart';
import '../../search_controller.dart';
import '../providers/state/search_state.dart';

class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = '/search';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Add two new tabs for Public and Alt profiles
    _tabController = TabController(length: 5, vsync: this);

    // Listen to tab changes and update search type
    _tabController.addListener(() {
      final searchType = _getSearchTypeFromTabIndex(_tabController.index);
      ref.read(searchControllerProvider.notifier).setSearchType(searchType);

      // Re-perform search with new type if there's already a query
      if (_textController.text.isNotEmpty) {
        _performSearch(_textController.text);
      }
    });
  }

  SearchType _getSearchTypeFromTabIndex(int index) {
    switch (index) {
      case 0:
        return SearchType.all;
      case 1:
        return SearchType.users;
      case 2:
        return SearchType.publicUsers;
      case 3:
        return SearchType.altUsers;
      case 4:
        return SearchType.herds;
      default:
        return SearchType.all;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final searchType = ref.read(searchControllerProvider).type;

    switch (searchType) {
      case SearchType.users:
        ref.read(searchControllerProvider.notifier).searchUsers(query);
        break;
      case SearchType.publicUsers:
        ref.read(searchControllerProvider.notifier).searchPublicUsers(query);
        break;
      case SearchType.altUsers:
        ref.read(searchControllerProvider.notifier).searchAltUsers(query);
        break;
      case SearchType.herds:
        ref.read(searchControllerProvider.notifier).searchHerds(query);
        break;
      case SearchType.all:
      default:
        ref.read(searchControllerProvider.notifier).searchAll(query);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchControllerProvider);
    final currentFeedType = ref.watch(currentFeedProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurfaceVariant,
                isScrollable: true, // Allow tabs to scroll if needed
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Current Feed'),
                  Tab(text: 'Public Profiles'),
                  Tab(text: 'Alt Profiles'),
                  Tab(text: 'Herds'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // All tab - shows combined results
                    _buildSearchResults(
                      searchState,
                      showBoth: true,
                      showPublic: true,
                      showAlt: true,
                    ),
                    // Current Feed tab - shows users based on current feed type
                    _buildSearchResults(
                      searchState,
                      showUsers: true,
                    ),
                    // Public Profiles tab
                    _buildSearchResults(
                      searchState,
                      showPublic: true,
                    ),
                    // Alt Profiles tab
                    _buildSearchResults(
                      searchState,
                      showAlt: true,
                    ),
                    // Herds tab
                    _buildSearchResults(
                      searchState,
                      showHerds: true,
                    ),
                  ],
                ),
              ),
              // Position search bar at the bottom with padding for nav bar
              _buildSearchBar(),
              BottomNavPadding(
                height: 65.0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
    SearchState state, {
    bool showUsers = false,
    bool showPublic = false,
    bool showAlt = false,
    bool showHerds = false,
    bool showBoth = false,
  }) {
    switch (state.status) {
      case SearchStatus.error:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "An error occurred. Please try again.",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case SearchStatus.loaded:
        return _buildLoadedContent(
            state, showUsers, showPublic, showAlt, showHerds, showBoth);
      case SearchStatus.initial:
      default:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Search for users or herds",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }

  Widget _buildLoadedContent(
    SearchState state,
    bool showUsers,
    bool showPublic,
    bool showAlt,
    bool showHerds,
    bool showBoth,
  ) {
    final currentFeedType = ref.watch(currentFeedProvider);

    // Filter and properly display users based on the current feed type
    List<UserModel> usersToShow = [];
    List<UserModel> publicUsersToShow = [];
    List<UserModel> altUsersToShow = [];

    // For "Current Feed" tab
    if (showUsers || showBoth) {
      usersToShow = state.users;
    }

    // For "Public Profiles" tab - only show when in public feed or specifically requested
    if ((showPublic || showBoth) &&
        (currentFeedType == FeedType.public ||
            state.type == SearchType.publicUsers)) {
      publicUsersToShow = state.publicUsers;
    }

    // For "Alt Profiles" tab
    if (showAlt || showBoth) {
      altUsersToShow = state.altUsers;
    }

    final herdsToShow = (showHerds || showBoth) ? state.herds : [];

    final bool hasAnyResults = usersToShow.isNotEmpty ||
        publicUsersToShow.isNotEmpty ||
        altUsersToShow.isNotEmpty ||
        herdsToShow.isNotEmpty;

    if (!hasAnyResults) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "No results found.",
            style: TextStyle(fontSize: 16.0),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView(
      children: [
        // Current Feed Users Section (Based on current feed type)
        if (usersToShow.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              currentFeedType == FeedType.public
                  ? 'Public Profiles'
                  : 'Alt Profiles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...usersToShow.map((user) => _buildUserListItem(
                user,
                isCurrentFeed: true,
                feedType: currentFeedType,
              )),
          const SizedBox(height: 16),
        ],

        // Public Users Section - only show in public feed or if specifically requesting
        if (publicUsersToShow.isNotEmpty &&
            (currentFeedType == FeedType.public ||
                state.type == SearchType.publicUsers)) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Public Profiles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...publicUsersToShow.map((user) => _buildUserListItem(
                user,
                isPublic: true,
                feedType: FeedType.public,
              )),
          const SizedBox(height: 16),
        ],

        // Alt Users Section
        if (altUsersToShow.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Alt Profiles',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...altUsersToShow.map((user) => _buildUserListItem(
                user,
                isAlt: true,
                feedType: FeedType.alt,
              )),
          const SizedBox(height: 16),
        ],

        // Herds Section
        if (herdsToShow.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Herds',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...herdsToShow.map((herd) => _buildHerdListItem(herd)),
        ],
      ],
    );
  }

  Widget _buildUserListItem(
    UserModel user, {
    bool isPublic = false,
    bool isAlt = false,
    bool isCurrentFeed = false,
    required FeedType feedType,
  }) {
    // STRICT SEPARATION: Determine which profile properties to display based on feed type
    // We never mix public and alt information to maintain anonymity

    // For public profiles
    if (feedType == FeedType.public) {
      final String displayName = '${user.firstName} ${user.lastName}'.trim();
      final String? imageUrl = user.profileImageURL;
      final bool isPrivate = user.isPrivateAccount;
      final hasProfileImage = imageUrl != null && imageUrl.isNotEmpty;

      return ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: Colors.grey[200],
              backgroundImage: hasProfileImage ? NetworkImage(imageUrl) : null,
              child: !hasProfileImage
                  ? Icon(
                      Icons.account_circle,
                      color: Colors.grey[400],
                      size: 22.0 * 2,
                    )
                  : null,
            ),
            if (isPrivate)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey[700],
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontSize: 16.0),
        ),
        subtitle: user.username.isNotEmpty
            ? Text(
                '@${user.username}',
                style: TextStyle(color: Colors.grey[600]),
              )
            : null,
        trailing: Icon(Icons.public, color: Colors.blue, size: 16),
        onTap: () {
          context.pushNamed(
            'publicProfile',
            pathParameters: {'id': user.id},
          );
        },
      );
    }
    // For alt profiles
    else {
      final String displayName = user.altUsername ?? 'Anonymous';
      final String? imageUrl = user.altProfileImageURL;
      final bool isPrivate = user.altIsPrivateAccount;
      final hasProfileImage = imageUrl != null && imageUrl.isNotEmpty;

      return ListTile(
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 22.0,
              backgroundColor: Colors.grey[200],
              backgroundImage: hasProfileImage ? NetworkImage(imageUrl) : null,
              child: !hasProfileImage
                  ? Icon(
                      Icons.masks,
                      color: Colors.grey[400],
                      size: 22.0 * 2,
                    )
                  : null,
            ),
            if (isPrivate)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    color: Colors.grey[700],
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          displayName,
          style: const TextStyle(fontSize: 16.0),
        ),
        // No username subtitle for alt profiles to maintain anonymity
        trailing: Icon(Icons.masks, color: Colors.purple, size: 16),
        onTap: () {
          context.pushNamed(
            'altProfile',
            pathParameters: {'id': user.id},
          );
        },
      );
    }
  }

  Widget _buildHerdListItem(HerdModel herd) {
    // Check if profileImageURL is null or empty
    final hasProfileImage =
        herd.profileImageURL != null && herd.profileImageURL!.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        radius: 22.0,
        backgroundColor: Colors.grey[200],
        // Only use NetworkImage if the URL exists and isn't empty
        backgroundImage:
            hasProfileImage ? NetworkImage(herd.profileImageURL!) : null,
        // Show placeholder icon if no image URL
        child: !hasProfileImage
            ? Icon(
                Icons.group,
                color: Colors.grey[400],
                size: 22.0 * 2,
              )
            : null,
      ),
      title: Text(
        herd.name,
        style: const TextStyle(fontSize: 16.0),
      ),
      subtitle: Text(
        '${herd.memberCount} members',
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: () {
        // Navigate to herd detail screen
        context.pushNamed(
          'herd',
          pathParameters: {'id': herd.id},
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            borderSide: BorderSide(color: Colors.blueGrey, width: 2),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            borderSide: BorderSide(color: Colors.black, width: 2.0),
          ),
          labelText: 'Search Users and Herds',
          labelStyle: const TextStyle(
            color: Colors.black,
            fontFamily: 'OpenSans',
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Colors.black,
          ),
          suffixIcon: IconButton(
            icon: const Icon(
              Icons.clear_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              _textController.clear();
              ref.read(searchControllerProvider.notifier).clearSearch();
            },
          ),
        ),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        onChanged: (value) {
          if (value.trim().isNotEmpty) {
            _performSearch(value.trim());
          } else {
            ref.read(searchControllerProvider.notifier).clearSearch();
          }
        },
      ),
    );
  }
}

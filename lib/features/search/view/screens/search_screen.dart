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

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Listen to tab changes and update search type
    _tabController.addListener(() {
      final searchType = _tabController.index == 0
          ? SearchType.all
          : _tabController.index == 1
          ? SearchType.users
          : SearchType.herds;

      ref.read(searchControllerProvider.notifier).setSearchType(searchType);

      // Re-perform search with new type if there's already a query
      if (_textController.text.isNotEmpty) {
        _performSearch(_textController.text);
      }
    });
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchBar(),
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                tabs: const [
                  Tab(text: 'All'),
                  Tab(text: 'Users'),
                  Tab(text: 'Herds'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSearchResults(searchState, showBoth: true),
                    _buildSearchResults(searchState, showUsers: true),
                    _buildSearchResults(searchState, showHerds: true),
                  ],
                ),
              ),
              BottomNavPadding(
                height: 60.0,
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
        return _buildLoadedContent(state, showUsers, showHerds, showBoth);
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
      bool showHerds,
      bool showBoth,
      ) {
    final hasUsers = showUsers || showBoth;
    final hasHerds = showHerds || showBoth;

    final usersToShow = hasUsers ? state.users : [];
    final herdsToShow = hasHerds ? state.herds : [];

    if (usersToShow.isEmpty && herdsToShow.isEmpty) {
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
        // Show Users Section
        if (usersToShow.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Users',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...usersToShow.map((user) => _buildUserListItem(user)),
          const SizedBox(height: 16),
        ],

        // Show Herds Section
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

  Widget _buildUserListItem(UserModel user) {
    // Check if profileImageURL is null or empty
    final hasProfileImage = user.profileImageURL != null &&
        user.profileImageURL!.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        radius: 22.0,
        backgroundColor: Colors.grey[200],
        // Only use NetworkImage if the URL exists and isn't empty
        backgroundImage: hasProfileImage
            ? NetworkImage(user.profileImageURL!)
            : null,
        // Show placeholder icon if no image URL
        child: !hasProfileImage
            ? Icon(
          Icons.account_circle,
          color: Colors.grey[400],
          size: 22.0 * 2,
        )
            : null,
      ),
      title: Text(
        user.username,
        style: const TextStyle(fontSize: 16.0),
      ),
      onTap: () {
        final feedType = ref.read(currentFeedProvider);
        if (feedType == FeedType.alt) {
          context.pushNamed(
            'altProfile',
            pathParameters: {'id': user.id},
          );
        } else {
          context.pushNamed(
            'publicProfile',
            pathParameters: {'id': user.id},
          );
        }
      },
    );
  }

  Widget _buildHerdListItem(HerdModel herd) {
    // Check if profileImageURL is null or empty
    final hasProfileImage = herd.profileImageURL != null &&
        herd.profileImageURL!.isNotEmpty;

    return ListTile(
      leading: CircleAvatar(
        radius: 22.0,
        backgroundColor: Colors.grey[200],
        // Only use NetworkImage if the URL exists and isn't empty
        backgroundImage: hasProfileImage
            ? NetworkImage(herd.profileImageURL!)
            : null,
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
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50.0)),
            borderSide: BorderSide(color: Color(0xffc2ffc2), width: 2),
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
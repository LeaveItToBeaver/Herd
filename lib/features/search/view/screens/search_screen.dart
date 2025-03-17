import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';
import '../../search_controller.dart';
import '../providers/state/search_state.dart';


// TODO: I need to find out why the search function is broken on the profile page.
// Go to either public or private profile, press search button, get hit with failed contains key error.
class SearchScreen extends ConsumerStatefulWidget {
  static const String routeName = '/search';

  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
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
              Expanded(
                child: _buildSearchResults(searchState),
              ),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchState state) {
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
        return state.users.isNotEmpty
            ? ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (BuildContext context, int index) {
              final user = state.users[index];
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
                  if (feedType == FeedType.private) {
                    context.pushNamed(
                      'privateProfile',
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
            })
            : const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "No users were found.",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case SearchStatus.initial:
      default:
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Search for users",
              style: TextStyle(fontSize: 16.0),
              textAlign: TextAlign.center,
            ),
          ),
        );
    }
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.only(bottom: 10),
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
          labelText: 'Search',
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
            ref.read(searchControllerProvider.notifier).searchUsers(value.trim());
          } else {
            ref.read(searchControllerProvider.notifier).clearSearch();
          }
        },
      ),
    );
  }
}
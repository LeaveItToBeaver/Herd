import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/rich_text_editing/models/user_mention_embed.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

class MentionOverlay extends ConsumerStatefulWidget {
  final QuillController controller;
  final FocusNode focusNode;
  final bool isAlt;
  final Widget child;

  const MentionOverlay({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isAlt,
    required this.child,
  });

  @override
  ConsumerState<MentionOverlay> createState() => _MentionOverlayState();
}

class _MentionOverlayState extends ConsumerState<MentionOverlay> {
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  int _mentionStartIndex = -1;
  final _debouncer = Debouncer(milliseconds: 300);
  List<UserModel> _searchResults = [];
  bool _isSearching = false;
  final LayerLink _layerLink = LayerLink();
  bool _isInsertingMention = false; // Flag to prevent listener during insertion

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    debugPrint("MentionOverlay: initState - Listener added to controller.");
  }

  @override
  void dispose() {
    // Set flag to prevent any operations during disposal
    _isInsertingMention = true;

    // Remove listener first
    widget.controller.removeListener(_onTextChanged);

    // Clean up overlay
    _hideOverlay(resetState: true);

    // Dispose debouncer
    _debouncer.dispose();

    super.dispose();
  }

  void _onTextChanged() {
    // Skip processing if we're currently inserting a mention
    if (_isInsertingMention) {
      debugPrint(
          "MentionOverlay: Skipping _onTextChanged during mention insertion");
      return;
    }

    debugPrint("MentionOverlay: _onTextChanged triggered.");
    final text = widget.controller.document.toPlainText();
    final selection = widget.controller.selection;
    debugPrint(
        "MentionOverlay: Text='${text.replaceAll('\n', '\\n')}', Selection=${selection.toString()}");

    if (!selection.isCollapsed) {
      debugPrint("MentionOverlay: Selection not collapsed, hiding overlay.");
      _hideOverlay(resetState: true);
      return;
    }

    final cursorPosition = selection.baseOffset;
    debugPrint("MentionOverlay: Cursor position: $cursorPosition");

    // Add bounds checking for cursor position
    if (cursorPosition < 0 || cursorPosition > text.length) {
      debugPrint("MentionOverlay: Invalid cursor position, hiding overlay.");
      _hideOverlay(resetState: true);
      return;
    }

    int atIndex = -1;
    final searchStart = (cursorPosition - 20).clamp(0, cursorPosition);
    for (int i = cursorPosition - 1; i >= searchStart; i--) {
      if (i < text.length && text[i] == '@') {
        debugPrint(
            "MentionOverlay: Found '@' at index $i. Char before: ${i > 0 ? text[i - 1] : 'START'}");
        if (i == 0 || (i > 0 && (text[i - 1] == ' ' || text[i - 1] == '\n'))) {
          atIndex = i;
          debugPrint("MentionOverlay: Valid '@' found at index $atIndex");
          break;
        } else {
          debugPrint(
              "MentionOverlay: Invalid '@' at index $i (not preceded by space/newline or not at start).");
        }
      }
    }

    if (atIndex >= 0) {
      // Add bounds checking for substring operation
      if (atIndex + 1 <= text.length && cursorPosition <= text.length) {
        final query = text.substring(atIndex + 1, cursorPosition);
        debugPrint("MentionOverlay: Potential mention query: '$query'");

        if (!query.contains(' ') && !query.contains('\n')) {
          _mentionStartIndex = atIndex;
          _searchQuery = query;
          debugPrint(
              "MentionOverlay: Debouncer will run for query: '$_searchQuery'");
          _debouncer.run(() => _searchUsers(query));
          return;
        } else {
          debugPrint(
              "MentionOverlay: Query contains space or newline after @, ending mention attempt.");
        }
      } else {
        debugPrint(
            "MentionOverlay: Invalid substring bounds, ending mention attempt.");
      }
    } else {
      debugPrint(
          "MentionOverlay: No valid '@' for mention, ending mention attempt.");
    }

    _hideOverlay(resetState: true);
  }

  Future<void> _searchUsers(String query) async {
    debugPrint("MentionOverlay: _searchUsers called with query: '$query'");
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      _showOverlay();
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final results = await userRepository.searchUsers(
        query,
        profileType: widget.isAlt ? FeedType.alt : FeedType.public,
      );

      if (mounted) {
        setState(() {
          _searchResults = results.take(5).toList();
          _isSearching = false;
        });
        _showOverlay();
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _showOverlay() {
    debugPrint(
        "MentionOverlay: _showOverlay called. Search query: '$_searchQuery', Results: ${_searchResults.length}");
    _hideOverlay(resetState: false);

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("MentionOverlay: RenderBox is null, cannot show overlay.");
      return;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: renderBox.size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(16, 22),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: 200,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _buildSearchResults(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchQuery.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'No users found for "$_searchQuery"',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Type to search users',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final user = _searchResults[index];
        final displayName = widget.isAlt
            ? user.username
            : '${user.firstName} ${user.lastName}'.trim();

        return InkWell(
          onTap: () {
            final int startIndexForThisTap = _mentionStartIndex;
            _insertMention(user, startIndexForThisTap);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: user.profileImageURL != null
                      ? NetworkImage(user.profileImageURL!)
                      : null,
                  child: user.profileImageURL == null
                      ? const Icon(Icons.person, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '@${user.username}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _insertMention(UserModel user, int capturedStartIndex) async {
    final displayName = widget.isAlt
        ? user.username
        : '${user.firstName} ${user.lastName}'.trim();

    final selection = widget.controller.selection;
    final replaceStart = capturedStartIndex;
    final replaceEnd = selection.baseOffset;
    final lengthToReplace = replaceEnd - replaceStart;

    debugPrint(
        "MentionOverlay: _insertMention called for user: ${user.username}");
    debugPrint("MentionOverlay: capturedStartIndex = $capturedStartIndex");
    debugPrint("MentionOverlay: current selection = $selection");
    debugPrint("MentionOverlay: replaceStart (from captured) = $replaceStart");
    debugPrint("MentionOverlay: replaceEnd = $replaceEnd");
    debugPrint("MentionOverlay: length to replace = $lengthToReplace");

    final mentionData = MentionData(
      userId: user.id,
      username: user.username,
      displayName: displayName,
    );

    if (replaceStart < 0 || lengthToReplace < 0) {
      debugPrint(
          "MentionOverlay: ERROR - Invalid replaceStart or lengthToReplace. Aborting.");
      _hideOverlay(resetState: true);
      widget.focusNode.requestFocus();
      return;
    }

    try {
      // Set flag to prevent listener from processing changes during insertion
      _isInsertingMention = true;

      // Hide overlay immediately and reset state
      _hideOverlay(resetState: true);

      // Single operation: replace the @mention text with embed + space
      final embed = BlockEmbed.custom(
        UserMentionEmbed(jsonEncode(mentionData.toJson())),
      );

      // Calculate final cursor position (after embed + space)
      final finalCursorPos = replaceStart + 2; // embed(1) + space(1)

      // Replace @username with embed
      widget.controller.replaceText(
        replaceStart,
        lengthToReplace,
        embed,
        TextSelection.collapsed(offset: replaceStart + 1),
      );

      // Add a small delay to ensure the first operation completes
      await Future.delayed(Duration(milliseconds: 10));

      // Insert space after the embed
      widget.controller.replaceText(
        replaceStart + 1,
        0,
        ' ',
        TextSelection.collapsed(offset: finalCursorPos),
      );

      // Add another small delay
      await Future.delayed(Duration(milliseconds: 10));

      // Final cursor positioning
      widget.controller.updateSelection(
        TextSelection.collapsed(offset: finalCursorPos),
        ChangeSource.local,
      );

      debugPrint(
          "MentionOverlay: After updateSelection. New selection: ${widget.controller.selection}");
    } catch (e) {
      debugPrint("MentionOverlay: Error during mention insertion: $e");
    } finally {
      // Re-enable the listener
      _isInsertingMention = false;

      // Request focus back to the editor
      widget.focusNode.requestFocus();
      debugPrint("MentionOverlay: _insertMention completed.");
    }
  }

  void _hideOverlay({bool resetState = true}) {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      debugPrint("MentionOverlay: Error removing overlay: $e");
    }

    if (resetState) {
      _mentionStartIndex = -1;
      _searchQuery = '';
      if (mounted) {
        try {
          setState(() {
            _searchResults = [];
            _isSearching = false;
          });
        } catch (e) {
          debugPrint("MentionOverlay: Error setting state during reset: $e");
        }
      }
      debugPrint(
          "MentionOverlay: Overlay hidden AND state fully reset (mentionStartIndex, searchQuery, searchResults).");
    } else {
      debugPrint("MentionOverlay: Overlay entry removed (state NOT reset).");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.child,
    );
  }
}

// Debouncer to avoid too many search requests
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

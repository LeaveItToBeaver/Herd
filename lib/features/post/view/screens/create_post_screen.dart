import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';

import '../../../drafts/view/widgets/save_draft_dialog.dart';
import '../../../navigation/view/widgets/BottomNavPadding.dart';
import '../../../user/view/providers/current_user_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final bool isAlt;
  final String? herdId;

  const CreatePostScreen({
    super.key,
    this.isAlt = false, // Default to false for public posts
    this.herdId, // Optional herd ID for posting to a specific herd
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  File? _postMedia;
  bool _isSubmitting = false;
  late bool _isAlt;
  late bool _isDraft = false;
  late bool _hasMedia = false;
  late bool _isNSFW = false;
  final bool _isVideo = false;
  String? _selectedHerdId;
  String? _selectedHerdName;
  String? _selectHerdProfileImageUrl;
  bool _hasEnteredContent = false;
  bool _isHerdPost = false;

  @override
  void initState() {
    super.initState();

    // Debug log the received herdId parameter
    if (kDebugMode) {
      print('CreatePostScreen received herdId: ${widget.herdId}');
    }

    // Initialize with the provided values
    _isAlt = widget.isAlt;
    _selectedHerdId = widget.herdId;

    // If we have a herdId, fetch the herd name
    if (_selectedHerdId != null) {
      _fetchHerdInfo();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Start monitoring content changes for draft saving
    _checkContentEntered();
  }

// This method tracks when content is entered
  void _checkContentEntered() {
    // Check if title or content fields have text
    setState(() {
      _hasEnteredContent = _title.isNotEmpty || _content.isNotEmpty;
    });
  }

// Add this method to fetch the herd name when a herdId is provided
  void _fetchHerdInfo() async {
    try {
      final herd = await ref.read(herdProvider(_selectedHerdId!).future);
      if (mounted && herd != null) {
        setState(() {
          _selectedHerdName = herd.name;
          _selectHerdProfileImageUrl = herd.profileImageURL;
          if (kDebugMode) {
            print('Fetched herd name: $_selectedHerdName');
          }
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching herd name: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postControllerProvider);
    final currentUserAsync =
        ref.watch(currentUserProvider); // Changed read to watch
    final userId = currentUserAsync.userId;
    final currentFeed = ref.watch(currentFeedProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        final canPop = await _handlePopScope();
        if (canPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text("Create A Post"),
            actions: [
              if (_isSubmitting)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          body: currentUserAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (user) {
              if (user == null) {
                return const Center(
                    child: Text('You must be logged in to create a post'));
              }

              return postState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _buildForm(context, user),
                data: (_) => _buildForm(context, user),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserModel currentUser) {
    // Get theme for consistent styling
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy toggle card at the top
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _isNSFW && _isAlt
                    ? Colors.purple
                    : _isNSFW && !_isAlt
                        ? Colors.red
                        : _isAlt
                            ? Colors.blue
                            : Colors.black,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alt post toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isAlt ? Icons.public : Icons.public_off,
                                color: _isAlt ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isAlt ? 'Alt Post' : 'Regular Post',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _isAlt ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isAlt
                                ? 'Post with your alt profile'
                                : 'Post with your main profile',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Switch(
                        value: _isAlt,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _isAlt = value;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // NSFW toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                  _isNSFW
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility,
                                  color: _isNSFW && _isAlt
                                      ? Colors.purple
                                      : _isNSFW && !_isAlt
                                          ? Colors.red
                                          : Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _isNSFW ? 'NSFW' : 'SFW',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    color: _isNSFW && _isAlt
                                        ? Colors.purple
                                        : _isNSFW && !_isAlt
                                            ? Colors.red
                                            : Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isNSFW
                                ? 'Sensitive content warning'
                                : 'No sensitive content',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      Switch(
                        value: _isNSFW,
                        activeColor:
                            _isNSFW && _isAlt ? Colors.purple : Colors.red,
                        onChanged: (value) {
                          setState(() {
                            _isNSFW = value;
                          });
                        },
                      ),
                    ],
                  ),

                  // Media Toggle
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _hasMedia
                                    ? Icons.image
                                    : Icons.image_not_supported_outlined,
                                color:
                                    _hasMedia ? Colors.green[700] : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _hasMedia ? 'Media' : 'No Media',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _hasMedia
                                      ? Colors.green[700]
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          if (_hasMedia) const SizedBox(height: 2),
                          if (_hasMedia)
                            Text(
                              'Post with media',
                              style: theme.textTheme.bodyMedium,
                            ),
                        ],
                      ),
                      Switch(
                        value: _hasMedia,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _hasMedia = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),
          // Herd selection card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _isNSFW && _isAlt
                    ? Colors.purple
                    : _isNSFW && !_isAlt
                        ? Colors.red
                        : _isAlt
                            ? Colors.blue
                            : Colors.black,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Posting To',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _showHerdSelectionDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isNSFW && _isAlt
                              ? Colors.purple
                              : _isNSFW && !_isAlt
                                  ? Colors.red
                                  : _isAlt
                                      ? Colors.blue
                                      : Colors.black,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedHerdId != null
                                ? Icons.group
                                : Icons.person,
                            size: 18,
                            color: _selectedHerdId != null
                                ? Colors.blue
                                : _isNSFW && _isAlt
                                    ? Colors.purple
                                    : _isNSFW && !_isAlt
                                        ? Colors.red
                                        : _isAlt
                                            ? Colors.blue
                                            : Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _selectedHerdId != null
                                  ? '$_selectedHerdName'
                                  : 'Personal post (no herd)',
                              style: TextStyle(
                                color: _selectedHerdId != null
                                    ? Colors.blue
                                    : _isNSFW && _isAlt
                                        ? Colors.purple
                                        : _isNSFW && !_isAlt
                                            ? Colors.red
                                            : _isAlt
                                                ? Colors.blue
                                                : Colors.grey,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Post form
          _buildPostForm(context),

          const SizedBox(height: 16),

          // Submit button at the bottom
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.send,
                color: Colors.white,
              ),
              label: Text(
                _isAlt ? 'Create Alt Post' : 'Create Post',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNSFW && _isAlt
                    ? Colors.purple
                    : _isNSFW && !_isAlt
                        ? Colors.red
                        : _isAlt
                            ? Colors.blue
                            : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      if (currentUser != null) {
                        _submitForm(context, currentUser);
                      }
                    },
            ),
          ),

          BottomNavPadding(), // Add padding to avoid bottom nav bar overlap
        ],
      ),
    );
  }

  // Media picker widget
  List<File> _mediaFiles = [];
  int _currentMediaIndex = 0;

  Widget _mediaPicker(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () async {
            if (_isSubmitting)
              return; // Prevent changing media while submitting

            try {
              // Use the image picker to select multiple images
              final pickedFiles = await ImageHelper.pickMultipleMediaFiles(
                context: context,
              );

              if (pickedFiles != null && pickedFiles.isNotEmpty) {
                setState(() {
                  _mediaFiles = pickedFiles;
                  _currentMediaIndex = 0;
                  _postMedia = _mediaFiles.first; // For backward compatibility
                });
              }
            } catch (e) {
              if (context.mounted) {
                _showErrorSnackBar(
                    context, 'Failed to pick media. Please try again.');
              }
            }
          },
          child: Container(
            height: MediaQuery.of(context).size.height / 3,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isNSFW && _isAlt
                    ? Colors.purple
                    : _isNSFW && !_isAlt
                        ? Colors.red
                        : _isAlt
                            ? Colors.blue
                            : Colors.grey,
              ),
            ),
            child: _mediaFiles.isNotEmpty
                ? _buildMediaFilesPreview()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 64,
                        color: _isNSFW && _isAlt
                            ? Colors.purple
                            : _isNSFW && !_isAlt
                                ? Colors.red
                                : _isAlt
                                    ? Colors.blue
                                    : Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add media (up to 10 images/videos)',
                        style: TextStyle(
                          color: _isNSFW && _isAlt
                              ? Colors.purple
                              : _isNSFW && !_isAlt
                                  ? Colors.red
                                  : _isAlt
                                      ? Colors.blue
                                      : Colors.black54,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        // Show carousel controls if there are multiple media files
        if (_mediaFiles.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _currentMediaIndex > 0
                      ? () {
                          setState(() {
                            _currentMediaIndex--;
                            _postMedia = _mediaFiles[_currentMediaIndex];
                          });
                        }
                      : null,
                ),
                Text('${_currentMediaIndex + 1}/${_mediaFiles.length}'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _currentMediaIndex < _mediaFiles.length - 1
                      ? () {
                          setState(() {
                            _currentMediaIndex++;
                            _postMedia = _mediaFiles[_currentMediaIndex];
                          });
                        }
                      : null,
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _mediaFiles.removeAt(_currentMediaIndex);
                      if (_mediaFiles.isEmpty) {
                        _currentMediaIndex = 0;
                        _postMedia = null;
                      } else if (_currentMediaIndex >= _mediaFiles.length) {
                        _currentMediaIndex = _mediaFiles.length - 1;
                        _postMedia = _mediaFiles[_currentMediaIndex];
                      } else {
                        _postMedia = _mediaFiles[_currentMediaIndex];
                      }
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMediaFilesPreview() {
    if (_mediaFiles.isEmpty) return const SizedBox.shrink();

    final currentFile = _mediaFiles[_currentMediaIndex];
    final extension = currentFile.path.toLowerCase().substring(
          currentFile.path.lastIndexOf('.'),
        );

    final isVideo =
        ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension);
    final isGif = extension == '.gif';

    if (isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: _isNSFW && _isAlt
                  ? Colors.purple
                  : _isNSFW && !_isAlt
                      ? Colors.red
                      : _isAlt
                          ? Colors.blue
                          : Colors.grey,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam,
                    size: 48,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Video',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    extension.toUpperCase(),
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            currentFile,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        if (isGif)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'GIF',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPostForm(BuildContext context) {
    final borderColor = _isNSFW && _isAlt
        ? Colors.purple
        : _isNSFW && !_isAlt
            ? Colors.red
            : _isAlt
                ? Colors.blue
                : Colors.grey;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: _isNSFW && _isAlt
                        ? Colors.purple
                        : _isNSFW && !_isAlt
                            ? Colors.red
                            : _isAlt
                                ? Colors.blue
                                : Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _isNSFW && _isAlt
                      ? Colors.purple
                      : _isNSFW && !_isAlt
                          ? Colors.red
                          : _isAlt
                              ? Colors.blue
                              : Colors.grey,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.title,
                color: _isNSFW && _isAlt
                    ? Colors.purple
                    : _isNSFW && !_isAlt
                        ? Colors.red
                        : _isAlt
                            ? Colors.blue
                            : Colors.grey,
              ),
            ),
            onChanged: (value) {
              _title = value;
              _checkContentEntered();
            },
            validator: (value) => value == null || value.isEmpty
                ? 'Title cannot be empty.'
                : null,
          ),
          const SizedBox(height: 8),

          // Media picker
          if (_hasMedia) _mediaPicker(context),

          const SizedBox(height: 8),
          TextFormField(
            enabled: !_isSubmitting,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: 'Content',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    width: 2,
                    color: _isNSFW && _isAlt
                        ? Colors.purple
                        : _isNSFW && !_isAlt
                            ? Colors.red
                            : _isAlt
                                ? Colors.blue
                                : Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  width: 2,
                  color: _isNSFW && _isAlt
                      ? Colors.purple
                      : _isNSFW && !_isAlt
                          ? Colors.red
                          : _isAlt
                              ? Colors.blue
                              : Colors.black,
                ),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Icon(
                  Icons.article,
                  color: _isNSFW && _isAlt
                      ? Colors.purple
                      : _isNSFW && !_isAlt
                          ? Colors.red
                          : _isAlt
                              ? Colors.blue
                              : Colors.black,
                ),
              ),
            ),
            onChanged: (value) {
              _content = value;
              _checkContentEntered();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, UserModel currentUser) async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      debugPrint("Submitting post with ${_mediaFiles.length} media files");

      final postId = await ref.read(postControllerProvider.notifier).createPost(
            title: _title,
            content: _content,
            // Pass the list of media files, not just the first one
            mediaFiles: _mediaFiles,
            userId: currentUser.id,
            isAlt: _isAlt,
            isNSFW: _isNSFW,
            herdId: _selectedHerdId ?? '',
            herdName: _selectedHerdName ?? '',
            herdProfileImageURL: _selectHerdProfileImageUrl ?? '',
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAlt
                ? 'Alt post created successfully!'
                : 'Post created successfully!'),
            backgroundColor: _isNSFW && _isAlt
                ? Colors.purple
                : _isNSFW && !_isAlt
                    ? Colors.red
                    : _isAlt
                        ? Colors.blue
                        : Colors.black,
          ),
        );

        // Navigate to the post
        context.pushNamed(
          'post',
          pathParameters: {'id': postId},
          queryParameters: {'isAlt': _isAlt.toString()},
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          context,
          'There was an issue creating the post: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Widget _buildMediaPreview() {
  //   if (_postMedia == null) return const SizedBox.shrink();
  //
  //   final extension = _postMedia!.path.toLowerCase().substring(
  //         _postMedia!.path.lastIndexOf('.'),
  //       );
  //
  //   if (_isVideo) {
  //     return Stack(
  //       alignment: Alignment.center,
  //       children: [
  //         ClipRRect(
  //             borderRadius: BorderRadius.circular(12),
  //             child: Container(
  //               color: Colors.black87,
  //               width: double.infinity,
  //               height: double.infinity,
  //               child: Center(
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   children: [
  //                     const Icon(
  //                       Icons.videocam,
  //                       size: 48,
  //                       color: Colors.white70,
  //                     ),
  //                     const SizedBox(height: 8),
  //                     const Text(
  //                       'Video',
  //                       style: TextStyle(
  //                           color: Colors.white, fontWeight: FontWeight.bold),
  //                     ),
  //                     const SizedBox(height: 4),
  //                     Text(
  //                       extension.toUpperCase(),
  //                       style: const TextStyle(
  //                           color: Colors.white54, fontSize: 12),
  //                     )
  //                   ],
  //                 ),
  //               ),
  //             )),
  //         Icon(
  //           Icons.play_circle_fill,
  //           size: 64,
  //           color: Colors.white.withOpacity(0.8),
  //         ),
  //       ],
  //     );
  //   }
  //
  //   if (extension == '.gif') {
  //     return Stack(children: [
  //       ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Image.file(_postMedia!,
  //             fit: BoxFit.cover,
  //             width: double.infinity,
  //             height: double.infinity),
  //       ),
  //       Positioned(
  //         bottom: 8,
  //         right: 8,
  //         child: Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //           decoration: BoxDecoration(
  //             color: Colors.black.withOpacity(0.6),
  //             borderRadius: BorderRadius.circular(4),
  //           ),
  //           child: const Text(
  //             'GIF',
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ),
  //     ]);
  //   }
  //
  //   return ClipRRect(
  //     borderRadius: BorderRadius.circular(12),
  //     child: Image.file(_postMedia!,
  //         fit: BoxFit.cover, width: double.infinity, height: double.infinity),
  //   );
  // }

  Future<void> _showHerdSelectionDialog() async {
    final userHerds = await ref.read(userHerdsProvider.future);

    if (!mounted) return;

    final selectedHerd = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a Herd'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: userHerds.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  // No Herd option
                  return ListTile(
                    leading: const Icon(Icons.group_off),
                    title: const Text('No Herd'),
                    selected: _selectedHerdId == null,
                    onTap: () {
                      setState(() {
                        _selectedHerdId = null;
                        _selectedHerdName = null;
                      });
                      Navigator.of(context).pop(null);
                    },
                  );
                }

                final herd = userHerds[index - 1];

                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: herd.profileImageURL != null
                        ? NetworkImage(herd.profileImageURL!)
                        : null,
                    child: herd.profileImageURL == null
                        ? const Icon(Icons.group)
                        : null,
                  ),
                  title: Text(herd.name),
                  subtitle: Text(herd.description),
                  selected: _selectedHerdId == herd.id,
                  onTap: () {
                    setState(() {
                      _selectedHerdId = herd.id;
                      _selectedHerdName = herd.name;
                    });
                    Navigator.of(context).pop(herd.id);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<bool> _handlePopScope() async {
    // If no content entered or submitting, allow navigation without prompt
    if (!_hasEnteredContent || _isSubmitting) {
      return true;
    }

    // If user has selected media files, don't show draft dialog
    // as we don't support media in drafts
    if (_mediaFiles.isNotEmpty) {
      final shouldDiscard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Post?'),
          content: const Text(
              'You have uploaded media files which cannot be saved as drafts. '
              'Do you want to discard this post?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Discard'),
            ),
          ],
        ),
      );

      return shouldDiscard ?? false;
    }

    // Show the save draft dialog for text-only posts
    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (context) => SaveDraftDialog(
        title: _title,
        content: _content,
        isAlt: _isAlt,
        herdId: _selectedHerdId,
        herdName: _selectedHerdName,
      ),
    );

    return shouldNavigate ?? false;
  }
}

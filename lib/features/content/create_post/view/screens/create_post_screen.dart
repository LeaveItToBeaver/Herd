import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/content/create_post/create_post_controller.dart';
import 'package:herdapp/features/content/rich_text_editing/utils/mention_embed_builder.dart';
import 'package:herdapp/features/content/rich_text_editing/utils/mention_extractor.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';

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
  final String _content = '';
  File? _postMedia;
  bool _isSubmitting = false;
  late bool _isAlt;
  late final bool _isDraft = false;
  late bool _hasMedia = false;
  late bool _isNSFW = false;
  final bool _isVideo = false;
  String? _selectedHerdId;
  String? _selectedHerdName;
  String? _selectHerdProfileImageUrl;
  bool _hasEnteredContent = false;
  final bool _isHerdPost = false;
  late quill.QuillController _contentController;
  late FocusNode _editorFocusNode;
  late ScrollController _editorScrollController;
  final List<String> _postTags = [];

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
    _contentController = quill.QuillController.basic();

    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();

    _contentController.addListener(_extractTagsFromContent);

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

  @override
  void dispose() {
    // Set submitting to false to prevent any ongoing operations
    _isSubmitting = false;

    // Dispose controllers
    _contentController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();

    super.dispose();
  }

  @override
  void deactivate() {
    // Stop any ongoing submissions
    _isSubmitting = false;
    super.deactivate();
  }

  // bool get _canPerformUIOperations =>
  //     mounted && context.mounted && !_isSubmitting;

  // bool _validateForm() {
  //   if (!_canPerformUIOperations) return false;
  //   return _formKey.currentState?.validate() ?? false;
  // }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

// This method tracks when content is entered
  void _checkContentEntered() {
    if (!mounted) return;

    _safeSetState(() {
      _hasEnteredContent = _title.isNotEmpty || _content.isNotEmpty;
    });
  }

// Add this method to fetch the herd name when a herdId is provided
  void _fetchHerdInfo() async {
    if (!mounted) return;

    try {
      final herd = await ref.read(herdProvider(_selectedHerdId!).future);
      if (mounted && herd != null) {
        _safeSetState(() {
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

  void _extractTagsFromContent() {
    if (!mounted) return;

    final String text = _contentController.document.toPlainText();
    final RegExp tagRegExp = RegExp(r'#(\w+)');

    final List<String> currentTags = [];
    tagRegExp.allMatches(text).forEach((match) {
      final tag = match.group(1);
      if (tag != null && tag.isNotEmpty) {
        currentTags.add(tag.toLowerCase());
      }
    });

    debugPrint('検出されたタグ: ${currentTags.join(', ')}');

    // 現在のタグリストと抽出したタグリストを比較し、_postTagsを更新
    // 重複を排除し、新しいタグのみを追加
    _safeSetState(() {
      _postTags
        ..clear() // 一度クリアして再構築するか、差分更新するかは要検討。シンプルにクリア。
        ..addAll(currentTags.toSet().toList()); // Setで重複排除後、Listに戻す
      _checkContentEntered(); // コンテンツ変更を通知
    });
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(createPostControllerProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Always allow pop if submitting to avoid blocking navigation
        if (_isSubmitting) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
          return;
        }

        final canPop = await _handlePopScope();
        if (canPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            //backgroundColor: Colors.white,
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
                      color: Colors.grey,
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
                            : Theme.of(context).colorScheme.primary,
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
                            // Clear selected media when disabling media
                            if (!value) {
                              _mediaFiles.clear();
                              _postMedia = null;
                              _currentMediaIndex = 0;
                            }
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Herd selection card
          if (_isAlt)
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
                              : Theme.of(context).colorScheme.primary,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //const SizedBox(height: 6),
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
                    const SizedBox(height: 6),
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
                                        : Theme.of(context).colorScheme.primary,
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
                                    : 'Personal post',
                                style: TextStyle(
                                  color: _selectedHerdId != null
                                      ? Colors.blue
                                      : _isNSFW && _isAlt
                                          ? Colors.purple
                                          : _isNSFW && !_isAlt
                                              ? Colors.red
                                              : _isAlt
                                                  ? Colors.blue
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down,
                              color: _selectedHerdId != null
                                  ? Colors.blue
                                  : _isNSFW && _isAlt
                                      ? Colors.purple
                                      : _isNSFW && !_isAlt
                                          ? Colors.red
                                          : _isAlt
                                              ? Colors.blue
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Post form
          _buildPostForm(context),

          const SizedBox(height: 12),

          // Submit button at the bottom
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(
                Icons.send,
                color: _isNSFW && _isAlt
                    ? Colors.black
                    : _isNSFW && !_isAlt
                        ? Colors.black
                        : _isAlt
                            ? Colors.black
                            : Colors.white,
              ),
              label: Text(
                _isAlt ? 'Create Alt Post' : 'Create Post',
                style: TextStyle(
                    color: _isNSFW && _isAlt
                        ? Colors.black
                        : _isNSFW && !_isAlt
                            ? Colors.black
                            : _isAlt
                                ? Colors.black
                                : Colors.white,
                    fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isNSFW && _isAlt
                    ? Colors.purple
                    : _isNSFW && !_isAlt
                        ? Colors.red
                        : _isAlt
                            ? Colors.blue
                            : Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                      _submitForm(context, currentUser);
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

  Future<List<Map<String, dynamic>>> _processMediaFiles() async {
    List<Map<String, dynamic>> processedMedia = [];

    for (int i = 0; i < _mediaFiles.length; i++) {
      final file = _mediaFiles[i];
      final extension = file.path.toLowerCase().substring(
            file.path.lastIndexOf('.'),
          );

      final isVideo =
          ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension);

      if (isVideo) {
        //  Thumbnail generation is commented out for now
        // Generate thumbnail for video
        // final thumbnailFile =
        //     await ImageHelper.generateVideoThumbnailFile(file);

        processedMedia.add({
          'file': file,
          //'thumbnailFile': thumbnailFile,
          'mediaType': 'video',
          'index': i,
        });
      } else {
        // Regular image
        processedMedia.add({
          'file': file,
          'mediaType': ImageHelper.isGif(file) ? 'gif' : 'image',
          'index': i,
        });
      }
    }

    return processedMedia;
  }

  Widget _mediaPicker(BuildContext context) {
    return Column(
      children: [
        Card(
          child: GestureDetector(
            onTap: () async {
              if (_isSubmitting) {
                return; // Prevent changing media while submitting
              }

              try {
                // Use the image picker to select multiple images
                final pickedFiles = await ImageHelper.pickMediaFilesWithVideo(
                  context: context,
                );

                if (pickedFiles != null && pickedFiles.isNotEmpty) {
                  setState(() {
                    _mediaFiles = pickedFiles;
                    _currentMediaIndex = 0;
                    _postMedia =
                        _mediaFiles.first; // For backward compatibility
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isNSFW && _isAlt
                      ? Colors.purple
                      : _isNSFW && !_isAlt
                          ? Colors.red
                          : _isAlt
                              ? Colors.blue
                              : Theme.of(context).colorScheme.primary,
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
                                        : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
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

    final canEdit = !isVideo && !isGif;

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
                          : Theme.of(context).colorScheme.primary,
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
          // Remove button positioned in bottom right
          Positioned(
            bottom: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _mediaFiles.removeAt(_currentMediaIndex);
                  if (_mediaFiles.isEmpty) {
                    _currentMediaIndex = 0;
                    _postMedia = null;
                    _hasMedia =
                        false; // Also disable media toggle if no files left
                  } else if (_currentMediaIndex >= _mediaFiles.length) {
                    _currentMediaIndex = _mediaFiles.length - 1;
                    _postMedia = _mediaFiles[_currentMediaIndex];
                  } else {
                    _postMedia = _mediaFiles[_currentMediaIndex];
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
          Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white.withValues(alpha: 0.8),
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
        // Bottom right controls
        Positioned(
          bottom: 8,
          right: 8,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Remove button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _mediaFiles.removeAt(_currentMediaIndex);
                    if (_mediaFiles.isEmpty) {
                      _currentMediaIndex = 0;
                      _postMedia = null;
                      _hasMedia =
                          false; // Also disable media toggle if no files left
                    } else if (_currentMediaIndex >= _mediaFiles.length) {
                      _currentMediaIndex = _mediaFiles.length - 1;
                      _postMedia = _mediaFiles[_currentMediaIndex];
                    } else {
                      _postMedia = _mediaFiles[_currentMediaIndex];
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              if (canEdit) ...[
                const SizedBox(width: 8),
                // Edit button
                GestureDetector(
                  onTap: () => _cropImage(currentFile),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isGif)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
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
                : Theme.of(context).colorScheme.primary;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          Card(
            child: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                labelText: 'Title',
                // Set the default border
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: borderColor),
                ),
                // Set the border when field is enabled but not focused
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: borderColor),
                ),
                // Set the border when field is focused
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                    color: borderColor,
                    width: 2,
                  ),
                ),
                // Set the border when field has an error
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.red),
                ),
                // Set the border when field has an error and is focused
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.red, width: 2),
                ),
                prefixIcon: Icon(
                  Icons.title,
                  color: borderColor,
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
          ),

          // filterd tags
          if (_postTags.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Align(
                  // Chipが左揃えになるようにAlignを追加
                  alignment: Alignment.center,
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: _postTags.map((tag) {
                      return Chip(
                        // Change border radius to match the card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.transparent),
                        ),

                        label: Text('#$tag'), // # を付けて表示
                        backgroundColor:
                            Theme.of(context).primaryColor.withValues(
                                  alpha: 0.1, // 背景色を少し透明にして目立たせる
                                ),
                        labelStyle:
                            TextStyle(color: Theme.of(context).primaryColor),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () {
                          // Quillエディタからタグを削除するロジックは複雑になるため、
                          // ここではChipをタップしてもQuillエディタのテキストは変更しない。
                          // 必要であれば、Quillドキュメントを直接編集するロジックを実装する。
                          // 現状は表示から消すだけで、Quillエディタのテキストは残る。
                          _safeSetState(() {
                            _postTags.remove(tag);
                          });

                          // We might not have to notify the user here.
                          //_showErrorSnackBar(context, 'Please remove the tag from the editor.'); // ユーザーに通知
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

          // Media picker
          if (_hasMedia) _mediaPicker(context),

          //const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                Container(
                  // Minimum height but no maximum height constraint
                  constraints: const BoxConstraints(
                    minHeight: 200,
                  ),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: borderColor,
                      ),
                      left: BorderSide(
                        color: borderColor,
                      ),
                      right: BorderSide(
                        color: borderColor,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: MentionOverlay(
                    controller: _contentController,
                    focusNode: _editorFocusNode,
                    isAlt: _isAlt,
                    child: quill.QuillEditor(
                      controller: _contentController,
                      focusNode: _editorFocusNode,
                      scrollController: _editorScrollController,
                      config: quill.QuillEditorConfig(
                        scrollable: true,
                        padding: EdgeInsets.zero,
                        autoFocus: false,
                        expands: false,
                        placeholder: 'What\'s on your mind?',
                        scrollBottomInset: 60,
                        embedBuilders: [
                          MentionEmbedBuilder(), // Keep this here too
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    //color: Colors.grey.shade100,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                    border: Border(
                      bottom: BorderSide(
                        color: borderColor,
                      ),
                      left: BorderSide(
                        color: borderColor,
                      ),
                      right: BorderSide(
                        color: borderColor,
                      ),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: QuillSimpleToolbar(
                      controller: _contentController,
                      config: const QuillSimpleToolbarConfig(
                        showFontFamily: false,
                        showFontSize: false,
                        showBackgroundColorButton: false,
                        showClearFormat: false,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
      final deltaJson = _contentController.document.toDelta().toJson();
      final richTextContent = jsonEncode(deltaJson);

      final mentionIds =
          MentionExtractor.extractMentionIds(_contentController.document);

      debugPrint("Submitting post with ${_mediaFiles.length} media files");
      debugPrint("Found ${mentionIds.length} mentions: $mentionIds");

      final processedMedia = await _processMediaFiles();

      ref.read(createPostControllerProvider.notifier).reset();

      final postId =
          await ref.read(createPostControllerProvider.notifier).createPost(
                title: _title,
                content: richTextContent,
                processedMedia: processedMedia,
                mediaFiles: _mediaFiles,
                userId: currentUser.id,
                isAlt: _isAlt,
                isNSFW: _isNSFW,
                herdId: _selectedHerdId ?? '',
                herdName: _selectedHerdName ?? '',
                herdProfileImageURL: _selectHerdProfileImageUrl ?? '',
                mentions: mentionIds,
                tags: _postTags,
              );

      if (mounted && context.mounted) {
        context.go('/post/$postId?isAlt=${_isAlt.toString()}');
        return;
      }
    } catch (e) {
      debugPrint("Error in _submitForm: $e");

      if (mounted && context.mounted) {
        setState(() {
          _isSubmitting = false;
        });

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to create post. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

// Simplified _showErrorSnackBar method (kept for compatibility)
  void _showErrorSnackBar(BuildContext context, String message) {
    if (!mounted || !context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

// Add this method to handle cleanup when needed
  // void _resetFormState() {
  //   if (!mounted) return;

  //   setState(() {
  //     _title = '';
  //     _content = '';
  //     _mediaFiles.clear();
  //     _postMedia = null;
  //     _hasMedia = false;
  //     _isNSFW = false;
  //     _selectedHerdId = null;
  //     _selectedHerdName = null;
  //     _isSubmitting = false;
  //   });

  //   _contentController.clear();
  // }

  Future<void> _showHerdSelectionDialog() async {
    final userHerds = await ref.read(userHerdsProvider.future);

    if (!mounted) return;

    //final selectedHerd =
    await showDialog<String>(
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
    if (!_hasEnteredContent || _isSubmitting) {
      return true;
    }

    // If not mounted, allow navigation
    if (!mounted) return true;

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

    // Check if still mounted before showing draft dialog
    if (!mounted) return true;

    // Show the save draft dialog for text-only posts
    final shouldNavigate = await showDialog<bool>(
      context: context,
      builder: (context) => SaveDraftDialog(
        title: _title,
        content: _content,
        isAlt: _isAlt,
        herdId: _selectedHerdId,
        herdName: _selectedHerdName,
        tags: _postTags,
      ),
    );

    return shouldNavigate ?? false;
  }

  Future<void> _cropImage(File imageFile) async {
    try {
      final croppedFile = await ImageHelper.cropImage(
        context: context,
        imageFile: imageFile,
        cropStyle: CropStyle.rectangle,
        title: '',
      );
      if (croppedFile != null) {
        setState(() {
          _mediaFiles[_currentMediaIndex] = croppedFile;
          _postMedia = croppedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to crop image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import '../../../user/view/providers/current_user_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final bool isAlt;

  const CreatePostScreen({
    super.key,
    this.isAlt = false, // Default to public posts
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
  bool _isVideo = false;
  String? _selectedHerdId;
  String? _selectedHerdName;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided value
    _isAlt = widget.isAlt;
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentFeed = ref.watch(currentFeedProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(_isAlt ? "Create Alt Post" : "Create Public Post"),
          actions: [
            // Add submit button in app bar
            if (!_isSubmitting)
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (currentUser != null) {
                    _submitForm(context, currentUser);
                  }
                },
              ),
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(16.0),
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
        body: currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : postState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _buildForm(context, currentUser),
                data: (_) => _buildForm(context, currentUser),
              ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserModel currentUser) {
    // Get theme for consistent styling
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy toggle card at the top
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _isAlt ? Colors.blue : Colors.grey.shade300,
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
                        'Post Privacy',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isAlt ? Icons.lock : Icons.public,
                        color: _isAlt ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isAlt ? 'Alt Post' : 'Public Post',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _isAlt ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isAlt
                        ? 'Only visible to your alt connections.'
                        : 'Visible to everyone in your public feed.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.shade300,
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
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _showHerdSelectionDialog,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _selectedHerdId != null ? Icons.group : Icons.person,
                            size: 18,
                            color: _selectedHerdId != null ? Colors.blue : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedHerdId != null
                                  ? 'h/$_selectedHerdName'
                                  : 'Personal post (no herd)',
                              style: TextStyle(
                                color: _selectedHerdId != null ? Colors.blue : null,
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

          _mediaPicker(context),

          const SizedBox(height: 16),

          _buildPostForm(context),

          const SizedBox(height: 24),

          // Submit button at the bottom
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(
                _isAlt ? Icons.lock : Icons.send,
                color: Colors.white,
              ),
              label: Text(
                _isAlt ? 'Post Altly' : 'Post Publicly',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAlt ? Colors.blue : Colors.black,
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
        ],
      ),
    );
  }

  Widget _mediaPicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isSubmitting) return; // Prevent changing media while submitting

        try {
          // Use the new media picker method
          final pickedFile = await ImageHelper.pickMediaFile(
            context: context,
          );

          if (pickedFile != null) {
            final extension = pickedFile.path.toLowerCase().substring(
                  pickedFile.path.lastIndexOf('.'),
                );

            setState(() {
              _postMedia = pickedFile;
              // Check if file is video based on extension
              _isVideo =
                  ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(extension);
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
            color: _isAlt ? Colors.blue.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: _postMedia != null
            ? _buildMediaPreview()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate,
                    size: 64,
                    color:
                        _isAlt ? Colors.blue.withOpacity(0.7) : Colors.black54,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to add media (images, GIFs, videos)',
                    style: TextStyle(
                      color: _isAlt
                          ? Colors.blue.withOpacity(0.7)
                          : Colors.black54,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPostForm(BuildContext context) {
    final borderColor =
        _isAlt ? Colors.blue.withOpacity(0.3) : Colors.grey.shade300;

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
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _isAlt ? Colors.blue : Colors.black,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.title,
                color: _isAlt ? Colors.blue : null,
              ),
            ),
            onChanged: (value) => _title = value,
            validator: (value) => value == null || value.isEmpty
                ? 'Title cannot be empty.'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: !_isSubmitting,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: 'Content',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _isAlt ? Colors.blue : Colors.black,
                  width: 2,
                ),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Icon(
                  Icons.article,
                  color: _isAlt ? Colors.blue : null,
                ),
              ),
            ),
            onChanged: (value) => _content = value,
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
      final postId = await ref.read(postControllerProvider.notifier).createPost(
            title: _title,
            content: _content,
            imageFile: _postMedia,
            userId: currentUser.id,
            isAlt: _isAlt,
            herdId: _selectedHerdId!,
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isAlt
                ? 'Alt post created successfully!'
                : 'Post created successfully!'),
            backgroundColor: _isAlt ? Colors.blue : Colors.green,
          ),
        );

        // Navigate to the post
        _isSubmitting
            ? context.go('/altPost/$postId')
            : context.go('/post/$postId?isAlt=${_isAlt}');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          context,
          'There was an issue creating the post. Try again.',
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

  Widget _buildMediaPreview() {
    if (_postMedia == null) return const SizedBox.shrink();

    final extension = _postMedia!.path.toLowerCase().substring(
          _postMedia!.path.lastIndexOf('.'),
        );

    if (_isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.black87,
                width: double.infinity,
                height: double.infinity,
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
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12),
                      )
                    ],
                  ),
                ),
              )),
          Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white.withOpacity(0.8),
          ),
        ],
      );
    }

    if (extension == '.gif') {
      return Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_postMedia!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity),
        ),
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
      ]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(_postMedia!,
          fit: BoxFit.cover, width: double.infinity, height: double.infinity),
    );
  }

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
}

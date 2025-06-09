import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/mentions/view/widgets/mention_overlay_widget.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/rich_text_editing/utils/mention_embed_builder.dart';
import 'package:herdapp/features/rich_text_editing/utils/mention_extractor.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:herdapp/features/user/view/providers/current_user_provider.dart';

import '../../../create_post/create_post_controller.dart';

class EditPostScreen extends ConsumerStatefulWidget {
  final PostModel post;

  const EditPostScreen({
    super.key,
    required this.post,
  });

  @override
  ConsumerState<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends ConsumerState<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late quill.QuillController _contentController;
  late FocusNode _editorFocusNode;
  late ScrollController _editorScrollController;
  bool _isSubmitting = false;
  late bool _isNSFW;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.post.title);
    _isNSFW = widget.post.isNSFW;
    _editorFocusNode = FocusNode();
    _editorScrollController = ScrollController();

    // Initialize Quill controller with existing content
    _initializeContentController();
  }

  void _initializeContentController() {
    try {
      // Try to parse existing content as rich text
      if (widget.post.content.isNotEmpty) {
        final decoded = jsonDecode(widget.post.content);
        if (decoded is List) {
          // It's already rich text format - use Delta directly like create_post_screen
          final delta = Delta.fromJson(decoded);
          _contentController = quill.QuillController(
            document: quill.Document.fromDelta(delta),
            selection: const TextSelection.collapsed(offset: 0),
          );
        } else {
          // Fallback to plain text
          _contentController = quill.QuillController.basic();
          _contentController.document.insert(0, widget.post.content);
        }
      } else {
        _contentController = quill.QuillController.basic();
      }
    } catch (e) {
      // If parsing fails, treat as plain text
      _contentController = quill.QuillController.basic();
      if (widget.post.content.isNotEmpty) {
        _contentController.document.insert(0, widget.post.content);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    final userId = currentUserAsync.userId;

    // Security check: Only allow the author to edit their own post
    if (userId == null || userId != widget.post.authorId) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Post')),
        body: const Center(
          child: Text('You do not have permission to edit this post'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Post'),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Media view (non-editable)
                if (widget.post.mediaURL != null &&
                    widget.post.mediaURL!.isNotEmpty)
                  Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.post.mediaThumbnailURL ??
                            widget.post.mediaURL!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Media cannot be edited',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),

                // NSFW toggle
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _isNSFW ? Colors.red : Colors.grey.shade300,
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
                            const Text(
                              'Content Warning',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Switch(
                              value: _isNSFW,
                              activeColor: Colors.red,
                              onChanged: (value) {
                                setState(() {
                                  _isNSFW = value;
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _isNSFW
                                  ? Icons.warning_amber_rounded
                                  : Icons.check_circle,
                              color: _isNSFW ? Colors.red : Colors.green,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isNSFW ? 'NSFW Content' : 'Safe Content',
                              style: TextStyle(
                                color: _isNSFW ? Colors.red : Colors.green,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isNSFW
                              ? 'This post contains sensitive content not suitable for all audiences.'
                              : 'This post is appropriate for all audiences.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Title field
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Rich text content editor - copied directly from create_post_screen
                _buildRichTextEditor(),

                const SizedBox(height: 24),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isNSFW ? Colors.red : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isSubmitting ? 'Updating...' : 'Update Post',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Rich text editor - copied exactly from create_post_screen.dart
  Widget _buildRichTextEditor() {
    final borderColor = _isNSFW ? Colors.red : Colors.grey;

    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            minHeight: 200,
          ),
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: MentionOverlay(
            controller: _contentController,
            focusNode: _editorFocusNode,
            isAlt: widget.post.isAlt,
            child: quill.QuillEditor(
              controller: _contentController,
              focusNode: _editorFocusNode,
              scrollController: _editorScrollController,
              config: quill.QuillEditorConfig(
                scrollable: true,
                padding: EdgeInsets.zero,
                autoFocus: false,
                expands: false,
                placeholder:
                    'Edit your post content... Use @ to mention someone',
                scrollBottomInset: 60,
                embedBuilders: [
                  MentionEmbedBuilder(),
                ],
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            //color: Colors.grey.shade100,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            border: Border(
              bottom: BorderSide(color: borderColor),
              left: BorderSide(color: borderColor),
              right: BorderSide(color: borderColor),
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
    );
  }

  // Submit form - copied from create_post_screen.dart pattern
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final currentUserAsync = ref.read(currentUserProvider);
      final userId = currentUserAsync.userId;
      if (userId == null) throw Exception('User not logged in');

      // Convert rich text to JSON format - same as create_post_screen
      final deltaJson = _contentController.document.toDelta().toJson();
      final richTextContent = jsonEncode(deltaJson);

      // Extract mentions from the document - same as create_post_screen
      final mentionIds =
          MentionExtractor.extractMentionIds(_contentController.document);

      await ref.read(postControllerProvider.notifier).updatePost(
            postId: widget.post.id,
            userId: userId,
            title: _titleController.text,
            content: richTextContent,
            isAlt: widget.post.isAlt,
            isNSFW: _isNSFW,
            herdId: widget.post.herdId,
          );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post updated successfully')),
        );

        // Go back to previous screen
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating post: $e')),
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
}

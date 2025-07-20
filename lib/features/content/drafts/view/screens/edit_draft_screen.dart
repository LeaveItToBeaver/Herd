// lib/features/drafts/view/screens/edit_draft_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/content/drafts/data/models/draft_post_model.dart';
import 'package:herdapp/features/community/herds/view/providers/herd_providers.dart';

import '../providers/draft_provider.dart';

class EditDraftScreen extends ConsumerStatefulWidget {
  final DraftPostModel draft;

  const EditDraftScreen({
    super.key,
    required this.draft,
  });

  @override
  ConsumerState<EditDraftScreen> createState() => _EditDraftScreenState();
}

class _EditDraftScreenState extends ConsumerState<EditDraftScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  bool _isAlt = false;
  bool _isSubmitting = false;
  String? _selectedHerdId;
  String? _selectedHerdName;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.draft.title);
    _contentController = TextEditingController(text: widget.draft.content);
    _isAlt = widget.draft.isAlt;
    _selectedHerdId = widget.draft.herdId;
    _selectedHerdName = widget.draft.herdName;

    // Add listeners to detect changes
    _titleController.addListener(_onFieldChanged);
    _contentController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    setState(() {
      _hasUnsavedChanges = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  // Check for unsaved changes before popping
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) {
      return true;
    }

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
            'You have unsaved changes. Do you want to save your draft before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
          TextButton(
            onPressed: () async {
              // Save draft and return true to allow pop
              await _saveDraft();
              if (context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Draft'),
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
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Draft',
              onPressed: _isSubmitting ? null : _saveDraft,
            ),
            IconButton(
              icon: const Icon(Icons.send),
              tooltip: 'Publish',
              onPressed: _isSubmitting ? null : _publishDraft,
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
                  // Post privacy setting
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Switch(
                                value: _isAlt,
                                activeColor: Colors.blue,
                                onChanged: (value) {
                                  setState(() {
                                    _isAlt = value;
                                    _hasUnsavedChanges = true;
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
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
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Herd selection card
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
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
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
                                    _selectedHerdId != null
                                        ? Icons.group
                                        : Icons.person,
                                    size: 18,
                                    color: _selectedHerdId != null
                                        ? Colors.blue
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _selectedHerdId != null
                                          ? 'h/$_selectedHerdName'
                                          : 'Personal post (no herd)',
                                      style: TextStyle(
                                        color: _selectedHerdId != null
                                            ? Colors.blue
                                            : null,
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

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                    buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) {
                      return null; // Hide the counter
                    },
                  ),

                  const SizedBox(height: 16),

                  // Content field
                  TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter content';
                      }
                      return null;
                    },
                    maxLines: 8,
                  ),

                  const SizedBox(height: 24),

                  // Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _saveDraft,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Draft'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _publishDraft,
                          icon: const Icon(Icons.send),
                          label: const Text('Publish'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDraft() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authProvider);
      if (user == null) throw Exception('User not logged in');

      await ref.read(draftControllerProvider.notifier).saveDraft(
            authorId: user.uid,
            draftId: widget.draft.id,
            title: _titleController.text,
            content: _contentController.text,
            isAlt: _isAlt,
            herdId: _selectedHerdId,
            herdName: _selectedHerdName,
          );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _hasUnsavedChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Draft saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving draft: $e')),
        );
      }
    }
  }

  Future<void> _publishDraft() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    // First save the draft to get the most recent changes
    await _saveDraft();

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = ref.read(authProvider);
      if (user == null) throw Exception('User not logged in');

      final postId =
          await ref.read(draftControllerProvider.notifier).publishDraft(
                user.uid,
                widget.draft.id,
              );

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _hasUnsavedChanges = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published successfully')),
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
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error publishing post: $e')),
        );
      }
    }
  }

  Future<void> _showHerdSelectionDialog() async {
    final userHerdsAsync = ref.read(userHerdsProvider.future);

    try {
      final userHerds = await userHerdsAsync;

      if (!mounted) return;

      final selectedHerd = await showDialog<(String?, String?)>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Select a Herd'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: userHerds.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // No Herd option
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title: const Text('Personal Post (No Herd)'),
                      selected: _selectedHerdId == null,
                      onTap: () {
                        Navigator.of(context).pop((null, null));
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
                    subtitle: Text(
                      herd.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    selected: _selectedHerdId == herd.id,
                    onTap: () {
                      Navigator.of(context).pop((herd.id, herd.name));
                    },
                  );
                },
              ),
            ),
          );
        },
      );

      if (selectedHerd != null) {
        setState(() {
          _selectedHerdId = selectedHerd.$1;
          _selectedHerdName = selectedHerd.$2;
          _hasUnsavedChanges = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading herds: $e')),
        );
      }
    }
  }
}

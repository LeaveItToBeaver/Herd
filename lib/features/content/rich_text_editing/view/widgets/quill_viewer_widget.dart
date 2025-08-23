import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:herdapp/features/content/rich_text_editing/view/widgets/read_only_mention_builder_widget.dart';

enum RichTextSource {
  postWidget,
  postScreen,
  postFeed, // Add this for the feed context
}

class QuillViewerWidget extends StatefulWidget {
  final String jsonContent;
  final RichTextSource source;
  final bool isExpanded;

  const QuillViewerWidget({
    super.key,
    required this.jsonContent,
    required this.source,
    this.isExpanded = false,
  });

  @override
  State<QuillViewerWidget> createState() => _QuillViewerWidgetState();
}

class _QuillViewerWidgetState extends State<QuillViewerWidget>
    with AutomaticKeepAliveClientMixin {
  late quill.QuillController _controller;
  bool _isLoading = true;
  String? _errorDetail; // To store detailed error information
  String? _cachedJsonContent; // Cache the content to avoid rebuilds

  @override
  bool get wantKeepAlive => true; // Keep state alive during rebuilds

  @override
  void initState() {
    super.initState();
    debugPrint(
        "[QuillViewerWidget-${widget.source}] initState: Content length: ${widget.jsonContent.length}");
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant QuillViewerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only reinitialize if content actually changed
    if (oldWidget.jsonContent != widget.jsonContent) {
      debugPrint(
          "[QuillViewerWidget-${widget.source}] didUpdateWidget: Content changed. Re-initializing.");
      // Dispose the old controller before creating a new one to avoid issues
      _controller.dispose();
      _initializeController();
    } else if (oldWidget.isExpanded != widget.isExpanded) {
      debugPrint(
          "[QuillViewerWidget-${widget.source}] didUpdateWidget: Only expansion changed. Skipping controller recreation.");
      // Just trigger a rebuild without recreating the controller
      setState(() {});
    }
  }

  void _initializeController() {
    // Check if we already processed this content
    if (_cachedJsonContent == widget.jsonContent && !_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorDetail = null;
    });

    try {
      if (widget.jsonContent.isEmpty) {
        debugPrint(
            "[QuillViewerWidget-${widget.source}] Content is empty. Initializing with empty document.");
        _controller = quill.QuillController(
          document: quill.Document(), // Initialize with an empty document
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        _cachedJsonContent = widget.jsonContent;
        setState(() {
          _isLoading = false;
        });
        return;
      }

      debugPrint(
          "[QuillViewerWidget-${widget.source}] Attempting to parse JSON.");
      // Quill expects a List<dynamic> which is what jsonDecode should produce from a valid Delta JSON string
      final List<dynamic> jsonData = jsonDecode(widget.jsonContent);
      final doc = quill.Document.fromJson(jsonData);
      debugPrint(
          "[QuillViewerWidget-${widget.source}] JSON parsed and document created successfully.");

      _controller = quill.QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
      _cachedJsonContent = widget.jsonContent; // Cache the content
      setState(() {
        _isLoading = false;
      });
    } catch (e, s) {
      debugPrint(
          "[QuillViewerWidget-${widget.source}] ERROR initializing QuillController: $e\nStack trace:\n$s");
      debugPrint(
          "[QuillViewerWidget-${widget.source}] Failing JSON content was: ${widget.jsonContent}");
      setState(() {
        _isLoading = false;
        _errorDetail =
            "Error parsing rich text content: $e.\nRaw content:\n${widget.jsonContent}";
        // Fallback to a controller that shows the error
        _controller = quill.QuillController(
          document: quill.Document()
            ..insert(
                0, 'Error displaying content. See debug console for details.'),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      });
    }
  }

  @override
  void dispose() {
    debugPrint("[QuillViewerWidget-${widget.source}] dispose");
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    debugPrint(
        "[QuillViewerWidget-${widget.source}] build: isLoading: $_isLoading, hasError: ${_errorDetail != null}");

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorDetail != null) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment
            .centerLeft, // Align left for better readability of raw JSON
        child: SingleChildScrollView(
          // Allow scrolling for long error messages/JSON
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 30),
                  const SizedBox(width: 8),
                  Text(
                    'Rich Text Error',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                widget.source == RichTextSource.postScreen ||
                        widget.source == RichTextSource.postWidget &&
                            widget.isExpanded
                    ? _errorDetail! // Show full error and raw JSON on post screen or if expanded
                    : 'Could not load rich text. Tap to expand/view details.',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.left,
              ),
            ],
          ),
        ),
      );
    }

    // Configure editor styles
    final customStyles = quill.DefaultStyles(
      h1: quill.DefaultTextBlockStyle(
        Theme.of(context).textTheme.headlineLarge!,
        const quill.HorizontalSpacing(0, 0),
        const quill.VerticalSpacing(16, 0),
        const quill.VerticalSpacing(0, 0),
        null,
      ),
      sizeSmall: const TextStyle(fontSize: 14),
    );

    // Build the editor configuration
    final editorConfig = quill.QuillEditorConfig(
      customStyles: customStyles,
      autoFocus: false,
      expands: widget.source == RichTextSource.postScreen ||
          (widget.source == RichTextSource.postFeed && widget.isExpanded),
      padding: EdgeInsets.zero,
      scrollable: widget.source == RichTextSource.postScreen ||
          (widget.source == RichTextSource.postFeed && widget.isExpanded),
      showCursor: false,
      enableInteractiveSelection: widget.source == RichTextSource.postScreen,
      embedBuilders: [
        ReadOnlyMentionEmbedBuilder(context), // Add this line
      ],
    );

    // Create an appropriate editor based on whether we need scrolling or not
    Widget editor;

    if (widget.source == RichTextSource.postScreen ||
        (widget.source == RichTextSource.postFeed && widget.isExpanded)) {
      // For PostScreen or expanded post widget: use the scroll controller from the parent
      // but don't set expands to true when inside a ScrollView
      final bool inPostScreen = widget.source == RichTextSource.postScreen;

      // Create a configuration that works within a ScrollView
      final postScreenConfig = quill.QuillEditorConfig(
        customStyles: customStyles,
        autoFocus: false,
        // Critical: Don't use expands:true inside a SingleChildScrollView
        expands: false,
        padding: EdgeInsets.zero,
        scrollable: false, // Let the parent ScrollView handle scrolling
        showCursor: false,
        enableInteractiveSelection: inPostScreen,
        embedBuilders: [
          ReadOnlyMentionEmbedBuilder(context), // Add this line too
        ],
      );

      editor = quill.QuillEditor.basic(
        controller: _controller,
        config: postScreenConfig,
      );
    } else {
      // For non-scrollable compact post widget preview
      final scrollController = ScrollController();
      editor = quill.QuillEditor(
        controller: _controller,
        focusNode: FocusNode(canRequestFocus: false),
        scrollController: scrollController,
        config: editorConfig, // This already has embedBuilders now
      );
    }

    // For post widget preview, we want to limit the height
    if (widget.source == RichTextSource.postFeed && !widget.isExpanded) {
      return Container(
        constraints: const BoxConstraints(
          maxHeight: 120, // Show more lines for better preview
        ),
        width: double.infinity,
        child: ClipRect(
          child: editor,
        ),
      );
    }

    // For PostScreen or expanded PostWidget, return the editor directly
    // In PostScreen, wrap the editor in a Container with sizing constraints
    // to avoid the "RenderBox was not laid out" error
    if (widget.source == RichTextSource.postScreen) {
      return Container(
        child: editor,
      );
    }

    return editor;
  }
}

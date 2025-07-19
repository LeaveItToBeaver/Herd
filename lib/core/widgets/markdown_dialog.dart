import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Shows a dialog with markdown content loaded from an asset.
void showMarkdownDialog(
  BuildContext context, {
  required String title,
  required String assetPath,
}) async {
  final theme = Theme.of(context);
  final String content = await rootBundle.loadString(assetPath);

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Markdown(
                  data: content,
                  styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                    h1: theme.textTheme.headlineMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    h2: theme.textTheme.headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                    h3: theme.textTheme.titleLarge!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  selectable: true,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

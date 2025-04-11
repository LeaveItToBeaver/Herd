// 1. First, fix the Android back gesture issue by adding to AndroidManifest.xml:
// Add this attribute to the <application> tag in android/app/src/main/AndroidManifest.xml

/*
<application
    android:enableOnBackInvokedCallback="true"
    ... other attributes ...>
    ... application contents ...
</application>
*/

// 2. Update the legal document widget to:
// - Fix markdown previewing
// - Expand widget width
// - Improve layout

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track acceptance status of legal documents
final legalAcceptanceProvider = StateProvider<Map<String, bool>>((ref) {
  return {
    'terms': false,
    'privacy': false,
  };
});

class LegalDocumentWidget extends ConsumerWidget {
  final String title;
  final String assetPath;
  final String acceptanceKey;
  final bool isRequired;

  const LegalDocumentWidget({
    super.key,
    required this.title,
    required this.assetPath,
    required this.acceptanceKey,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acceptance = ref.watch(legalAcceptanceProvider);
    final isAccepted = acceptance[acceptanceKey] ?? false;

    return Container(
      width: double.infinity, // Full width of parent
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isRequired && !isAccepted
              ? theme.colorScheme.error.withOpacity(0.5)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Preview of the document (first few lines)
          FutureBuilder<String>(
            future: _loadAsset(assetPath),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasError || !snapshot.hasData) {
                return Text(
                  'Error loading document: ${snapshot.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                );
              }

              // Process markdown to remove headers and markdown symbols for preview
              final fullText = snapshot.data!;

              // Extract first paragraph and clean it
              final firstParagraphEnd = fullText.indexOf('\n\n');
              String preview = firstParagraphEnd > 0
                  ? fullText.substring(0, firstParagraphEnd)
                  : fullText.substring(
                      0, fullText.length > 150 ? 150 : fullText.length);

              // Remove markdown formatting
              preview = preview
                  .replaceAll(RegExp(r'#+ '), '') // Remove headers
                  .replaceAll(RegExp(r'```.*?```', dotAll: true),
                      '') // Remove code blocks
                  .replaceAll(RegExp(r'- '), '') // Remove list markers
                  .replaceAll(
                      RegExp(r'[\*_]{1,2}'), '') // Remove other markdown
                  .trim();

              if (preview.isEmpty) {
                preview =
                    "Click 'Read Full Document' to view document details.";
              } else {
                preview += '...';
              }

              return Text(
                preview,
                style: theme.textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              );
            },
          ),

          const SizedBox(height: 16),

          // Buttons for actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Read Full Document button
              TextButton(
                onPressed: () => _showFullDocument(context, ref),
                child: const Text('Read Full Document'),
              ),

              // Acceptance checkbox
              Row(
                children: [
                  Checkbox(
                    value: isAccepted,
                    onChanged: (value) {
                      // Only allow manual checking, not automatic
                      if (value != null) {
                        final currentAcceptance =
                            Map<String, bool>.from(acceptance);
                        currentAcceptance[acceptanceKey] = value;
                        ref.read(legalAcceptanceProvider.notifier).state =
                            currentAcceptance;
                      }
                    },
                  ),
                  Text(
                    'I Accept',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),

          // Required indicator
          if (isRequired && !isAccepted)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Acceptance required to continue',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Load markdown from assets
  Future<String> _loadAsset(String path) async {
    return await rootBundle.loadString(path);
  }

  // Show full document dialog
  void _showFullDocument(BuildContext context, WidgetRef ref) async {
    final theme = Theme.of(context);
    final acceptance = ref.read(legalAcceptanceProvider);
    final String content = await _loadAsset(assetPath);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // Make dialog wider
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95, // Wider dialog
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Markdown content
                Expanded(
                  child: Markdown(
                    data: content,
                    styleSheet: MarkdownStyleSheet(
                      h1: theme.textTheme.headlineMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      h2: theme.textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      h3: theme.textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                      p: theme.textTheme.bodyMedium!,
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      listBullet: theme.textTheme.bodyMedium,
                    ),
                    selectable: true, // Make text selectable
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () {
                        final currentAcceptance =
                            Map<String, bool>.from(acceptance);
                        currentAcceptance[acceptanceKey] = true;
                        ref.read(legalAcceptanceProvider.notifier).state =
                            currentAcceptance;
                        Navigator.pop(context);
                      },
                      child: const Text('Accept'),
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
}

// Widget that combines both legal documents and validates acceptance
class LegalDocumentsSection extends ConsumerWidget {
  final VoidCallback? onValidAcceptance;

  const LegalDocumentsSection({
    super.key,
    this.onValidAcceptance,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final acceptance = ref.watch(legalAcceptanceProvider);
    final hasAcceptedAll =
        (acceptance['terms'] ?? false) && (acceptance['privacy'] ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal Agreements',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please review and accept our terms and privacy policy',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Terms and Conditions - Full width container
        const LegalDocumentWidget(
          title: 'Terms and Conditions',
          assetPath: 'assets/legal/terms.md',
          acceptanceKey: 'terms',
        ),
        const SizedBox(height: 16),

        // Privacy Policy - Full width container
        const LegalDocumentWidget(
          title: 'Privacy Policy',
          assetPath: 'assets/legal/privacy.md',
          acceptanceKey: 'privacy',
        ),

        const SizedBox(height: 24),

        // Agreement text
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              const TextSpan(
                text:
                    'By creating an account, you confirm that you are at least 16 years of age and agree to the ',
              ),
              TextSpan(
                text: 'Terms of Service',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Show Terms dialog using the asset path
                    _showMarkdownDialog(context, ref, 'Terms and Conditions',
                        'assets/legal/terms.md', 'terms');
                  },
              ),
              const TextSpan(
                text: ' and ',
              ),
              TextSpan(
                text: 'Privacy Policy',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    // Show Privacy dialog using the asset path
                    _showMarkdownDialog(context, ref, 'Privacy Policy',
                        'assets/legal/privacy.md', 'privacy');
                  },
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Continue button that is enabled only when both documents are accepted
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: hasAcceptedAll ? onValidAcceptance : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),

        if (!hasAcceptedAll)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Text(
                'You must accept both documents to continue',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Show a full markdown dialog
  void _showMarkdownDialog(BuildContext context, WidgetRef ref, String title,
      String assetPath, String acceptanceKey) async {
    final theme = Theme.of(context);
    final acceptance = ref.read(legalAcceptanceProvider);
    final String content = await rootBundle.loadString(assetPath);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          // Make dialog wider
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.95, // Wider dialog
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dialog title
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Markdown content
                Expanded(
                  child: Markdown(
                    data: content,
                    styleSheet: MarkdownStyleSheet(
                      h1: theme.textTheme.headlineMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                      h2: theme.textTheme.headlineSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                      h3: theme.textTheme.titleLarge!
                          .copyWith(fontWeight: FontWeight.bold),
                      p: theme.textTheme.bodyMedium!,
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: const TextStyle(fontStyle: FontStyle.italic),
                      listBullet: theme.textTheme.bodyMedium,
                    ),
                    selectable: true, // Make text selectable
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: () {
                        final currentAcceptance =
                            Map<String, bool>.from(acceptance);
                        currentAcceptance[acceptanceKey] = true;
                        ref.read(legalAcceptanceProvider.notifier).state =
                            currentAcceptance;
                        Navigator.pop(context);
                      },
                      child: const Text('Accept'),
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
}

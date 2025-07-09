import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/herd_repository_provider.dart';

/// Mixin that provides validation logic for herd creation
mixin HerdValidationMixin<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  // Real-time validation state
  String? nameValidationError;
  bool isCheckingName = false;
  Timer? debounceTimer;

  @override
  void dispose() {
    debounceTimer?.cancel();
    super.dispose();
  }

  /// Validate herd name for special characters - no spaces allowed
  String? validateHerdNameFormat(String name) {
    if (name.isEmpty) return null;

    // Check length limit first (30 characters max)
    if (name.length > 30) {
      return 'Herd name cannot be longer than 30 characters.\nCurrent length: ${name.length}/30';
    }

    // Check for spaces
    if (name.contains(' ')) {
      return 'Herd name cannot contain spaces.\nUse formats like "TestTest" instead of "Test Test".';
    }

    // Check for invalid characters (no spaces or dashes allowed)
    final regex = RegExp(r'^[a-zA-Z0-9\.\,\!\?]+$');
    if (!regex.hasMatch(name.trim())) {
      // Find the first invalid character for more specific feedback
      final invalidChars = name
          .split('')
          .where((char) => !RegExp(r'[a-zA-Z0-9\.\,\!\?]').hasMatch(char))
          .toSet();

      if (invalidChars.isNotEmpty) {
        return 'Invalid character(s): ${invalidChars.join(', ')}\nOnly letters, numbers, and basic punctuation (. , ! ?) are allowed.\nSpaces and dashes are not allowed.';
      }
      return 'Name can only contain letters, numbers,\nand basic punctuation (. , ! ?) - no spaces or dashes.';
    }

    return null;
  }

  /// Real-time validation of herd name with immediate feedback
  Future<void> validateHerdNameRealTime(String name) async {
    // Cancel any existing timer
    debounceTimer?.cancel();

    // Immediate format validation (no delay)
    final formatError = validateHerdNameFormat(name);
    if (formatError != null) {
      setState(() {
        nameValidationError = formatError;
        isCheckingName = false;
      });
      return;
    }

    // Length validation
    if (name.length < 3) {
      setState(() {
        nameValidationError =
            name.isEmpty ? null : 'Name must be at least 3 characters';
        isCheckingName = false;
      });
      return;
    }

    // Show loading immediately for name existence check
    setState(() {
      isCheckingName = true;
      nameValidationError = null;
    });

    // Debounce the network call by 500ms
    debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final repository = ref.read(herdRepositoryProvider);
        final nameExists = await repository.checkHerdNameExists(name);

        if (mounted) {
          setState(() {
            nameValidationError = nameExists
                ? 'A herd with this name already exists.\nPlease choose a different name.'
                : null;
            isCheckingName = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            nameValidationError = null; // Don't show error for network issues
            isCheckingName = false;
          });
        }
      }
    });
  }

  /// Form validator for herd name field
  String? validateHerdName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    if (value.length > 30) {
      return 'Name cannot be longer than 30 characters';
    }
    return nameValidationError;
  }
}

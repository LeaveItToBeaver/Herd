// user_settings_state.dart

class UserSettingsState {
  final bool allowNSFWContent;
  final bool blurNSFWContent;
  final bool showHerdsInAltFeed;
  final bool isOver18;
  final Map<String, dynamic> preferences;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, bool> updatingFields; // Track which fields are updating

  UserSettingsState({
    this.allowNSFWContent = false,
    this.blurNSFWContent = true,
    this.showHerdsInAltFeed = true,
    this.isOver18 = false,
    this.preferences = const {},
    this.isLoading = false,
    this.errorMessage,
    this.updatingFields = const {},
  });

  UserSettingsState copyWith({
    bool? allowNSFWContent,
    bool? blurNSFWContent,
    bool? showHerdsInAltFeed,
    bool? isOver18,
    Map<String, dynamic>? preferences,
    bool? isLoading,
    String? errorMessage,
    Map<String, bool>? updatingFields,
  }) {
    return UserSettingsState(
      allowNSFWContent: allowNSFWContent ?? this.allowNSFWContent,
      blurNSFWContent: blurNSFWContent ?? this.blurNSFWContent,
      showHerdsInAltFeed: showHerdsInAltFeed ?? this.showHerdsInAltFeed,
      isOver18: isOver18 ?? this.isOver18,
      preferences: preferences ?? this.preferences,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      updatingFields: updatingFields ?? this.updatingFields,
    );
  }

  // Helper to check if a specific field is currently updating
  bool isFieldUpdating(String fieldName) {
    return updatingFields[fieldName] == true;
  }
}

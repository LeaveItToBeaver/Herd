class MessageInteractionState {
  final Set<String> hiddenStatusMessages;
  final String? selectedMessageId;

  const MessageInteractionState({
    this.hiddenStatusMessages = const {},
    this.selectedMessageId,
  });

  MessageInteractionState copyWith({
    Set<String>? hiddenStatusMessages,
    String? selectedMessageId,
  }) {
    return MessageInteractionState(
      hiddenStatusMessages: hiddenStatusMessages ?? this.hiddenStatusMessages,
      selectedMessageId: selectedMessageId ?? this.selectedMessageId,
    );
  }
}

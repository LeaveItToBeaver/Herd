/// Enum representing the delivery/sync status of a message
enum MessageStatus {
  /// Message is being composed (not yet sent)
  draft,
  
  /// Message is being sent to the server (optimistic UI)
  sending,
  
  /// Message successfully delivered to server
  delivered,
  
  /// Message failed to send (needs retry)
  failed,
  
  /// Message was successfully read by recipient (future feature)
  read,
}

extension MessageStatusExtension on MessageStatus {
  /// Get display text for the status
  String get displayText {
    switch (this) {
      case MessageStatus.draft:
        return 'Draft';
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.delivered:
        return 'Delivered';
      case MessageStatus.failed:
        return 'Failed to send';
      case MessageStatus.read:
        return 'Read';
    }
  }

  /// Get icon for the status
  String get icon {
    switch (this) {
      case MessageStatus.draft:
        return '✏️';
      case MessageStatus.sending:
        return '📤';
      case MessageStatus.delivered:
        return '✅';
      case MessageStatus.failed:
        return '❌';
      case MessageStatus.read:
        return '👁️';
    }
  }

  /// Whether the message is in a final state (no more updates expected)
  bool get isFinal {
    return this == MessageStatus.delivered || 
           this == MessageStatus.failed || 
           this == MessageStatus.read;
  }

  /// Whether the message should show as an error
  bool get isError {
    return this == MessageStatus.failed;
  }

  /// Whether the message is still being processed
  bool get isPending {
    return this == MessageStatus.sending;
  }
}
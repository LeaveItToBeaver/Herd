import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_input_state.freezed.dart';

@freezed
abstract class MessageInputState with _$MessageInputState {
  const factory MessageInputState({
    @Default('') String text,
    @Default(false) bool isTyping,
    @Default(false) bool isSending,
    String? replyToMessageId,
    String? error,
  }) = _MessageInputState;
}

import 'package:televerse/telegram.dart';
import 'package:televerse/televerse.dart';

extension RawApiExtensions on RawAPI {
  static const maxMessageLength = 4096;
  Future<List<Message>> sendLongMessage(
    ID chatId,
    String text, {
    int? messageThreadId,
    ParseMode? parseMode,
    List<MessageEntity>? entities,
    bool? disableNotification,
    bool? protectContent,
    ReplyMarkup? replyMarkup,
    ReplyParameters? replyParameters,
    LinkPreviewOptions? linkPreviewOptions,
    String? businessConnectionId,
    String? messageEffectId,
    bool? allowPaidBroadcast,
    int? directMessagesTopicId,
    SuggestedPostParameters? suggestedPostParameters,
  }) async {
    final textParts = _separateLongText(text);
    final messages = [
      for (final textPart in textParts)
        await sendMessage(
          chatId,
          textPart,
          messageThreadId: messageThreadId,
          parseMode: parseMode,
          entities: entities,
          disableNotification: disableNotification,
          protectContent: protectContent,
          replyMarkup: replyMarkup,
          replyParameters: replyParameters,
          linkPreviewOptions: linkPreviewOptions,
          businessConnectionId: businessConnectionId,
          messageEffectId: messageEffectId,
          allowPaidBroadcast: allowPaidBroadcast,
          directMessagesTopicId: directMessagesTopicId,
          suggestedPostParameters: suggestedPostParameters,
        ),
    ];
    return messages;
  }

  List<String> _separateLongText(String text) {
    List<String> textParts = [];
    while (true) {
      // Base case: the current text is shorter than the limit
      if (text.length < maxMessageLength) {
        textParts.add(text);
        return textParts;
      }
      // Iterative case: separate text for almost maxMessageLength,
      // but splitting in "\n", ". " or " " if possible.
      String part = text.substring(0, maxMessageLength);
      for (final separator in ["\n", ". ", " "]) {
        if (!part.contains(separator)) continue;

        final separatorIndex = part.lastIndexOf(separator);
        part = part.substring(0, separatorIndex) + separator;
        break;
      }

      textParts.add(part);
      text = text.substring(part.length);
    }
  }
}

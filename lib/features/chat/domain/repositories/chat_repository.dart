import 'dart:io';
import '../entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<MessageEntity>> getMessages(
    String currentUserId,
    String otherUserId,
  );

  Stream<Map<String, dynamic>?> getChatSummary(
    String currentUserId,
    String otherUserId,
  );
  Future<void> resetUnreadCount(String currentUserId, String otherUserId);
  Future<void> sendMessage(MessageEntity message, {File? imageFile});
  // Simple version: get list of users to chat with (or recent chats)
  Stream<List<Map<String, dynamic>>> getUsers(); // For simplicity in this demo
}

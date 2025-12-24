import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Stream<Map<String, dynamic>?> getChatSummary(
    String currentUserId,
    String otherUserId,
  ) {
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(otherUserId)
        .snapshots()
        .map((doc) => doc.data());
  }

  @override
  Future<void> resetUnreadCount(
    String currentUserId,
    String otherUserId,
  ) async {
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(otherUserId)
        .set({'unreadCount': 0}, SetOptions(merge: true));
  }

  ChatRepositoryImpl({FirebaseFirestore? firestore, FirebaseStorage? storage})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _storage =
          storage ??
          FirebaseStorage
              .instance; // Revert to standard instance, let google-services.json handle it

  @override
  Stream<List<MessageEntity>> getMessages(
    String currentUserId,
    String otherUserId,
  ) {
    List<String> ids = [currentUserId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");
    print('Message Stream Requested for Room: $chatRoomId');

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          print('Snapshot Received! Doc count: ${snapshot.docs.length}');
          return snapshot.docs
              .map((doc) => MessageModel.fromSnapshot(doc))
              .toList();
        });
  }

  @override
  Future<void> sendMessage(MessageEntity message, {File? imageFile}) async {
    print(
      'Sending Message From: ${message.senderId} To: ${message.receiverId}',
    );
    List<String> ids = [message.senderId, message.receiverId];
    ids.sort();
    String chatRoomId = ids.join("_");
    print('Chat Room ID: $chatRoomId');

    String content = message.content;
    MessageType type = message.type;

    if (imageFile != null) {
      try {
        String fileName = const Uuid().v4();
        final ref = _storage.ref().child(
          'chat_images/$chatRoomId/$fileName.jpg',
        );

        final bytes = await imageFile.readAsBytes();
        final metadata = SettableMetadata(contentType: 'image/jpeg');

        await ref.putData(bytes, metadata);
        content = await ref.getDownloadURL();
        type = MessageType.image;
      } catch (e) {
        print("Image Upload Failed: $e");
        throw Exception("Failed to upload image: $e");
      }
    }

    final messageModel = MessageModel(
      id: const Uuid().v4(),
      senderId: message.senderId,
      receiverId: message.receiverId,
      content: content,
      type: type,
      timestamp: DateTime.now(),
    );

    try {
      final batch = _firestore.batch();

      // 1. Add Message to Chat Room
      final messageRef = _firestore
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .doc(); // Auto-ID

      batch.set(messageRef, {
        ...messageModel.toMap(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Update Sender's Recent Chat (No unread count increase)
      final senderChatRef = _firestore
          .collection('users')
          .doc(message.senderId)
          .collection('chats')
          .doc(message.receiverId);

      batch.set(senderChatRef, {
        'lastMessage': type == MessageType.image ? '📷 Image' : content,
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserId': message.receiverId,
        'unreadCount':
            0, // Reset my unread count for this chat since I'm sending
      }, SetOptions(merge: true));

      // 3. Update Receiver's Recent Chat (Increment unread count)
      final receiverChatRef = _firestore
          .collection('users')
          .doc(message.receiverId)
          .collection('chats')
          .doc(message.senderId);

      batch.set(receiverChatRef, {
        'lastMessage': type == MessageType.image ? '📷 Image' : content,
        'timestamp': FieldValue.serverTimestamp(),
        'otherUserId': message.senderId,
        'unreadCount': FieldValue.increment(1),
      }, SetOptions(merge: true));

      await batch.commit();

      print('Message Sent & Recent Chats Updated!');
    } catch (e) {
      print('Error Sending Message: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> getUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => doc.data()).toList();
    });
  }
}

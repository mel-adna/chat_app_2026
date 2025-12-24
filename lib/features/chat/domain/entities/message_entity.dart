import 'package:equatable/equatable.dart';

enum MessageType { text, image }

class MessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final DateTime timestamp;

  const MessageEntity({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object> get props => [
    id,
    senderId,
    receiverId,
    content,
    type,
    timestamp,
  ];
}

import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object> get props => [];
}

class LoadMessages extends ChatEvent {
  final String currentUserId;
  final String otherUserId;

  const LoadMessages({required this.currentUserId, required this.otherUserId});

  @override
  List<Object> get props => [currentUserId, otherUserId];
}

class SendMessage extends ChatEvent {
  final String senderId;
  final String receiverId;
  final String content;
  final File? imageFile;

  const SendMessage({
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.imageFile,
  });

  @override
  List<Object> get props => [senderId, receiverId, content, imageFile ?? ''];
}

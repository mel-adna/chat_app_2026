import 'package:equatable/equatable.dart';
import '../../domain/entities/message_entity.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatUsersLoaded extends ChatState {
  final List<Map<String, dynamic>> users;

  const ChatUsersLoaded(this.users);

  @override
  List<Object> get props => [users];
}

class ChatMessagesLoaded extends ChatState {
  final Stream<List<MessageEntity>> messagesStream;

  const ChatMessagesLoaded(this.messagesStream);

  @override
  List<Object> get props => [messagesStream];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object> get props => [message];
}

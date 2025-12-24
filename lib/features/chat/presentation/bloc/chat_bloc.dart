import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository chatRepository;

  ChatBloc({required this.chatRepository}) : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
  }

  Future<void> _onLoadMessages(
    LoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final stream = chatRepository.getMessages(
        event.currentUserId,
        event.otherUserId,
      );
      emit(ChatMessagesLoaded(stream));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<ChatState> emit,
  ) async {
    try {
      final message = MessageEntity(
        id: '', // Generated in repo
        senderId: event.senderId,
        receiverId: event.receiverId,
        content: event.content,
        type: event.imageFile != null ? MessageType.image : MessageType.text,
        timestamp: DateTime.now(),
      );
      await chatRepository.sendMessage(message, imageFile: event.imageFile);
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}

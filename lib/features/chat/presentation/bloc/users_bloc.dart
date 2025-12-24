import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repositories/chat_repository.dart';

// Events
abstract class UsersEvent extends Equatable {
  const UsersEvent();
  @override
  List<Object> get props => [];
}

class LoadAllUsers extends UsersEvent {}

// States
abstract class UsersState extends Equatable {
  const UsersState();
  @override
  List<Object> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Map<String, dynamic>> users;
  const UsersLoaded(this.users);
  @override
  List<Object> get props => [users];
}

class UsersError extends UsersState {
  final String message;
  const UsersError(this.message);
  @override
  List<Object> get props => [message];
}

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final ChatRepository chatRepository;

  UsersBloc({required this.chatRepository}) : super(UsersInitial()) {
    on<LoadAllUsers>(_onLoadUsers);
  }

  Future<void> _onLoadUsers(
    LoadAllUsers event,
    Emitter<UsersState> emit,
  ) async {
    emit(UsersLoading());
    try {
      final usersStream = chatRepository.getUsers();
      await emit.forEach(
        usersStream,
        onData: (users) => UsersLoaded(users),
        onError: (error, stackTrace) => UsersError(error.toString()),
      );
    } catch (e) {
      emit(UsersError(e.toString()));
    }
  }
}

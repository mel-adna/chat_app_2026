import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/data/datasources/biometric_service.dart';
import 'features/chat/data/repositories/chat_repository_impl.dart';
import 'features/chat/presentation/bloc/chat_bloc.dart';
import 'features/chat/presentation/bloc/users_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/chat/presentation/screens/home_screen.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/bloc/auth_event.dart'; // Import AuthEvent
import 'features/auth/presentation/bloc/auth_state.dart'; // Import AuthState

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Simple DI configuration
    final authDataSource = AuthRemoteDataSourceImpl();
    final authRepository = AuthRepositoryImpl(remoteDataSource: authDataSource);
    final biometricService = BiometricService();

    final chatRepository = ChatRepositoryImpl();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: chatRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: authRepository,
              biometricService: biometricService,
            )..add(AuthCheckRequested()),
          ),
          BlocProvider(
            create: (context) => ChatBloc(chatRepository: chatRepository),
          ),
          BlocProvider(
            create: (context) => UsersBloc(chatRepository: chatRepository),
          ),
        ],
        child: MaterialApp(
          title: 'Chat 2026',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthAuthenticated) {
                return NotificationListenerWrapper(
                  currentUserId: state.user.id,
                  child: HomeScreen(currentUserId: state.user.id),
                );
              }
              // Ideally show splash screen while AuthInitial/Loading
              if (state is AuthLoading || state is AuthInitial) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return const LoginScreen();
            },
          ),
        ),
      ),
    );
  }
}

class NotificationListenerWrapper extends StatefulWidget {
  final String currentUserId;
  final Widget child;

  const NotificationListenerWrapper({
    super.key,
    required this.currentUserId,
    required this.child,
  });

  @override
  State<NotificationListenerWrapper> createState() =>
      _NotificationListenerWrapperState();
}

class _NotificationListenerWrapperState
    extends State<NotificationListenerWrapper> {
  // We need to keep track of the stream subscription
  // Actually, we can use a StreamSubscription in logic, but simplest is to just have Logic here

  // To avoid duplicate notifications on startup, we track the initial load or timestamps
  // But a simple way is: Listen to .changes()
  // If change type is Modified and unreadCount increased -> Notify

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    // This is a "hack/workaround" since we don't have backend push notifications
    // We listen to Firestore directly while the app is alive.

    // We can't easily access Firestore instance without import, assuming simple usage or import
    // Let's rely on standard imports we add
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.currentUserId)
          .collection('chats')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          for (var change in snapshot.data!.docChanges) {
            if (change.type == DocumentChangeType.modified) {
              final data = change.doc.data() as Map<String, dynamic>;
              final unreadCount = data['unreadCount'] as int? ?? 0;
              // Simple heuristic: If unread count > 0, notify
              // Caveat: This might trigger if you just opened the app.
              // Better: Compare with old data if possible, or just trigger.
              // Since we want "Notify", let's just trigger for now if unread > 0
              // Refinement: Only if timestamp is very recent (last 10 seconds)?

              final Timestamp? ts = data['timestamp'] as Timestamp?;
              if (ts != null && unreadCount > 0) {
                final diff = DateTime.now().difference(ts.toDate());
                if (diff.inSeconds < 10) {
                  // Only notify if message is fresh
                  NotificationService().showNotification(
                    "New Message",
                    data['lastMessage'] ?? "You have a new message",
                  );
                }
              }
            }
          }
        }
        return widget.child;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';

// Actually HomeScreen doesn't need LoginScreen import if we remove logout button.
// But wait, the logout logic was IN the button. Now we moved it.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'settings_screen.dart';
import '../bloc/users_bloc.dart';
import '../bloc/chat_bloc.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;
  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UsersBloc>().add(LoadAllUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            final users = state.users
                .where((u) => u['uid'] != widget.currentUserId)
                .toList();

            if (users.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final String? photoUrl = user['photoUrl'];
                final String displayName =
                    user['displayName'] ?? 'Unknown User';
                final String userId = user['uid'];

                return StreamBuilder<Map<String, dynamic>?>(
                  stream: context
                      .read<ChatBloc>()
                      .chatRepository
                      .getChatSummary(widget.currentUserId, userId),
                  builder: (context, snapshot) {
                    final chatData = snapshot.data;
                    final String lastMessage =
                        chatData?['lastMessage'] ?? user['email'] ?? '';
                    final int unreadCount = chatData?['unreadCount'] ?? 0;
                    final Timestamp? timestamp = chatData?['timestamp'];

                    // Format Time (Simple logic)
                    String timeText = '';
                    if (timestamp != null) {
                      final dt = timestamp.toDate();
                      timeText =
                          "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
                    }

                    return ListTile(
                      leading: Stack(
                        children: [
                          Hero(
                            tag: 'avatar_$userId',
                            child: CircleAvatar(
                              backgroundColor: AppColors.primary,
                              backgroundImage: photoUrl != null
                                  ? NetworkImage(photoUrl)
                                  : null,
                              child: photoUrl == null
                                  ? Text(
                                      displayName.isNotEmpty
                                          ? displayName[0].toUpperCase()
                                          : 'U',
                                    )
                                  : null,
                            ),
                          ),
                          if (user['isOnline'] == true)
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green, // Online Indicator
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.background,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (timeText.isNotEmpty)
                            Text(
                              timeText,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: unreadCount > 0 ? Colors.white : Colors.grey,
                          fontWeight: unreadCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: unreadCount > 0
                          ? CircleAvatar(
                              radius: 12,
                              backgroundColor: AppColors.primary,
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        // Reset count when entering
                        context
                            .read<ChatBloc>()
                            .chatRepository
                            .resetUnreadCount(widget.currentUserId, userId);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                              currentUserId: widget.currentUserId,
                              otherUserId: userId,
                              otherUserName: displayName,
                              otherUserPhotoUrl: photoUrl,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          } else if (state is UsersError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Loading users...'));
        },
      ),
    );
  }
}

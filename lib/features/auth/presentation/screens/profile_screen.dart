import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  String? _photoUrl;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _populateUserData();
  }

  void _populateUserData() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated) {
      _nameController.text = state.user.displayName ?? '';
      _photoUrl = state.user.photoUrl;
    }
  }

  void _saveProfile() {
    if (_nameController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    context.read<AuthBloc>().add(
      AuthUpdateProfileRequested(
        displayName: _nameController.text.trim(),
        photoUrl: _photoUrl,
      ),
    );

    // Simulate delay for better UX since Bloc might not emit immediate feedback state suitable for this local screen
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditing = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile Updated!')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _photoUrl = state.user.photoUrl;
          if (!_isEditing) {
            _nameController.text = state.user.displayName ?? '';
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            if (!_isEditing)
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    _isEditing = true;
                  });
                },
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _isEditing
                      ? () {
                          // TODO: Implement Image Picker Logic here reusing ChatScreen logic or new service
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Image Upload not implemented yet here",
                              ),
                            ),
                          );
                        }
                      : null,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary,
                    backgroundImage: _photoUrl != null
                        ? NetworkImage(_photoUrl!)
                        : null,
                    child: _photoUrl == null
                        ? Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(fontSize: 40),
                          )
                        : null,
                  ),
                ),
                if (_isEditing)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: const Text(
                      "Tap to change photo",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                // Email is usually read-only
                TextField(
                  enabled: false,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  controller: TextEditingController(
                    text: context.select(
                      (AuthBloc bloc) => (bloc.state is AuthAuthenticated)
                          ? (bloc.state as AuthAuthenticated).user.email
                          : '',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Use StreamBuilder to listen to real-time online status from Firestore
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(
                        context.read<AuthBloc>().state is AuthAuthenticated
                            ? (context.read<AuthBloc>().state
                                      as AuthAuthenticated)
                                  .user
                                  .id
                            : '',
                      )
                      .snapshots(),
                  builder: (context, snapshot) {
                    bool isOnline = true; // Default
                    if (snapshot.hasData && snapshot.data!.exists) {
                      final data =
                          snapshot.data!.data() as Map<String, dynamic>?;
                      if (data != null && data.containsKey('isOnline')) {
                        isOnline = data['isOnline'] as bool;
                      }
                    }

                    return SwitchListTile(
                      title: const Text("Show as Online"),
                      subtitle: const Text(
                        "Other users can see when you are active",
                      ),
                      value: isOnline,
                      onChanged: (val) {
                        context.read<AuthBloc>().add(
                          AuthToggleOnlineStatus(val),
                        );
                        // No need for manual snackbar, UI will update automatically via stream
                      },
                    );
                  },
                ),
                const SizedBox(
                  height: 40,
                ), // Replaced Spacer with fixed spacel ? "You are now Online" : "You are now Offline",
                if (_isEditing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProfile,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save Changes'),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Dartz removed

// Wait, I should probably add dartz or fpdart if I want "Senior" level.
// I'll stick to direct throws for now for readability unless requested.

import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithEmail(String email, String password);
  Future<UserEntity> signUpWithEmail(String email, String password);
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  Future<UserEntity?> getCurrentUser();
  Future<void> updateProfile({required String displayName, String? photoUrl});
  Future<void> toggleOnlineStatus(bool isOnline);
}

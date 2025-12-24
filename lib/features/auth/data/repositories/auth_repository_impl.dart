import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel;
    } catch (e) {
      // Log error
      return null;
    }
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    final userModel = await remoteDataSource.signInWithEmail(email, password);
    return userModel;
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final userModel = await remoteDataSource.signInWithGoogle();
    return userModel;
  }

  @override
  Future<void> signOut() async {
    return await remoteDataSource.signOut();
  }

  @override
  Future<UserEntity> signUpWithEmail(String email, String password) async {
    final userModel = await remoteDataSource.signUpWithEmail(email, password);
    return userModel;
  }

  @override
  Future<void> updateProfile({
    required String displayName,
    String? photoUrl,
  }) async {
    await remoteDataSource.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  @override
  Future<void> toggleOnlineStatus(bool isOnline) async {
    await remoteDataSource.toggleOnlineStatus(isOnline);
  }
}

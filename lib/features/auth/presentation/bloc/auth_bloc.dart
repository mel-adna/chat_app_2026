import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/biometric_service.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final BiometricService biometricService; // Inject this

  AuthBloc({required this.authRepository, required this.biometricService})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthGoogleLoginRequested>(_onAuthGoogleLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthBiometricLoginRequested>(_onAuthBiometricLoginRequested);
    on<AuthUpdateProfileRequested>(_onAuthUpdateProfileRequested);
    on<AuthToggleOnlineStatus>(_onAuthToggleOnlineStatus);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (_) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithEmail(
        event.email,
        event.password,
      );
      // Store credentials on success
      await biometricService.storeCredentials(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthGoogleLoginRequested(
    AuthGoogleLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signInWithGoogle();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.signUpWithEmail(
        event.email,
        event.password,
      );
      // Store credentials on success
      await biometricService.storeCredentials(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onAuthBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check support
    bool canCheck = await biometricService.isBiometricAvailable();
    if (!canCheck) {
      emit(const AuthError("Biometrics not available"));
      return;
    }

    // Authenticate
    bool authenticated = await biometricService.authenticate();
    if (authenticated) {
      emit(AuthLoading());
      try {
        final creds = await biometricService.getCredentials();
        if (creds != null) {
          final user = await authRepository.signInWithEmail(
            creds['email']!,
            creds['password']!,
          );
          emit(AuthAuthenticated(user));
        } else {
          emit(
            const AuthError(
              "No stored credentials. Login with password first.",
            ),
          );
        }
      } catch (e) {
        emit(AuthError("Biometric Login Failed: ${e.toString()}"));
      }
    }
  }

  Future<void> _onAuthUpdateProfileRequested(
    AuthUpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    // We don't want to emit AuthLoading because it might rebuild the whole app if AuthBloc is top-level.
    // Instead, we might want a separate "ProfileSaving" state OR just handle it optimistically.
    // For now, let's just do it. If we emit AuthLoading, the user might be kicked to a loading screen.
    // Let's assume ProfileScreen handles its own loading state via a local Bloc or simple state,
    // OR we emit a specific "AuthProfileUpdateSuccess" (which requires changing states).

    // Better approach for global auth bloc: Just do the update and trigger a reload of user.
    try {
      await authRepository.updateProfile(
        displayName: event.displayName,
        photoUrl: event.photoUrl,
      );
      // Refresh current user
      add(AuthCheckRequested());
    } catch (e) {
      // Allow UI to handle error via listener if possible, or emit error
      emit(AuthError("Update failed: ${e.toString()}"));
      // Re-fetch user to restore valid state
      add(AuthCheckRequested());
    }
  }

  Future<void> _onAuthToggleOnlineStatus(
    AuthToggleOnlineStatus event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await authRepository.toggleOnlineStatus(event.isOnline);
      // We don't necessarily need to emit a new state or fetch user again
      // because this is a background status update, but for keeping UI sync
      // if we were storing isOnline in local user model, we might want to update it.
      // For now, fire and forget logic is acceptable, or refresh user.
    } catch (e) {
      // Log error
    }
  }
}

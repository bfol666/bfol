import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/services/supabase_service.dart';

enum AuthStatus { initializing, unauthenticated, authenticating, authenticated, error }

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initializing,
    this.user,
    this.error,
  });

  AuthState copyWith({AuthStatus? status, User? user, String? error}) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseService _supabaseService;

  AuthNotifier(this._supabaseService) : super(const AuthState());

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final response = await _supabaseService.signIn(email, password);
      final userData = response.user;
      if (userData != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: User(
            id: userData.id,
            email: userData.email ?? email,
            nickname: userData.userMetadata?['nickname'] ?? email.split('@').first,
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signUp(String email, String password, String nickname) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    try {
      final response = await _supabaseService.signUp(email, password);
      final userData = response.user;
      if (userData != null) {
        await _supabaseService.client.from('profiles').insert({
          'id': userData.id,
          'nickname': nickname,
          'email': email,
        });
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: User(
            id: userData.id,
            email: email,
            nickname: nickname,
            createdAt: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _supabaseService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user.dart';
import '../../data/services/local_storage_service.dart';
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
  final LocalStorageService _localStorage;
  final SupabaseService _supabaseService;

  AuthNotifier(this._localStorage, this._supabaseService)
      : super(const AuthState()) {
    _init();
  }

  void _init() {
    if (_localStorage.isLoggedIn) {
      final userId = _localStorage.currentUserId ?? 'local-user';
      state = AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: userId,
          email: 'local@moodiary.app',
          nickname: '小叶子',
          createdAt: DateTime.now(),
        ),
      );
    } else {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Quick local sign-in for MVP (no backend)
  Future<void> signInLocally(String nickname) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    await Future.delayed(const Duration(milliseconds: 400));
    const userId = 'local-user';
    await _localStorage.setLoggedIn(true);
    await _localStorage.setCurrentUserId(userId);
    state = AuthState(
      status: AuthStatus.authenticated,
      user: User(
        id: userId,
        email: 'local@moodiary.app',
        nickname: nickname,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Full Supabase sign-in (falls back to local when backend is unavailable)
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(status: AuthStatus.authenticating);
    if (!_supabaseService.isInitialized) {
      await signInLocally(email.split('@').first);
      return;
    }
    try {
      final response = await _supabaseService.signIn(email, password);
      final userData = response.user;
      if (userData != null) {
        await _localStorage.setLoggedIn(true);
        await _localStorage.setCurrentUserId(userData.id);
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
    if (!_supabaseService.isInitialized) {
      await signInLocally(nickname);
      return;
    }
    try {
      final response = await _supabaseService.signUp(email, password);
      final userData = response.user;
      if (userData != null) {
        await _supabaseService.client.from('profiles').insert({
          'id': userData.id,
          'nickname': nickname,
          'email': email,
        });
        await _localStorage.setLoggedIn(true);
        await _localStorage.setCurrentUserId(userData.id);
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
    if (_supabaseService.isInitialized) {
      try {
        await _supabaseService.signOut();
      } catch (_) {}
    }
    await _localStorage.setLoggedIn(false);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

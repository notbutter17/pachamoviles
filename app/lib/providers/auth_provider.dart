import 'package:flutter/foundation.dart';

import '../core/enums/user_role.dart';
import '../core/errors/api_exception.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../services/secure_storage_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Single source of truth for the session: tokens, current user and role.
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  final SecureStorageService _storage;

  AuthProvider(this._repo, this._storage);

  AuthStatus _status = AuthStatus.unknown;
  UserModel? _user;
  bool _loading = false;
  String? _error;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  UserRole get role => _user?.role ?? UserRole.unknown;
  bool get isAdmin => role.isAdmin;
  bool get loading => _loading;
  String? get error => _error;

  /// Called on app start: validates a stored session against `/me`.
  Future<void> tryAutoLogin() async {
    final hasSession = await _storage.hasSession();
    if (!hasSession) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }
    try {
      _user = await _repo.me();
      _setStatus(AuthStatus.authenticated);
    } on ApiException {
      await _storage.clear();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repo.login(email: email, password: password);
      await _storage.saveTokens(
        access: result.tokens.access,
        refresh: result.tokens.refresh,
      );
      _user = result.user;
      _loading = false;
      _setStatus(AuthStatus.authenticated);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clear();
    _user = null;
    _error = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  /// Triggered by the API client when refresh fails.
  void onSessionExpired() {
    _storage.clear();
    _user = null;
    _setStatus(AuthStatus.unauthenticated);
  }

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }
}

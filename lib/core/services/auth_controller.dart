import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/auth_session.dart';
import '../models/enums.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'secure_preferences.dart';
import 'token_storage.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isCodeSent = false,
    this.verificationId,
    this.lastPhoneNumber,
    this.biometricAvailable = false,
    this.biometricEnabled = false,
  });

  final UserProfile? user;
  final bool isLoading;
  final String? error;
  final bool isCodeSent;
  final String? verificationId;
  final String? lastPhoneNumber;
  final bool biometricAvailable;
  final bool biometricEnabled;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? error,
    bool? isCodeSent,
    String? verificationId,
    String? lastPhoneNumber,
    bool? biometricAvailable,
    bool? biometricEnabled,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isCodeSent: isCodeSent ?? this.isCodeSent,
      verificationId: verificationId ?? this.verificationId,
      lastPhoneNumber: lastPhoneNumber ?? this.lastPhoneNumber,
      biometricAvailable: biometricAvailable ?? this.biometricAvailable,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(
    this._authService,
    this._tokenStorage,
    this._notificationService,
    this._securePreferences,
    this._localAuth,
  ) : super(const AuthState());

  final AuthService _authService;
  final TokenStorage _tokenStorage;
  final NotificationService _notificationService;
  final SecurePreferences _securePreferences;
  final LocalAuthentication _localAuth;

  Future<void> restoreSession() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _restoreSessionInternal()
          .timeout(const Duration(seconds: 12));
    } on TimeoutException {
      state = state.copyWith(isLoading: false, user: null, error: 'timeout');
    } catch (error) {
      state = state.copyWith(isLoading: false, user: null, error: '$error');
    }
  }

  Future<void> _restoreSessionInternal() async {
    final session = await _authService.currentSession();
    if (session == null) {
      state = state.copyWith(isLoading: false, user: null);
      return;
    }
    await _storeSession(session);
  }

  Future<void> loadBiometricState() async {
    if (kIsWeb) {
      state = state.copyWith(biometricAvailable: false);
      return;
    }
    final isSupported = await _localAuth.isDeviceSupported();
    final canCheck = await _localAuth.canCheckBiometrics;
    final enabled = await _securePreferences.isBiometricEnabled();
    state = state.copyWith(
      biometricAvailable: isSupported && canCheck,
      biometricEnabled: enabled,
    );
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _securePreferences.setBiometricEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled);
  }

  Future<void> authenticateWithBiometrics() async {
    if (kIsWeb) {
      return;
    }
    if (!state.biometricAvailable || !state.biometricEnabled) {
      return;
    }
    final didAuthenticate = await _localAuth.authenticate(
      localizedReason: 'Authenticate to continue',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
    if (didAuthenticate) {
      await restoreSession();
    }
  }

  Future<void> sendPhoneCode({required String phone}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _authService.sendPhoneVerification(phone: phone);
      if (result.didAutoVerify) {
        final session = await _authService.currentSession();
        if (session != null) {
          await _storeSession(session);
          return;
        }
      }
      state = state.copyWith(
        isLoading: false,
        isCodeSent: true,
        verificationId: result.verificationId,
        lastPhoneNumber: phone,
      );
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> loginWithPhone({
    required String phone,
    required String otp,
    UserRole? role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _authService.loginWithPhone(
        phone: phone,
        otp: otp,
        role: role,
      );
      await _storeSession(session);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _authService.signInWithEmail(
        email: email,
        password: password,
        role: role,
      );
      await _storeSession(session);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> register({
    required String phone,
    required String name,
    required UserRole role,
    String? email,
    required String otp,
    Map<String, dynamic>? roleData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _authService.loginWithPhone(
        phone: phone,
        otp: otp,
        role: role,
      );
      await _storeSession(session);
      final registered = await _authService.register(
        phone: phone,
        name: name,
        role: role,
        email: email,
        roleData: roleData,
      );
      state = state.copyWith(user: registered.user, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String phone,
    required String name,
    required UserRole role,
    Map<String, dynamic>? roleData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _authService.registerWithEmail(
        email: email,
        password: password,
        phone: phone,
        name: name,
        role: role,
        roleData: roleData,
      );
      await _storeSession(session);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> signInWithGoogle({required UserRole role}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final session = await _authService.signInWithGoogle(role: role);
      await _storeSession(session);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> updateProfile({
    required String name,
    String? email,
    String? locale,
    Map<String, dynamic>? roleData,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _authService.updateProfile(
        name: name,
        email: email,
        locale: locale,
        roleData: roleData,
      );
      state = state.copyWith(user: profile, isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: '$error');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, error: null);
    await _authService.logout();
    await _tokenStorage.clearToken();
    state = const AuthState(isLoading: false);
  }

  Future<void> _storeSession(AuthSession session) async {
    await _tokenStorage.writeToken(session.accessToken);
    await _notificationService.registerDeviceToken(session.user.id);
    state = state.copyWith(
      user: session.user,
      isLoading: false,
      isCodeSent: false,
      verificationId: null,
      lastPhoneNumber: null,
    );
  }
}


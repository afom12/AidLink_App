import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/auth_session.dart';
import '../models/user_profile.dart';
import '../models/enums.dart';

class PhoneVerificationResult {
  PhoneVerificationResult({
    required this.verificationId,
    this.resendToken,
    this.didAutoVerify = false,
  });

  final String verificationId;
  final int? resendToken;
  final bool didAutoVerify;
}

class AuthService {
  AuthService({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  String? _verificationId;
  int? _resendToken;

  Future<PhoneVerificationResult> sendPhoneVerification({
    required String phone,
    int? forceResendToken,
  }) async {
    final completer = Completer<PhoneVerificationResult>();
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendToken ?? _resendToken,
      verificationCompleted: (credential) async {
        try {
          await _firebaseAuth.signInWithCredential(credential);
          if (!completer.isCompleted) {
            completer.complete(
              PhoneVerificationResult(
                verificationId: '',
                resendToken: _resendToken,
                didAutoVerify: true,
              ),
            );
          }
        } catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
      },
      verificationFailed: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
      codeSent: (verificationId, resendToken) {
        _verificationId = verificationId;
        _resendToken = resendToken;
        if (!completer.isCompleted) {
          completer.complete(
            PhoneVerificationResult(
              verificationId: verificationId,
              resendToken: resendToken,
            ),
          );
        }
      },
      codeAutoRetrievalTimeout: (verificationId) {
        _verificationId = verificationId;
      },
    );
    return completer.future;
  }

  Future<AuthSession> loginWithPhone({
    required String phone,
    required String otp,
    UserRole? role,
  }) async {
    if (_verificationId == null || _verificationId!.isEmpty) {
      throw StateError('missing_verification_id');
    }
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: otp,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final profile = await _ensureProfileForUser(
      userCredential.user,
      role: role,
      phone: phone,
    );
    final token = await userCredential.user?.getIdToken() ?? '';
    return AuthSession(accessToken: token, user: profile);
  }

  Future<AuthSession> signInWithEmail({
    required String email,
    required String password,
    UserRole? role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final resolvedPassword =
        password.trim().isEmpty ? _deriveDemoPassword(normalizedEmail) : password;
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: resolvedPassword,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('email_sign_in_failed');
      }
      final profile = await _ensureProfileForUser(
        user,
        email: normalizedEmail,
        role: role,
      );
      final token = await user.getIdToken() ?? '';
      return AuthSession(accessToken: token, user: profile);
    } on FirebaseAuthException catch (error) {
      if (password.trim().isNotEmpty) {
        rethrow;
      }
      if (error.code != 'user-not-found' && error.code != 'invalid-credential') {
        rethrow;
      }
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: resolvedPassword,
      );
      final user = credential.user;
      if (user == null) {
        throw StateError('email_registration_failed');
      }
      final profile = await _persistProfile(
        user: user,
        phone: '',
        name: '',
        role: role ?? UserRole.seeker,
        email: normalizedEmail,
      );
      final token = await user.getIdToken() ?? '';
      return AuthSession(accessToken: token, user: profile);
    }
  }

  Future<AuthSession> register({
    required String phone,
    required String name,
    required UserRole role,
    String? email,
    Map<String, dynamic>? roleData,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('not_authenticated');
    }
    final profile = await _persistProfile(
      user: user,
      phone: phone,
      name: name,
      role: role,
      email: email,
      roleData: roleData,
    );
    final token = await user.getIdToken() ?? '';
    return AuthSession(accessToken: token, user: profile);
  }

  Future<AuthSession> registerWithEmail({
    required String email,
    required String password,
    required String phone,
    required String name,
    required UserRole role,
    Map<String, dynamic>? roleData,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('email_registration_failed');
    }
    final profile = await _persistProfile(
      user: user,
      phone: phone,
      name: name,
      role: role,
      email: email,
      roleData: roleData,
    );
    final token = await user.getIdToken() ?? '';
    return AuthSession(accessToken: token, user: profile);
  }

  String _deriveDemoPassword(String email) {
    return '${email.trim().toLowerCase()}_AidLink!';
  }

  Future<AuthSession> signInWithGoogle({
    required UserRole role,
  }) async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw StateError('google_sign_in_cancelled');
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user == null) {
      throw StateError('google_sign_in_failed');
    }
    final profile = await _ensureProfileForUser(
      user,
      role: role,
      email: user.email,
      name: user.displayName,
    );
    final token = await user.getIdToken() ?? '';
    return AuthSession(accessToken: token, user: profile);
  }

  Future<AuthSession?> currentSession() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    final profile = await _ensureProfileForUser(user);
    final token = await user.getIdToken() ?? '';
    return AuthSession(accessToken: token, user: profile);
  }

  Future<UserProfile> fetchProfile() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('not_authenticated');
    }
    return _ensureProfileForUser(user);
  }

  Future<UserProfile> updateProfile({
    required String name,
    String? email,
    String? locale,
    Map<String, dynamic>? roleData,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw StateError('not_authenticated');
    }
    final profile = await _persistProfile(
      user: user,
      phone: user.phoneNumber ?? '',
      name: name,
      role: enumFromApiString(
        UserRole.values,
        (await _readProfile(user.uid))?['role']?.toString(),
        UserRole.seeker,
      ),
      email: email,
      locale: locale,
      roleData: roleData,
    );
    return profile;
  }

  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Future<UserProfile> _ensureProfileForUser(
    User? user, {
    UserRole? role,
    String? phone,
    String? name,
    String? email,
  }) async {
    if (user == null) {
      throw StateError('not_authenticated');
    }
    final data = await _readProfile(user.uid);
    if (data != null) {
      return UserProfile.fromJson(data);
    }
    return _persistProfile(
      user: user,
      phone: phone ?? user.phoneNumber ?? '',
      name: name ?? user.displayName ?? '',
      role: role ?? UserRole.seeker,
      email: email ?? user.email,
    );
  }

  Future<Map<String, dynamic>?> _readProfile(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    if (!snapshot.exists) {
      return null;
    }
    return snapshot.data();
  }

  Future<UserProfile> _persistProfile({
    required User user,
    required String phone,
    required String name,
    required UserRole role,
    String? email,
    String? locale,
    Map<String, dynamic>? roleData,
  }) async {
    final profile = UserProfile(
      id: user.uid,
      phone: phone,
      name: name,
      role: role,
      isVerified: user.phoneNumber != null || user.emailVerified,
      email: email,
      locale: locale,
      roleData: roleData,
    );
    await _firestore.collection('users').doc(user.uid).set(
          profile.toJson(),
          SetOptions(merge: true),
        );
    return profile;
  }
}





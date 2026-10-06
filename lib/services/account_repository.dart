import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../models/user_profile.dart';
import 'local_database.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Accounts stored on the device. Passwords are salted and hashed, never
/// stored as plain text.
class AccountRepository {
  AccountRepository(this._db, {DateTime Function()? clock, Random? random})
    : _clock = clock ?? DateTime.now,
      _random = random ?? Random.secure();

  static const _accountsKey = 'accounts.v1';
  static const _sessionKey = 'session.v1';
  static const minPasswordLength = 6;
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final LocalDatabase _db;
  final DateTime Function() _clock;
  final Random _random;

  Map<String, dynamic> _accounts() {
    final raw = _db.read(_accountsKey);
    if (raw == null) return {};
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> _saveAccounts(Map<String, dynamic> accounts) =>
      _db.write(_accountsKey, jsonEncode(accounts));

  /// The signed-in user, or null.
  UserProfile? currentUser() {
    final id = _db.read(_sessionKey);
    if (id == null) return null;
    final record = _accounts()[id] as Map<String, dynamic>?;
    if (record == null) return null;
    return UserProfile.fromJson(record['profile'] as Map<String, dynamic>);
  }

  static String? validateName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Please enter your name.';
    if (trimmed.length > 24) return 'Use 24 characters or fewer.';
    return null;
  }

  static String? validateEmail(String email) {
    if (!_emailPattern.hasMatch(email.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.length < minPasswordLength) {
      return 'Use at least $minPasswordLength characters.';
    }
    return null;
  }

  Future<UserProfile> register({
    required String name,
    required String email,
    required String password,
    required int grade,
  }) async {
    final error =
        validateName(name) ??
        validateEmail(email) ??
        validatePassword(password);
    if (error != null) throw AuthException(error);

    final normalizedEmail = email.trim().toLowerCase();
    final accounts = _accounts();
    final taken = accounts.values.any(
      (record) =>
          (record as Map<String, dynamic>)['profile']['email'] ==
          normalizedEmail,
    );
    if (taken) {
      throw const AuthException('An account with this email already exists.');
    }

    final profile = UserProfile(
      id: _newId('user'),
      name: name.trim(),
      grade: grade.clamp(1, 6),
      createdAt: _clock(),
      email: normalizedEmail,
    );
    final salt = _newSalt();
    accounts[profile.id] = {
      'profile': profile.toJson(),
      'salt': salt,
      'hash': _hash(password, salt),
    };
    await _saveAccounts(accounts);
    await _db.write(_sessionKey, profile.id);
    return profile;
  }

  Future<UserProfile> signIn({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    for (final entry in _accounts().entries) {
      final record = entry.value as Map<String, dynamic>;
      final profile = UserProfile.fromJson(
        record['profile'] as Map<String, dynamic>,
      );
      if (profile.email != normalizedEmail) continue;
      if (record['hash'] != _hash(password, record['salt'] as String)) break;
      await _db.write(_sessionKey, profile.id);
      return profile;
    }
    throw const AuthException('The email or password is not correct.');
  }

  /// Starts without an email. Progress stays on this device only.
  Future<UserProfile> continueAsGuest({
    required String name,
    required int grade,
  }) async {
    final error = validateName(name);
    if (error != null) throw AuthException(error);
    final profile = UserProfile(
      id: _newId('guest'),
      name: name.trim(),
      grade: grade.clamp(1, 6),
      createdAt: _clock(),
    );
    final accounts = _accounts()..[profile.id] = {'profile': profile.toJson()};
    await _saveAccounts(accounts);
    await _db.write(_sessionKey, profile.id);
    return profile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    final accounts = _accounts();
    final record = accounts[profile.id] as Map<String, dynamic>?;
    if (record == null) throw const AuthException('Account not found.');
    record['profile'] = profile.toJson();
    await _saveAccounts(accounts);
  }

  /// Guests cannot sign in again, so their account is removed on sign out.
  Future<void> signOut() async {
    final user = currentUser();
    if (user != null && user.isGuest) {
      await _saveAccounts(_accounts()..remove(user.id));
    }
    await _db.delete(_sessionKey);
  }

  String _newId(String prefix) {
    final bytes = List<int>.generate(8, (_) => _random.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '$prefix-$hex';
  }

  String _newSalt() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }

  static String _hash(String password, String salt) {
    return sha256.convert(utf8.encode('$salt:$password')).toString();
  }
}

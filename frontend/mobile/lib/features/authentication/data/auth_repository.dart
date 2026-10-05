import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/authentication/token_store.dart';
import '../../../core/networking/api_client.dart';
import 'account.dart';

class AuthRepository {
  AuthRepository({
    required String baseUrl,
    this.googleClientId = '',
    TokenStore? tokenStore,
  }) : _tokens = tokenStore ?? TokenStore() {
    _client = ApiClient(
      baseUrl: _normalize(baseUrl),
      tokenStore: _tokens,
    );
  }

  final String googleClientId;
  final TokenStore _tokens;
  late final ApiClient _client;
  GoogleSignIn? _google;
  Account? account;

  Future<void> register({
    required String fullName,
    required String password,
    String? email,
    String? phone,
    String? verificationToken,
  }) async {
    final body = <String, dynamic>{
      'fullName': fullName,
      'password': password,
      'acceptedTerms': true,
    };
    if (email != null) {
      body['email'] = email;
    }
    if (phone != null) {
      body['phone'] = phone;
    }
    if (verificationToken != null) {
      body['verificationToken'] = verificationToken;
    }
    await _client.post('/api/v1/auth/register', body: body);
    account = null;
    await _tokens.clear();
  }

  Future<Account> login({
    required String password,
    String? email,
    String? phone,
  }) async {
    final body = <String, dynamic>{'password': password};
    if (email != null) {
      body['email'] = email;
    }
    if (phone != null) {
      body['phone'] = phone;
    }
    final payload = await _client.post('/api/v1/auth/login', body: body);
    return _storeSession(payload);
  }

  /// Opens the Google sheet, then asks the API to check the token.
  /// A cancelled sheet returns null and does not show an error.
  Future<Account?> continueWithGoogle({
    required String intent,
    bool acceptedTerms = false,
  }) async {
    final clientId = googleClientId.trim();
    if (clientId.isEmpty) {
      throw ApiException("Google sign-in isn't set up.");
    }

    final google = _google ??= GoogleSignIn(serverClientId: clientId);
    try {
      await google.signOut();
      final picked = await google.signIn();
      if (picked == null) {
        return null;
      }
      final idToken = (await picked.authentication).idToken;
      if (idToken == null || idToken.isEmpty) {
        throw ApiException("Google sign-in didn't work. Try again.");
      }
      final body = <String, dynamic>{
        'idToken': idToken,
        'intent': intent,
      };
      if (acceptedTerms) {
        body['acceptedTerms'] = true;
      }
      final payload = await _client.post('/api/v1/auth/google', body: body);
      return await _storeSession(payload);
    } on ApiException {
      rethrow;
    } on PlatformException catch (error) {
      if (error.code == 'sign_in_canceled' || error.code == 'canceled') {
        return null;
      }
      throw ApiException("Google sign-in didn't work. Try again.");
    }
  }

  Future<void> requestVerificationCode({
    required String purpose,
    required String destination,
  }) async {
    await _client.post(
      '/api/v1/auth/verification-codes',
      body: {'purpose': purpose, 'destination': destination},
    );
  }

  Future<String> confirmVerificationCode({
    required String purpose,
    required String destination,
    required String code,
  }) async {
    final payload = await _client.post(
      '/api/v1/auth/verification-codes/confirm',
      body: {
        'purpose': purpose,
        'destination': destination,
        'code': code,
      },
    );
    final token = payload?['verificationToken'];
    if (token is! String || token.isEmpty) {
      throw ApiException('Something went wrong. Try again.');
    }
    return token;
  }

  Future<void> resetPassword({
    required String verificationToken,
    required String password,
  }) async {
    await _client.post(
      '/api/v1/auth/password-reset',
      body: {
        'verificationToken': verificationToken,
        'password': password,
      },
    );
  }

  Future<Account?> restoreSession() async {
    final refreshToken = await _tokens.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) {
      account = null;
      return null;
    }
    try {
      final payload = await _client.get('/api/v1/auth/me', authorized: true);
      if (payload == null) {
        account = null;
        return null;
      }
      account = Account.fromJson(payload);
      return account;
    } on ApiException {
      account = null;
      await _tokens.clear();
      return null;
    } on FormatException {
      account = null;
      await _tokens.clear();
      return null;
    }
  }

  Future<void> signOut() async {
    final refreshToken = await _tokens.readRefresh();
    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _client.post(
          '/api/v1/auth/logout',
          body: {'refreshToken': refreshToken},
        );
      }
    } on ApiException {
      // Local sign-out still stands if the server cannot be reached.
    } finally {
      account = null;
      await _tokens.clear();
    }
  }

  Future<Account> _storeSession(Map<String, dynamic>? payload) async {
    if (payload == null) {
      throw ApiException('Something went wrong. Try again.');
    }
    final accessToken = payload['accessToken'];
    final refreshToken = payload['refreshToken'];
    final user = payload['user'];
    if (accessToken is! String || refreshToken is! String || user is! Map) {
      throw ApiException('Something went wrong. Try again.');
    }
    await _tokens.save(accessToken: accessToken, refreshToken: refreshToken);
    try {
      account = Account.fromJson(Map<String, dynamic>.from(user));
    } on FormatException {
      throw ApiException('Something went wrong. Try again.');
    }
    return account!;
  }

  String _normalize(String baseUrl) {
    if (baseUrl.endsWith('/')) {
      return baseUrl.substring(0, baseUrl.length - 1);
    }
    return baseUrl;
  }
}

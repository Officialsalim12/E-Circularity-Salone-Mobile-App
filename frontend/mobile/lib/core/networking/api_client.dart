import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../authentication/token_store.dart';

class ApiException implements Exception {
  ApiException(this.message);

  final String message;
}

class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenStore,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final TokenStore tokenStore;
  final http.Client _http;
  Future<bool>? _refreshing;

  Future<Map<String, dynamic>?> post(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = false,
  }) {
    return _send('POST', path, body: body, authorized: authorized);
  }

  Future<Map<String, dynamic>?> get(String path, {bool authorized = false}) {
    return _send('GET', path, authorized: authorized);
  }

  Future<Map<String, dynamic>?> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authorized = false,
    bool allowRefresh = true,
  }) async {
    if (baseUrl.isEmpty) {
      throw ApiException("The API address isn't set.");
    }

    final accessToken = authorized ? await tokenStore.readAccess() : null;
    var response = await _request(
      method,
      path,
      body: body,
      accessToken: accessToken,
    );

    if (response.statusCode == 401 && authorized && allowRefresh) {
      final refreshed = await _refresh();
      if (!refreshed) {
        await tokenStore.clear();
        throw ApiException('Sign in to continue.');
      }
      response = await _request(
        method,
        path,
        body: body,
        accessToken: await tokenStore.readAccess(),
      );
    }

    return _decode(response);
  }

  Future<bool> _refresh() {
    final inFlight = _refreshing;
    if (inFlight != null) {
      return inFlight;
    }
    final run = _refreshOnce();
    _refreshing = run;
    return run.whenComplete(() {
      if (identical(_refreshing, run)) {
        _refreshing = null;
      }
    });
  }

  Future<bool> _refreshOnce() async {
    final refreshToken = await tokenStore.readRefresh();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }
    try {
      final response = await _request(
        'POST',
        '/api/v1/auth/refresh',
        body: {'refreshToken': refreshToken},
      );
      final payload = _decode(response);
      final access = payload?['accessToken'];
      final refresh = payload?['refreshToken'];
      if (access is! String || refresh is! String) {
        return false;
      }
      await tokenStore.save(accessToken: access, refreshToken: refresh);
      return true;
    } on ApiException {
      return false;
    }
  }

  Future<http.Response> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{'Accept': 'application/json'};
    if (body != null) {
      headers['Content-Type'] = 'application/json';
    }
    if (accessToken != null && accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) {
      request.body = jsonEncode(body);
    }

    try {
      return await _http
          .send(request)
          .timeout(const Duration(seconds: 20))
          .then(http.Response.fromStream);
    } on TimeoutException {
      throw ApiException('The server took too long to respond. Try again.');
    } catch (error) {
      if (error is ApiException) {
        rethrow;
      }
      throw ApiException(
        "Can't reach the server. Check your connection and try again.",
      );
    }
  }

  Map<String, dynamic>? _decode(http.Response response) {
    if (response.statusCode == 204 || response.body.isEmpty) {
      if (response.statusCode >= 400) {
        throw ApiException('Something went wrong. Try again.');
      }
      return null;
    }

    Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Something went wrong. Try again.');
    }

    if (response.statusCode >= 400) {
      final message = decoded is Map<String, dynamic>
          ? _errorMessage(decoded)
          : null;
      throw ApiException(message ?? 'Something went wrong. Try again.');
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    throw ApiException('Something went wrong. Try again.');
  }

  String? _errorMessage(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is Map<String, dynamic> && error['message'] is String) {
      return error['message'] as String;
    }
    return null;
  }
}

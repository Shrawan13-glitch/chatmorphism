import 'dart:convert';
import 'package:http/http.dart' as http;
import '../debug_service.dart';

class DeviceFlowResponse {
  final String deviceCode;
  final String userCode;
  final String verificationUri;
  final int interval;
  final int expiresIn;

  const DeviceFlowResponse({
    required this.deviceCode,
    required this.userCode,
    required this.verificationUri,
    required this.interval,
    required this.expiresIn,
  });

  factory DeviceFlowResponse.fromJson(Map<String, dynamic> json) {
    return DeviceFlowResponse(
      deviceCode: json['device_code'] as String,
      userCode: json['user_code'] as String,
      verificationUri: json['verification_uri'] as String,
      interval: (json['interval'] as int?) ?? 5,
      expiresIn: (json['expires_in'] as int?) ?? 900,
    );
  }
}

class TokenResponse {
  final String? accessToken;
  final String? error;
  final String? errorDescription;

  const TokenResponse({this.accessToken, this.error, this.errorDescription});

  bool get isSuccess => accessToken != null;
  bool get isPending => error == 'authorization_pending';
  bool get isSlowDown => error == 'slow_down';
}

class GithubOauthService {
  final http.Client _client = http.Client();
  final String clientId;

  GithubOauthService({required this.clientId});

  Future<DeviceFlowResponse> requestDeviceCode() async {
    final resp = await _client.post(
      Uri.parse('https://github.com/login/device/code'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'scope': 'repo workflow',
      },
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to get device code: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return DeviceFlowResponse.fromJson(data);
  }

  Future<TokenResponse> pollForToken(String deviceCode) async {
    final resp = await _client.post(
      Uri.parse('https://github.com/login/oauth/access_token'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'client_id': clientId,
        'device_code': deviceCode,
        'grant_type': 'urn:ietf:params:oauth:grant-type:device_code',
      },
    );

    if (resp.statusCode != 200) {
      DebugService.instance
          .error('OAuth poll error: ${resp.statusCode} ${resp.body}');
      return TokenResponse(error: 'http_error', errorDescription: resp.body);
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;

    if (data.containsKey('access_token')) {
      return TokenResponse(accessToken: data['access_token'] as String);
    }

    return TokenResponse(
      error: data['error'] as String?,
      errorDescription: data['error_description'] as String?,
    );
  }

  Future<String?> fetchUsername(String token) async {
    try {
      final resp = await _client.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'kino-app',
        },
      );
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['login'] as String?;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}

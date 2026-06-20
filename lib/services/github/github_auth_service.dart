import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubAuthService {
  final http.Client _client = http.Client();

  String? _token;
  String? _username;

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get username => _username;

  void restore(String token, String username) {
    _token = token;
    _username = username;
  }

  void clear() {
    _token = null;
    _username = null;
  }

  Future<bool> validateToken(String pat) async {
    try {
      final resp = await _client.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $pat',
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'kino-app',
        },
      );
      if (resp.statusCode != 200) return false;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      _token = pat;
      _username = data['login'] as String?;
      return true;
    } catch (_) {
      return false;
    }
  }

  Map<String, String> get authHeaders => {
    'Authorization': 'Bearer ${_token!}',
    'Accept': 'application/vnd.github.v3+json',
    'User-Agent': 'kino-app',
  };

  void dispose() {
    _client.close();
  }
}

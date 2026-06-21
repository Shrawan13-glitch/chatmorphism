import 'dart:convert';
import 'package:http/http.dart' as http;
import 'github_auth_service.dart';

class GithubClient {
  final GithubAuthService _auth;
  final http.Client _http = http.Client();

  GithubClient(this._auth);

  static const _baseUrl = 'api.github.com';

  Map<String, String> get _headers => _auth.authHeaders;

  Uri _uri(String path, {Map<String, String>? query}) {
    return Uri.https(_baseUrl, path, query);
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? query}) async {
    final resp = await _http.get(_uri(path, query: query), headers: _headers);
    return _handleResponse(resp);
  }

  Future<List<Map<String, dynamic>>> getList(String path,
      {Map<String, String>? query}) async {
    final resp = await _http.get(_uri(path, query: query), headers: _headers);
    _checkStatus(resp);
    final body = jsonDecode(resp.body);
    if (body is List) return body.cast<Map<String, dynamic>>();
    if (body is Map<String, dynamic>) {
      final items = body['items'] ?? body['workflow_runs'] ?? body['artifacts'] ?? body['workflows'];
      if (items is List) return items.cast<Map<String, dynamic>>();
      return [body];
    }
    return [];
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final resp = await _http.post(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(resp, allowEmpty: true);
  }

  Future<Map<String, dynamic>> patch(String path,
      {Map<String, dynamic>? body}) async {
    final resp = await _http.patch(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? body}) async {
    final resp = await _http.put(
      _uri(path),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(resp);
  }

  Future<Map<String, dynamic>> delete(String path,
      {Map<String, dynamic>? body}) async {
    final request = http.Request('DELETE', _uri(path));
    request.headers.addAll(_headers);
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    final resp = await _http.send(request);
    final response = await http.Response.fromStream(resp);
    return _handleResponse(response, allowEmpty: true);
  }

  Future<dynamic> getDynamic(String path,
      {Map<String, String>? query}) async {
    final resp = await _http.get(_uri(path, query: query), headers: _headers);
    _checkStatus(resp);
    if (resp.body.isEmpty) return null;
    return jsonDecode(resp.body);
  }

  Future<http.Response> getRaw(String path,
      {Map<String, String>? query}) async {
    return await _http.get(_uri(path, query: query), headers: _headers);
  }

  Map<String, dynamic> _handleResponse(http.Response resp,
      {bool allowEmpty = false}) {
    if (resp.statusCode == 204 && allowEmpty) return {};
    _checkStatus(resp);
    if (resp.body.isEmpty) return {};
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  void _checkStatus(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    String message;
    try {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? 'Unknown error';
    } catch (_) {
      message = resp.body.isNotEmpty ? resp.body : 'HTTP ${resp.statusCode}';
    }
    throw GithubApiException(resp.statusCode, message);
  }

  void dispose() => _http.close();
}

class GithubApiException implements Exception {
  final int statusCode;
  final String message;
  GithubApiException(this.statusCode, this.message);

  @override
  String toString() => 'GitHub API Error $statusCode: $message';
}

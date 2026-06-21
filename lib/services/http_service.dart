import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final bool truncated;

  const HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    this.truncated = false,
  });

  @override
  String toString() {
    final sb = StringBuffer();
    sb.writeln('Status: $statusCode');
    sb.writeln('Headers:');
    for (final e in headers.entries) {
      if (e.key.toLowerCase() == 'authorization') continue;
      sb.writeln('  ${e.key}: ${e.value}');
    }
    sb.writeln();
    if (truncated) {
      sb.writeln('Body (truncated, ${body.length} chars shown):');
    } else {
      sb.writeln('Body:');
    }
    sb.write(body);
    return sb.toString();
  }
}

class HttpService {
  final http.Client _client = http.Client();
  static const int _maxBodyBytes = 100 * 1024;

  Future<HttpResponse> request({
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    String? body,
    Duration timeout = const Duration(seconds: 30),
    bool followRedirects = true,
  }) async {
    var uri = Uri.tryParse(url);
    if (uri == null) {
      throw Exception('Invalid URL: $url');
    }
    if (!uri.hasScheme) {
      uri = Uri.parse('https://$url');
    }

    final request = http.StreamedRequest(method, uri);
    request.followRedirects = followRedirects;

    request.headers.addAll(<String, String>{
      'User-Agent':
          'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      'Accept': '*/*',
      'Accept-Language': 'en-US,en;q=0.9',
      ...?headers,
    });

    if (body != null && body.isNotEmpty) {
      request.headers.putIfAbsent('Content-Type', () => _inferContentType(body));
      request.sink.add(utf8.encode(body));
    }
    request.sink.close();

    final streamedResponse = await _client
        .send(request)
        .timeout(timeout);

    final response = await http.Response.fromStream(streamedResponse);

    final responseHeaders = <String, String>{};
    for (final e in response.headers.entries) {
      responseHeaders[e.key] = e.value;
    }

    var responseBody = response.body;
    final truncated = responseBody.length > _maxBodyBytes;
    if (truncated) {
      responseBody = '${responseBody.substring(0, _maxBodyBytes)}\n\n[Response truncated at $_maxBodyBytes bytes]';
    }

    return HttpResponse(
      statusCode: response.statusCode,
      headers: responseHeaders,
      body: responseBody,
      truncated: truncated,
    );
  }

  String _inferContentType(String body) {
    final trimmed = body.trim();
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      return 'application/json';
    }
    if (RegExp(r'^([\w%]+=[\w%]*(?:&[\w%]+=[\w%]*)*)$').hasMatch(trimmed)) {
      return 'application/x-www-form-urlencoded';
    }
    return 'text/plain; charset=utf-8';
  }

  void dispose() {
    _client.close();
  }
}

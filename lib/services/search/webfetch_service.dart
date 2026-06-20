import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebFetchService {
  final http.Client _client = http.Client();
  static const int _maxBytes = 50000;

  Future<String?> fetchContent(String url, {int timeoutSeconds = 20}) async {
    try {
      var uri = Uri.tryParse(url);
      if (uri == null) return null;
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$url');
      }

      final response = await _client
          .get(
            uri,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
              'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
              'Accept-Language': 'en-US,en;q=0.9',
            },
          )
          .timeout(Duration(seconds: timeoutSeconds));

      if (response.statusCode != 200) return null;

      final cleaned = _extractText(response.body);
      if (cleaned.length > _maxBytes) {
        return '${cleaned.substring(0, _maxBytes)}\n\n[truncated...]';
      }
      return cleaned;
    } catch (e) {
      return null;
    }
  }

  Future<String?> powerFetchContent(String url,
      {int timeoutSeconds = 20}) async {
    try {
      var uri = Uri.tryParse(url);
      if (uri == null) return null;
      if (!uri.hasScheme) {
        uri = Uri.parse('https://$url');
      }

      return await _webViewFetch(uri, timeoutSeconds);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _webViewFetch(Uri uri, int timeoutSeconds) async {
    final completer = Completer<String?>();

    final headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(uri.toString())),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        loadWithOverviewMode: true,
        useWideViewPort: false,
        minimumFontSize: 1,
      ),
      onLoadStop: (controller, url) async {
        await Future.delayed(const Duration(milliseconds: 1500));
        if (completer.isCompleted) return;
        try {
          final text = await controller.evaluateJavascript(
            source: 'document.body.innerText',
          );
          completer.complete(text?.toString());
        } catch (_) {
          completer.complete(null);
        }
      },
      onReceivedError: (controller, request, error) {
        if (!completer.isCompleted) completer.complete(null);
      },
    );

    await headlessWebView.run();

    final result = await completer.future.timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () => null,
    );

    await headlessWebView.dispose();
    if (result == null) return null;

    var content = result;
    if (content.length > _maxBytes) {
      content = '${content.substring(0, _maxBytes)}\n\n[truncated...]';
    }
    return content;
  }

  String _extractText(String html) {
    var text = html;
    text = text.replaceAll(RegExp(r'<script[^>]*>.*?</script>', dotAll: true), ' ');
    text = text.replaceAll(RegExp(r'<style[^>]*>.*?</style>', dotAll: true), ' ');
    text = text.replaceAll(RegExp(r'<nav[^>]*>.*?</nav>', dotAll: true), ' ');
    text = text.replaceAll(RegExp(r'<header[^>]*>.*?</header>', dotAll: true), ' ');
    text = text.replaceAll(RegExp(r'<footer[^>]*>.*?</footer>', dotAll: true), ' ');
    text = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    text = text.replaceAll(RegExp(r'&[a-z]+;'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }
}

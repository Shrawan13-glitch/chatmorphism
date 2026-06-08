import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchResult {
  final String heading;
  final String abstractText;
  final String source;
  final String url;
  final String answer;

  const SearchResult({
    this.heading = '',
    this.abstractText = '',
    this.source = '',
    this.url = '',
    this.answer = '',
  });

  bool get hasData => heading.isNotEmpty || answer.isNotEmpty || abstractText.isNotEmpty;

  String get formatted {
    if (!hasData) return 'No results found.';
    final buf = StringBuffer();
    if (heading.isNotEmpty) buf.writeln('Heading: $heading');
    if (answer.isNotEmpty) buf.writeln('Answer: $answer');
    if (abstractText.isNotEmpty) buf.writeln('Summary: $abstractText');
    if (source.isNotEmpty) buf.writeln('Source: $source');
    if (url.isNotEmpty) buf.writeln('URL: $url');
    return buf.toString().trim();
  }
}

class ToolService {
  static Future<SearchResult> webSearch(String query) async {
    final uri = Uri.https('api.duckduckgo.com', '/', {
      'q': query,
      'format': 'json',
      'no_html': '1',
      'skip_disambig': '1',
    });

    final response = await http.get(uri, headers: {
      'User-Agent': 'ChatMorphism/1.0',
    });

    if (response.statusCode != 200) {
      throw Exception('Search failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchResult(
      heading: data['Heading'] as String? ?? '',
      abstractText: data['Abstract'] as String? ?? '',
      source: data['AbstractSource'] as String? ?? '',
      url: data['AbstractURL'] as String? ?? '',
      answer: data['Answer'] as String? ?? '',
    );
  }
}

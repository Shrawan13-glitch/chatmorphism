// ignore_for_file: use_null_aware_elements
import 'dart:convert';
import 'github_client.dart';

class GithubContentService {
  final GithubClient _client;

  GithubContentService(this._client);

  Future<dynamic> getContents(
      String owner, String repo, String path) {
    return _client.getDynamic('/repos/$owner/$repo/contents/$path');
  }

  Future<Map<String, String?>> readFile(
      String owner, String repo, String path) async {
    final data = await getContents(owner, repo, path);
    final content = data['content'] as String? ?? '';
    final encoding = data['encoding'] as String? ?? 'base64';
    final sha = data['sha'] as String?;

    String decoded;
    if (encoding == 'base64') {
      decoded = utf8.decode(base64Decode(content.replaceAll('\n', '')));
    } else {
      decoded = content;
    }

    return {'content': decoded, 'sha': sha};
  }

  Future<Map<String, dynamic>> createFile(
    String owner, String repo,
    String path, {
    required String message,
    required String content,
    String? branch,
  }) {
    return _client.put('/repos/$owner/$repo/contents/$path', body: {
      'message': message,
      'content': base64Encode(utf8.encode(content)),
      if (branch != null) 'branch': branch,
    });
  }

  Future<Map<String, dynamic>> updateFile(
    String owner, String repo,
    String path, {
    required String message,
    required String content,
    required String sha,
    String? branch,
  }) {
    return _client.put('/repos/$owner/$repo/contents/$path', body: {
      'message': message,
      'content': base64Encode(utf8.encode(content)),
      'sha': sha,
      if (branch != null) 'branch': branch,
    });
  }

  Future<Map<String, dynamic>> deleteFile(
    String owner, String repo,
    String path, {
    required String message,
    required String sha,
    String? branch,
  }) {
    return _client.delete('/repos/$owner/$repo/contents/$path', body: {
      'message': message,
      'sha': sha,
      if (branch != null) 'branch': branch,
    });
  }

  Future<List<Map<String, dynamic>>> getRepoTree(
      String owner, String repo, String treeSha,
      {bool recursive = false}) async {
    final data = await _client.get('/repos/$owner/$repo/git/trees/$treeSha',
        query: {'recursive': recursive ? '1' : '0'});
    return (data['tree'] as List?)?.cast<Map<String, dynamic>>() ?? [];
  }

  Future<Map<String, dynamic>> createBlob(
      String owner, String repo, String content) {
    return _client.post('/repos/$owner/$repo/git/blobs', body: {
      'content': base64Encode(utf8.encode(content)),
      'encoding': 'base64',
    });
  }

  Future<Map<String, dynamic>> createTree(
    String owner, String repo, {
    required String baseTree,
    required List<Map<String, dynamic>> tree,
  }) {
    return _client.post('/repos/$owner/$repo/git/trees', body: {
      'base_tree': baseTree,
      'tree': tree,
    });
  }

  Future<Map<String, dynamic>> readme(String owner, String repo) {
    return _client.get('/repos/$owner/$repo/readme');
  }
}

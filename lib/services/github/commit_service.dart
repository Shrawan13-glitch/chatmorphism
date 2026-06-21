// ignore_for_file: use_null_aware_elements
import 'github_client.dart';

class GithubCommitService {
  final GithubClient _client;

  GithubCommitService(this._client);

  Future<List<Map<String, dynamic>>> listCommits(String owner, String repo,
      {String? branch, String? path, int perPage = 30}) {
    return _client.getList('/repos/$owner/$repo/commits', query: {
      if (branch != null) 'sha': branch,
      if (path != null) 'path': path,
      'per_page': perPage.toString(),
    });
  }

  Future<Map<String, dynamic>> getCommit(
      String owner, String repo, String sha) {
    return _client.get('/repos/$owner/$repo/commits/$sha');
  }

  Future<Map<String, dynamic>> compareCommits(
    String owner, String repo,
    String base, String head,
  ) {
    return _client.get('/repos/$owner/$repo/compare/$base...$head');
  }

  Future<Map<String, dynamic>> revertCommit(
      String owner, String repo, String sha) async {
    final commit = await getCommit(owner, repo, sha);
    final message = commit['commit']['message'] as String? ?? '';
    final parentSha = (commit['parents'] as List?)?.first['sha'] as String?;

    if (parentSha == null) {
      throw Exception('Cannot revert root commit (no parent)');
    }

    return _client.post('/repos/$owner/$repo/git/commits', body: {
      'message': 'Revert "$message"',
      'tree': commit['commit']['tree']['sha'],
      'parents': [parentSha],
    });
  }

  Future<Map<String, dynamic>> getCommitDiff(
      String owner, String repo, String sha) async {
    final resp = await _client.getRaw('/repos/$owner/$repo/commits/$sha',
        query: {'accept': 'application/vnd.github.v3.diff'});
    return {
      'sha': sha,
      'diff': resp.body,
    };
  }

  Future<List<Map<String, dynamic>>> listCommitComments(
      String owner, String repo, String sha) {
    return _client.getList('/repos/$owner/$repo/commits/$sha/comments');
  }

  Future<Map<String, dynamic>> searchCommits(String query,
      {String? repo, int perPage = 10}) {
    return _client.get('/search/commits', query: {
      'q': query,
      'per_page': perPage.toString(),
    });
  }

  Future<Map<String, dynamic>> createCommit(
    String owner, String repo, {
    required String message,
    required String tree,
    required List<String> parents,
  }) {
    return _client.post('/repos/$owner/$repo/git/commits', body: {
      'message': message,
      'tree': tree,
      'parents': parents,
    });
  }
}

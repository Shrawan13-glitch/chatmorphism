// ignore_for_file: use_null_aware_elements
import 'github_client.dart';

class GithubPrService {
  final GithubClient _client;

  GithubPrService(this._client);

  Future<List<Map<String, dynamic>>> listPullRequests(
      String owner, String repo,
      {String state = 'open', int perPage = 30}) {
    return _client.getList('/repos/$owner/$repo/pulls', query: {
      'state': state,
      'per_page': perPage.toString(),
    });
  }

  Future<Map<String, dynamic>> getPullRequest(
      String owner, String repo, int number) {
    return _client.get('/repos/$owner/$repo/pulls/$number');
  }

  Future<Map<String, dynamic>> createPullRequest(
    String owner, String repo, {
    required String title,
    required String head,
    required String base,
    String? body,
    bool draft = false,
  }) {
    return _client.post('/repos/$owner/$repo/pulls', body: {
      'title': title,
      'head': head,
      'base': base,
      if (body != null) 'body': body,
      'draft': draft,
    });
  }

  Future<Map<String, dynamic>> updatePullRequest(
    String owner, String repo, int number, {
    String? title,
    String? body,
    String? state,
    String? base,
  }) {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (body != null) data['body'] = body;
    if (state != null) data['state'] = state;
    if (base != null) data['base'] = base;
    return _client.patch('/repos/$owner/$repo/pulls/$number', body: data);
  }

  Future<Map<String, dynamic>> mergePullRequest(
    String owner, String repo, int number, {
    String? commitTitle,
    String? commitMessage,
    String mergeMethod = 'merge',
  }) {
    return _client.put('/repos/$owner/$repo/pulls/$number/merge', body: {
      if (commitTitle != null) 'commit_title': commitTitle,
      if (commitMessage != null) 'commit_message': commitMessage,
      'merge_method': mergeMethod,
    });
  }

  Future<List<Map<String, dynamic>>> listPullRequestFiles(
      String owner, String repo, int number) {
    return _client.getList('/repos/$owner/$repo/pulls/$number/files');
  }

  Future<List<Map<String, dynamic>>> listPullRequestCommits(
      String owner, String repo, int number) {
    return _client.getList('/repos/$owner/$repo/pulls/$number/commits');
  }

  Future<List<Map<String, dynamic>>> listPullRequestReviews(
      String owner, String repo, int number) {
    return _client.getList('/repos/$owner/$repo/pulls/$number/reviews');
  }

  Future<Map<String, dynamic>> createPullRequestReview(
    String owner, String repo, int number, {
    required String body,
    String event = 'COMMENT',
  }) {
    return _client.post('/repos/$owner/$repo/pulls/$number/reviews', body: {
      'body': body,
      'event': event,
    });
  }

  Future<Map<String, dynamic>> getPullRequestDiff(
      String owner, String repo, int number) async {
    final resp = await _client.getRaw('/repos/$owner/$repo/pulls/$number',
        query: {'accept': 'application/vnd.github.v3.diff'});
    return {
      'number': number,
      'diff': resp.body,
    };
  }

  Future<List<Map<String, dynamic>>> listPullRequestsForCommit(
      String owner, String repo, String sha) {
    return _client.getList('/repos/$owner/$repo/commits/$sha/pulls');
  }
}

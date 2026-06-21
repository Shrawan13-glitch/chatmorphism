// ignore_for_file: use_null_aware_elements
import 'github_client.dart';

class GithubIssueService {
  final GithubClient _client;

  GithubIssueService(this._client);

  Future<List<Map<String, dynamic>>> listIssues(String owner, String repo,
      {String state = 'open', String? label, int perPage = 30}) {
    return _client.getList('/repos/$owner/$repo/issues', query: {
      'state': state,
      if (label != null) 'labels': label,
      'per_page': perPage.toString(),
    });
  }

  Future<Map<String, dynamic>> getIssue(
      String owner, String repo, int number) {
    return _client.get('/repos/$owner/$repo/issues/$number');
  }

  Future<Map<String, dynamic>> createIssue(
    String owner, String repo, {
    required String title,
    String? body,
    List<String>? labels,
    List<String>? assignees,
  }) {
    return _client.post('/repos/$owner/$repo/issues', body: {
      'title': title,
      if (body != null) 'body': body,
      if (labels != null) 'labels': labels,
      if (assignees != null) 'assignees': assignees,
    });
  }

  Future<Map<String, dynamic>> updateIssue(
    String owner, String repo, int number, {
    String? title,
    String? body,
    String? state,
    List<String>? labels,
  }) {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (body != null) data['body'] = body;
    if (state != null) data['state'] = state;
    if (labels != null) data['labels'] = labels;
    return _client.patch('/repos/$owner/$repo/issues/$number', body: data);
  }

  Future<List<Map<String, dynamic>>> listIssueComments(
      String owner, String repo, int issueNumber) {
    return _client.getList('/repos/$owner/$repo/issues/$issueNumber/comments');
  }

  Future<Map<String, dynamic>> createIssueComment(
    String owner, String repo, int issueNumber, {
    required String body,
  }) {
    return _client.post('/repos/$owner/$repo/issues/$issueNumber/comments',
        body: {'body': body});
  }

  Future<List<Map<String, dynamic>>> listLabels(String owner, String repo) {
    return _client.getList('/repos/$owner/$repo/labels');
  }

  Future<Map<String, dynamic>> createLabel(
    String owner, String repo, {
    required String name,
    required String color,
    String? description,
  }) {
    return _client.post('/repos/$owner/$repo/labels', body: {
      'name': name,
      'color': color,
      if (description != null) 'description': description,
    });
  }
}

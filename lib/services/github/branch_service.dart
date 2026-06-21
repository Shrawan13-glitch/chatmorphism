// ignore_for_file: use_null_aware_elements
import 'github_client.dart';

class GithubBranchService {
  final GithubClient _client;

  GithubBranchService(this._client);

  Future<List<Map<String, dynamic>>> listBranches(String owner, String repo,
      {int perPage = 30}) {
    return _client.getList('/repos/$owner/$repo/branches',
        query: {'per_page': perPage.toString()});
  }

  Future<Map<String, dynamic>> getBranch(
      String owner, String repo, String branch) {
    return _client.get('/repos/$owner/$repo/branches/$branch');
  }

  Future<Map<String, dynamic>> createBranch(
    String owner, String repo,
    String branchName,
    String sha,
  ) {
    return _client.post('/repos/$owner/$repo/git/refs', body: {
      'ref': 'refs/heads/$branchName',
      'sha': sha,
    });
  }

  Future<void> deleteBranch(String owner, String repo, String branch) async {
    await _client.delete('/repos/$owner/$repo/git/refs/heads/$branch');
  }

  Future<Map<String, dynamic>> renameBranch(
    String owner, String repo,
    String oldName, String newName,
  ) {
    return _client.post('/repos/$owner/$repo/branches/$oldName/rename', body: {
      'new_name': newName,
    });
  }

  Future<Map<String, dynamic>> getDefaultBranchSha(
      String owner, String repo) async {
    final repoData = await _client.get('/repos/$owner/$repo');
    final defaultBranch = repoData['default_branch'] as String? ?? 'main';
    return getBranch(owner, repo, defaultBranch);
  }

  Future<Map<String, dynamic>> mergeBranch(
    String owner, String repo, {
    required String base,
    required String head,
    String? commitMessage,
  }) {
    return _client.post('/repos/$owner/$repo/merges', body: {
      'base': base,
      'head': head,
      if (commitMessage != null) 'commit_message': commitMessage,
    });
  }

  Future<Map<String, dynamic>> compareBranches(
    String owner, String repo,
    String base, String head,
  ) {
    return _client.get('/repos/$owner/$repo/compare/$base...$head');
  }
}

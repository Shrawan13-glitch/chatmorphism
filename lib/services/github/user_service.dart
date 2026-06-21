// ignore_for_file: use_null_aware_elements
import 'github_client.dart';

class GithubUserService {
  final GithubClient _client;

  GithubUserService(this._client);

  Future<Map<String, dynamic>> getAuthenticatedUser() {
    return _client.get('/user');
  }

  Future<Map<String, dynamic>> getUser(String username) {
    return _client.get('/users/$username');
  }

  Future<List<Map<String, dynamic>>> listOrganizations() {
    return _client.getList('/user/orgs');
  }

  Future<List<Map<String, dynamic>>> listUserRepos(String username,
      {String? type, int perPage = 30}) {
    return _client.getList('/users/$username/repos', query: {
      if (type != null) 'type': type,
      'per_page': perPage.toString(),
    });
  }

  Future<List<Map<String, dynamic>>> listStarredRepos(
      {int perPage = 30}) {
    return _client.getList('/user/starred',
        query: {'per_page': perPage.toString()});
  }

  Future<List<Map<String, dynamic>>> listWatchedRepos(
      {int perPage = 30}) {
    return _client.getList('/user/subscriptions',
        query: {'per_page': perPage.toString()});
  }

  Future<List<Map<String, dynamic>>> listFollowers(String username,
      {int perPage = 30}) {
    return _client.getList('/users/$username/followers',
        query: {'per_page': perPage.toString()});
  }

  Future<List<Map<String, dynamic>>> listFollowing(String username,
      {int perPage = 30}) {
    return _client.getList('/users/$username/following',
        query: {'per_page': perPage.toString()});
  }

  Future<List<Map<String, dynamic>>> listUserOrganizations(String username) {
    return _client.getList('/users/$username/orgs');
  }

  Future<List<Map<String, dynamic>>> listEvents(String username,
      {int perPage = 10}) {
    return _client.getList('/users/$username/events',
        query: {'per_page': perPage.toString()});
  }

  Future<Map<String, dynamic>> checkFollow(String username) async {
    try {
      await _client.get('/user/following/$username');
      return {'following': true};
    } on GithubApiException catch (e) {
      if (e.statusCode == 404) return {'following': false};
      rethrow;
    }
  }

  Future<void> followUser(String username) async {
    await _client.put('/user/following/$username');
  }

  Future<void> unfollowUser(String username) async {
    await _client.delete('/user/following/$username');
  }
}

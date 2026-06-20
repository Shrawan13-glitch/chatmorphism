import 'github_auth_service.dart';
import 'github_api_service.dart';
import '../debug_service.dart';

class GithubRepoService {
  final GithubAuthService _auth;
  late final GithubApiService _api;

  GithubRepoService(this._auth) {
    _api = GithubApiService(_auth);
  }

  GithubApiService get api => _api;

  Future<void> ensureRepoExists() async {
    if (!_auth.isAuthenticated) {
      throw Exception('GitHub not connected');
    }

    final exists = await _api.userRepoExists();
    if (exists) {
      DebugService.instance.info('GithubRepo: repo already exists');
      return;
    }

    DebugService.instance.info('GithubRepo: creating repo from template...');
    await _api.createRepoFromTemplate();
    DebugService.instance.info('GithubRepo: repo created');
  }

  Future<String> getRepoUrl() async {
    final username = _auth.username;
    if (username == null) throw Exception('Not authenticated');
    return 'https://github.com/$username/${GithubApiService.templateRepo}';
  }

  void dispose() {
    _api.dispose();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'github_auth_service.dart';

class GithubApiService {
  final GithubAuthService _auth;
  final http.Client _client = http.Client();

  static const String templateOwner = 'Shrawan13-glitch';
  static const String templateRepo = 'tts-generator';
  static const String defaultClientId = 'Ov23liNu8xYXb3lnQXRI';

  GithubApiService(this._auth);

  Map<String, String> get _headers => _auth.authHeaders;

  Future<String> getRepoFullName() async {
    final username = _auth.username;
    if (username == null) throw Exception('Not authenticated');
    return '$username/$templateRepo';
  }

  Future<bool> userRepoExists() async {
    final username = _auth.username;
    if (username == null) return false;
    try {
      final resp = await _client.get(
        Uri.parse('https://api.github.com/repos/$username/$templateRepo'),
        headers: _headers,
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<void> createRepoFromTemplate() async {
    final username = _auth.username;
    if (username == null) throw Exception('Not authenticated');

    final resp = await _client.post(
      Uri.parse(
        'https://api.github.com/repos/$templateOwner/$templateRepo/generate',
      ),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'owner': username,
        'name': templateRepo,
        'description': 'Personal TTS generator powered by ShryneTTS',
        'public': true,
      }),
    );

    if (resp.statusCode != 201) {
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      throw Exception(
        'Failed to create repo: ${body['message'] ?? resp.statusCode}',
      );
    }
  }

  Future<int> triggerWorkflow(String itemsJson) async {
    final repo = await getRepoFullName();
    final resp = await _client.post(
      Uri.parse(
        'https://api.github.com/repos/$repo/actions/workflows/generate.yml/dispatches',
      ),
      headers: {
        ..._headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'ref': 'master',
        'inputs': {'items': itemsJson},
      }),
    );

    if (resp.statusCode != 204) {
      final body = resp.body.isNotEmpty
          ? jsonDecode(resp.body) as Map<String, dynamic>
          : null;
      throw Exception(
        'Failed to trigger workflow: ${body?['message'] ?? resp.statusCode}',
      );
    }

    return resp.statusCode;
  }

  Future<Map<String, dynamic>?> getLatestWorkflowRun() async {
    final repo = await getRepoFullName();
    final resp = await _client.get(
      Uri.parse(
        'https://api.github.com/repos/$repo/actions/workflows/generate.yml/runs?per_page=1&status=completed',
      ),
      headers: _headers,
    );

    if (resp.statusCode != 200) return null;
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final runs = data['workflow_runs'] as List<dynamic>;
    if (runs.isEmpty) return null;
    return runs.first as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> getWorkflowRun(int runId) async {
    final repo = await getRepoFullName();
    final resp = await _client.get(
      Uri.parse('https://api.github.com/repos/$repo/actions/runs/$runId'),
      headers: _headers,
    );
    if (resp.statusCode != 200) return null;
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<int> findLatestTriggeredRun() async {
    final repo = await getRepoFullName();
    final resp = await _client.get(
      Uri.parse(
        'https://api.github.com/repos/$repo/actions/workflows/generate.yml/runs?per_page=1&event=workflow_dispatch',
      ),
      headers: _headers,
    );

    if (resp.statusCode != 200) {
      throw Exception('Failed to list runs: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final runs = data['workflow_runs'] as List<dynamic>;
    if (runs.isEmpty) throw Exception('No workflow runs found');
    return (runs.first as Map<String, dynamic>)['id'] as int;
  }

  Future<List<int>> downloadArtifact(int runId) async {
    final repo = await getRepoFullName();

    final artifactsResp = await _client.get(
      Uri.parse(
        'https://api.github.com/repos/$repo/actions/runs/$runId/artifacts',
      ),
      headers: _headers,
    );

    if (artifactsResp.statusCode != 200) {
      throw Exception('Failed to list artifacts: ${artifactsResp.statusCode}');
    }

    final data = jsonDecode(artifactsResp.body) as Map<String, dynamic>;
    final artifacts = data['artifacts'] as List<dynamic>;
    if (artifacts.isEmpty) throw Exception('No artifacts found');

    final artifact = artifacts.first as Map<String, dynamic>;
    final downloadUrl = artifact['archive_download_url'] as String;

    final zipResp = await _client.get(
      Uri.parse(downloadUrl),
      headers: _headers,
    );

    if (zipResp.statusCode != 200) {
      throw Exception('Failed to download artifact: ${zipResp.statusCode}');
    }

    return zipResp.bodyBytes;
  }

  void dispose() {
    _client.close();
  }
}

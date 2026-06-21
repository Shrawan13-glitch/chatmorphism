import '../openrouter_service.dart';

class GithubToolService {
  static bool _initialized = false;

  static void ensureInitialized() {
    if (!_initialized) {
      _initialized = true;
    }
  }

  static List<Map<String, dynamic>> get toolDefinitions => [
        // ── Repos ──
        OpenRouterService.makeToolDefinition(
          name: 'github_list_repos',
          description:
              'List repositories for the authenticated user. Optionally filter by type (all, owner, public, private, member) and sort (full_name, created, updated, pushed).',
          parameters: {
            'type': 'object',
            'properties': {
              'type': {
                'type': 'string',
                'description':
                    'Type of repos: all, owner, public, private, member (default: all)',
                'enum': ['all', 'owner', 'public', 'private', 'member'],
              },
              'sort': {
                'type': 'string',
                'description': 'Sort by: full_name, created, updated, pushed',
                'enum': ['full_name', 'created', 'updated', 'pushed'],
              },
            },
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_get_repo',
          description:
              'Get detailed information about a specific repository including description, stars, forks, language, topics, and more.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {
                'type': 'string',
                'description': 'Repository owner (user or org)',
              },
              'repo': {
                'type': 'string',
                'description': 'Repository name',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_create_repo',
          description:
              'Create a new repository for the authenticated user. Set private: false for public repos.',
          parameters: {
            'type': 'object',
            'properties': {
              'name': {
                'type': 'string',
                'description': 'Repository name',
              },
              'description': {
                'type': 'string',
                'description': 'Repository description',
              },
              'private': {
                'type': 'boolean',
                'description': 'Whether repo is private (default: true)',
              },
              'auto_init': {
                'type': 'boolean',
                'description':
                    'Auto-initialize with README (default: false)',
              },
            },
            'required': ['name'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_delete_repo',
          description:
              'Delete a repository. WARNING: This is permanent and cannot be undone.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {
                'type': 'string',
                'description': 'Repository owner',
              },
              'repo': {
                'type': 'string',
                'description': 'Repository name to delete',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_update_repo',
          description:
              'Update repository settings like name, description, or visibility.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'name': {
                'type': 'string',
                'description': 'New repository name',
              },
              'description': {
                'type': 'string',
                'description': 'New description',
              },
              'private': {
                'type': 'boolean',
                'description': 'Change visibility',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_search_repos',
          description:
              'Search for repositories on GitHub. Returns matching repos with metadata.',
          parameters: {
            'type': 'object',
            'properties': {
              'query': {
                'type': 'string',
                'description': 'Search query (supports GitHub search syntax)',
              },
              'limit': {
                'type': 'integer',
                'description': 'Max results (default: 10, max: 50)',
              },
            },
            'required': ['query'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_fork_repo',
          description: 'Fork a repository to your account or an organization.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {
                'type': 'string',
                'description': 'Owner of the repo to fork',
              },
              'repo': {
                'type': 'string',
                'description': 'Name of the repo to fork',
              },
              'organization': {
                'type': 'string',
                'description':
                    'Optional organization to fork to (default: your account)',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_star_repo',
          description: 'Star a repository.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_unstar_repo',
          description: 'Unstar a repository.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
            },
            'required': ['owner', 'repo'],
          },
        ),

        // ── Branches ──
        OpenRouterService.makeToolDefinition(
          name: 'github_list_branches',
          description: 'List all branches in a repository.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_create_branch',
          description:
              'Create a new branch in a repository from a given SHA.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'branch_name': {
                'type': 'string',
                'description': 'Name for the new branch',
              },
              'sha': {
                'type': 'string',
                'description':
                    'SHA of the commit to base the branch on. Use github_get_repo to find the default branch SHA.',
              },
            },
            'required': ['owner', 'repo', 'branch_name', 'sha'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_delete_branch',
          description: 'Delete a branch from a repository.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'branch': {'type': 'string'},
            },
            'required': ['owner', 'repo', 'branch'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_merge_branches',
          description: 'Merge a branch into another branch.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'base': {
                'type': 'string',
                'description': 'Base branch (the one receiving changes)',
              },
              'head': {
                'type': 'string',
                'description': 'Head branch (the one being merged in)',
              },
              'commit_message': {
                'type': 'string',
                'description': 'Optional custom commit message',
              },
            },
            'required': ['owner', 'repo', 'base', 'head'],
          },
        ),

        // ── Commits ──
        OpenRouterService.makeToolDefinition(
          name: 'github_list_commits',
          description:
              'List commits in a repository. Optionally filter by branch or file path.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'branch': {
                'type': 'string',
                'description': 'Branch name to filter by',
              },
              'path': {
                'type': 'string',
                'description':
                    'Only commits that touch this file path',
              },
              'limit': {
                'type': 'integer',
                'description': 'Max commits to return (default: 30)',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_get_commit',
          description:
              'Get detailed information about a specific commit including stats and files changed.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'sha': {
                'type': 'string',
                'description': 'Commit SHA',
              },
            },
            'required': ['owner', 'repo', 'sha'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_compare_commits',
          description:
              'Compare two commits or branches. Shows diff and commit list between them.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'base': {
                'type': 'string',
                'description': 'Base ref (commit SHA or branch name)',
              },
              'head': {
                'type': 'string',
                'description': 'Head ref (commit SHA or branch name)',
              },
            },
            'required': ['owner', 'repo', 'base', 'head'],
          },
        ),

        // ── File Content ──
        OpenRouterService.makeToolDefinition(
          name: 'github_read_file',
          description:
              'Read a file from a repository. Returns the file content and metadata.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'path': {
                'type': 'string',
                'description': 'File path in the repository',
              },
            },
            'required': ['owner', 'repo', 'path'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_write_file',
          description:
              'Create or update a file in a repository. Creates a new commit with the change. If the file already exists, provide the sha from github_read_file.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'path': {
                'type': 'string',
                'description': 'File path in the repository',
              },
              'content': {
                'type': 'string',
                'description': 'File content as text',
              },
              'message': {
                'type': 'string',
                'description': 'Commit message',
              },
              'sha': {
                'type': 'string',
                'description':
                    'Required when updating an existing file. Get this from github_read_file.',
              },
              'branch': {
                'type': 'string',
                'description':
                    'Optional branch name (defaults to default branch)',
              },
            },
            'required': ['owner', 'repo', 'path', 'content', 'message'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_delete_file',
          description:
              'Delete a file from a repository. Creates a commit with the deletion.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'path': {
                'type': 'string',
                'description': 'File path to delete',
              },
              'message': {
                'type': 'string',
                'description': 'Commit message',
              },
              'sha': {
                'type': 'string',
                'description':
                    'File SHA from github_read_file or github_get_repo',
              },
              'branch': {
                'type': 'string',
                'description': 'Optional branch name',
              },
            },
            'required': ['owner', 'repo', 'path', 'message', 'sha'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_list_contents',
          description:
              'List the contents of a directory in a repository. Use this to explore repo structure.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'path': {
                'type': 'string',
                'description':
                    'Directory path (empty for root). Default: ""',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),

        // ── Pull Requests ──
        OpenRouterService.makeToolDefinition(
          name: 'github_list_pull_requests',
          description:
              'List pull requests in a repository. Filter by state (open, closed, all).',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'state': {
                'type': 'string',
                'description': 'PR state: open, closed, all (default: open)',
                'enum': ['open', 'closed', 'all'],
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_get_pull_request',
          description:
              'Get detailed information about a specific pull request.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'number': {
                'type': 'integer',
                'description': 'Pull request number',
              },
            },
            'required': ['owner', 'repo', 'number'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_create_pull_request',
          description: 'Create a new pull request.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'title': {
                'type': 'string',
                'description': 'PR title',
              },
              'head': {
                'type': 'string',
                'description':
                    'Branch name containing your changes',
              },
              'base': {
                'type': 'string',
                'description': 'Branch you want to merge into',
              },
              'body': {
                'type': 'string',
                'description': 'PR description / body text',
              },
              'draft': {
                'type': 'boolean',
                'description': 'Create as draft PR (default: false)',
              },
            },
            'required': ['owner', 'repo', 'title', 'head', 'base'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_merge_pull_request',
          description: 'Merge a pull request. Supports merge, squash, and rebase strategies.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'number': {
                'type': 'integer',
                'description': 'PR number to merge',
              },
              'merge_method': {
                'type': 'string',
                'description':
                    'Merge method: merge, squash, rebase (default: merge)',
                'enum': ['merge', 'squash', 'rebase'],
              },
              'commit_title': {
                'type': 'string',
                'description': 'Optional custom commit title',
              },
            },
            'required': ['owner', 'repo', 'number'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_update_pull_request',
          description:
              'Update a pull request (title, body, state, base branch).',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'number': {'type': 'integer'},
              'title': {'type': 'string'},
              'body': {'type': 'string'},
              'state': {
                'type': 'string',
                'enum': ['open', 'closed'],
              },
            },
            'required': ['owner', 'repo', 'number'],
          },
        ),

        // ── Issues ──
        OpenRouterService.makeToolDefinition(
          name: 'github_list_issues',
          description:
              'List issues in a repository. Optionally filter by state (open, closed, all) or label.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'state': {
                'type': 'string',
                'description': 'Issue state (default: open)',
                'enum': ['open', 'closed', 'all'],
              },
              'label': {
                'type': 'string',
                'description': 'Filter by label name',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_create_issue',
          description:
              'Create a new issue in a repository.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'title': {'type': 'string'},
              'body': {
                'type': 'string',
                'description': 'Issue body/description',
              },
              'labels': {
                'type': 'array',
                'items': {'type': 'string'},
                'description': 'Labels to apply',
              },
            },
            'required': ['owner', 'repo', 'title'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_create_issue_comment',
          description:
              'Add a comment to an issue or pull request.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'issue_number': {
                'type': 'integer',
                'description': 'Issue or PR number',
              },
              'body': {'type': 'string'},
            },
            'required': ['owner', 'repo', 'issue_number', 'body'],
          },
        ),

        // ── Actions ──
        OpenRouterService.makeToolDefinition(
          name: 'github_list_workflows',
          description:
              'List all GitHub Actions workflows in a repository.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_trigger_workflow',
          description:
              'Trigger a GitHub Actions workflow. Provide the workflow filename (e.g., "main.yml") or ID.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'workflow_id': {
                'type': 'string',
                'description':
                    'Workflow file name (e.g., "ci.yml") or workflow ID',
              },
              'ref': {
                'type': 'string',
                'description':
                    'Branch/tag name to run on (default: main)',
              },
              'inputs': {
                'type': 'object',
                'description':
                    'Workflow inputs as key-value pairs (for workflow_dispatch)',
              },
            },
            'required': ['owner', 'repo', 'workflow_id'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_list_workflow_runs',
          description:
              'List workflow runs. Optionally filter by workflow, status, event, or branch.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'workflow_id': {
                'type': 'string',
                'description': 'Optional: filter by workflow file name or ID',
              },
              'status': {
                'type': 'string',
                'description':
                    'Filter by status: queued, in_progress, completed, success, failure, cancelled',
              },
              'event': {
                'type': 'string',
                'description': 'Filter by event: push, pull_request, workflow_dispatch, etc.',
              },
              'branch': {
                'type': 'string',
                'description': 'Filter by branch name',
              },
            },
            'required': ['owner', 'repo'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_get_workflow_run',
          description:
              'Get detailed information about a specific workflow run including its status, conclusion, and URL.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'run_id': {
                'type': 'integer',
                'description': 'Workflow run ID',
              },
            },
            'required': ['owner', 'repo', 'run_id'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_get_workflow_logs',
          description:
              'Get the logs for a workflow run. Use this to debug failed workflows.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'run_id': {
                'type': 'integer',
                'description': 'Workflow run ID to get logs for',
              },
            },
            'required': ['owner', 'repo', 'run_id'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_cancel_workflow_run',
          description: 'Cancel a running workflow run.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'run_id': {'type': 'integer'},
            },
            'required': ['owner', 'repo', 'run_id'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_rerun_workflow',
          description: 'Rerun a failed or cancelled workflow run.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'run_id': {'type': 'integer'},
            },
            'required': ['owner', 'repo', 'run_id'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_list_artifacts',
          description:
              'List artifacts from a workflow run.',
          parameters: {
            'type': 'object',
            'properties': {
              'owner': {'type': 'string'},
              'repo': {'type': 'string'},
              'run_id': {'type': 'integer'},
            },
            'required': ['owner', 'repo', 'run_id'],
          },
        ),
        OpenRouterService.makeToolDefinition(
          name: 'github_get_user',
          description:
              'Get information about the authenticated GitHub user or any GitHub user.',
          parameters: {
            'type': 'object',
            'properties': {
              'username': {
                'type': 'string',
                'description':
                    'Optional: username to look up. If empty, returns authenticated user info.',
              },
            },
          },
        ),
      ];
}

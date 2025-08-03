# Verify Member Exists Action

This GitHub Action validates if a specified GitHub user is a member of an organization using the GitHub API. It returns whether the user is a member (`true` or `false`).

## Features
- Validates a GitHub user’s membership in an organization by making a GET request to the GitHub API.
- Expects a slugified username for API compatibility.
- Outputs whether the user is a member of the organization (`member-exists`).
- Requires a GitHub token with organization read permissions for authentication.
- Includes debug logging to ensure step output visibility in the GitHub Actions UI.

## Inputs
| Name          | Description                                              | Required | Default |
|---------------|----------------------------------------------------------|----------|---------|
| `member-name` | The slugified username of the member to validate (e.g., "john-doe"). | Yes      | N/A     |
| `token`       | GitHub token with organization read permissions.         | Yes      | N/A     |
| `owner`       | The owner of the organization (user or organization).    | Yes      | N/A     |

## Outputs
| Name            | Description                                              |
|-----------------|----------------------------------------------------------|
| `result`       | Result of the action ("success" or "failure")         |
| `member-exists` | Whether the user is a member of the organization (`true` or `false`). |
| `error_message`| Error message if the member existence check fails. |

## Usage
1. **Add the Action to Your Workflow**:
   Create or update a workflow file (e.g., `.github/workflows/verify-member-exists.yml`) in your repository.

2. **Reference the Action**:
   Use the action by referencing the repository and version (e.g., `v1`).

3. **Example Workflow**:
   ```yaml
   name: Verify Member Exists
   on:
     workflow_dispatch:
       inputs:
         member-name:
           description: 'Slugified username of the member to verify (e.g., "john-doe")'
           required: true
   jobs:
     verify-member:
       runs-on: ubuntu-latest
       steps:
         - name: Verify Member Exists
           id: verify
           uses: la-actions/verify-member-exists@v1.0.0
           with:
             member-name: ${{ github.event.inputs.member-name }}
             token: ${{ secrets.GITHUB_TOKEN }}
             owner: ${{ github.repository_owner }}
         - name: Print Result
           run: |
             if [[ "${{ steps.verify.outputs.member-exists }}" == "true" ]]; then
               echo "Member ${{ github.event.inputs.member-name }} exists in organization ${{ github.repository_owner }}."
             else
               echo "Member ${{ github.event.inputs.member-name }} does not exist in organization ${{ github.repository_owner }}."
               exit 1
             fi

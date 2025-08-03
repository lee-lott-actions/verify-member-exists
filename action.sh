 #!/bin/bash

verify_member_exists() {
  local member_name="$1"
  local token="$2"
  local owner="$3"

  if [ -z "$member_name" ] || [ -z "$token" ] || [ -z "$owner" ]; then
    echo "Error: Missing required parameters"
    echo "result=failure" >> "$GITHUB_OUTPUT"
    echo "error-message=Missing required parameters: member_name, owner, and token must be provided." >> "$GITHUB_OUTPUT"    
    echo "member-exists=false" >> "$GITHUB_OUTPUT"
    return
  fi

  echo "Attempting to verify member '$member_name' exists in organization '$owner'"

   # Use MOCK_API if set, otherwise default to GitHub API
  local api_base_url="${MOCK_API:-https://api.github.com}"
  
  # Make API request to check if the member exists
  RESPONSE=$(curl -s -o response.json -w "%{http_code}" \
    -H "Authorization: Bearer $token" \
    -H "Accept: application/vnd.github+json" \
    -H "Content-Type: application/json" \
    "$api_base_url/orgs/$owner/members/$member_name")

  echo "API Response Code: $RESPONSE"  
  cat response.json

  if [ "$RESPONSE" -eq 204 ]; then
    echo "Member '$member_name' exists in organization '$owner'"
    echo "result=success" >> "$GITHUB_OUTPUT"
    echo "member-exists=true" >> "$GITHUB_OUTPUT"
  else
    echo "Member '$member_name' does not exist in organization '$owner'"
    echo "result=success" >> "$GITHUB_OUTPUT"
    echo "member-exists=false" >> "$GITHUB_OUTPUT"
  fi
}

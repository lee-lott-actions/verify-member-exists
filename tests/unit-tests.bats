#!/usr/bin/env bats

# Load the Bash script
load ../action.sh

# Mock the curl command to simulate API responses
mock_curl() {
  local http_code=$1
  local response_file=$2
  echo "$http_code"
  cat "$response_file" > response.json
}

# Setup function to run before each test
setup() {
  export GITHUB_OUTPUT=$(mktemp)
}

# Teardown function to clean up after each test
teardown() {
  rm -f response.json "$GITHUB_OUTPUT" mock_response.json
}

@test "verify_member_exists succeeds with HTTP 204" {
  echo '' > mock_response.json
  curl() { mock_curl "204" mock_response.json; }
  export -f curl

  run verify_member_exists "test-user" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'member-exists' "$GITHUB_OUTPUT")" == "member-exists=true" ]
}

@test "verify_member_exists fails with HTTP 404 (not a member)" {
  echo '{"message": "Not Found"}' > mock_response.json
  curl() { mock_curl "404" mock_response.json; }
  export -f curl

  run verify_member_exists "test-user" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=success" ]
  [ "$(grep 'member-exists' "$GITHUB_OUTPUT")" == "member-exists=false" ]
}

@test "verify_member_exists fails with empty member_name" {
  run verify_member_exists "" "fake-token" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'member-exists' "$GITHUB_OUTPUT")" == "member-exists=false" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: member_name, owner, and token must be provided." ]
}

@test "verify_member_exists fails with empty token" {
  run verify_member_exists "test-user" "" "test-owner"

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'member-exists' "$GITHUB_OUTPUT")" == "member-exists=false" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: member_name, owner, and token must be provided." ]
}

@test "verify_member_exists fails with empty owner" {
  run verify_member_exists "test-user" "fake-token" ""

  [ "$status" -eq 0 ]
  [ "$(grep 'result' "$GITHUB_OUTPUT")" == "result=failure" ]
  [ "$(grep 'member-exists' "$GITHUB_OUTPUT")" == "member-exists=false" ]
  [ "$(grep 'error-message' "$GITHUB_OUTPUT")" == "error-message=Missing required parameters: member_name, owner, and token must be provided." ]
}

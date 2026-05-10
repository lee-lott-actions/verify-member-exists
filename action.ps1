function Test-MemberExists {
    param(
        [string]$MemberName,
        [string]$Token,
        [string]$Owner
    )

    # Validate required parameters
    if ([string]::IsNullOrEmpty($MemberName) -or
        [string]::IsNullOrEmpty($Token) -or
        [string]::IsNullOrEmpty($Owner)) {
        Write-Host "Error: Missing required parameters"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=Missing required parameters: member_name, owner, and token must be provided."
        Add-Content -Path $env:GITHUB_OUTPUT -Value "member-exists=false"
        return
    }

    Write-Host "Attempting to verify member '$MemberName' exists in organization '$Owner'"

    # Use MOCK_API if set, otherwise default to GitHub API
    $apiBaseUrl = $env:MOCK_API
    if (-not $apiBaseUrl) { $apiBaseUrl = "https://api.github.com" }
    $uri = "$apiBaseUrl/orgs/$Owner/members/$MemberName"

    $headers = @{
        Authorization = "Bearer $Token"
        Accept = "application/vnd.github+json"
        "X-GitHub-Api-Version" = "2026-03-10"
    }

    try {
        $response = Invoke-WebRequest -Uri $uri -Headers $headers -Method Get

        Write-Host "API Response Code: $($response.StatusCode)"
        Write-Host $response.Content

        if ($response.StatusCode -eq 204) {
            Write-Host "Member '$MemberName' exists in organization '$Owner'"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "member-exists=true"
        } else {
            Write-Host "Member '$MemberName' does not exist in organization '$Owner'"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "result=success"
            Add-Content -Path $env:GITHUB_OUTPUT -Value "member-exists=false"
        }
    } catch {
		$errorMsg = "Error: Failed to verify member '$MemberName' exists in organization '$Owner'. Exception: $($_.Exception.Message)"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "result=failure"
        Add-Content -Path $env:GITHUB_OUTPUT -Value "member-exists=false"
		Add-Content -Path $env:GITHUB_OUTPUT -Value "error-message=$errorMsg"
		Write-Host $errorMsg
    }
}

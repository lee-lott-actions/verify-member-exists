Describe "Test-MemberExists" {
    BeforeAll {
        $script:MemberName = "test-user"
        $script:Owner      = "test-owner"
        $script:Token      = "fake-token"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
    BeforeEach {
        $env:GITHUB_OUTPUT = "$PSScriptRoot/github_output.temp"
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        $env:MOCK_API = $script:MockApiUrl
    }
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Variable -Name MOCK_API -Scope Global -ErrorAction SilentlyContinue
    }

    It "verify_member_exists succeeds with HTTP 204" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 204; Content = '' }
        }
        Test-MemberExists -MemberName $MemberName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "member-exists=true"
    }

    It "verify_member_exists fails with HTTP 404 (not a member)" {
        Mock Invoke-WebRequest {
            [PSCustomObject]@{ StatusCode = 404; Content = '{"message": "Not Found"}' }
        }
        Test-MemberExists -MemberName $MemberName -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=success"
        $output | Should -Contain "member-exists=false"
    }

    It "verify_member_exists fails with empty member_name" {
        Test-MemberExists -MemberName "" -Token $Token -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "member-exists=false"
        $output | Should -Contain "error-message=Missing required parameters: member_name, owner, and token must be provided."
    }

    It "verify_member_exists fails with empty token" {
        Test-MemberExists -MemberName $MemberName -Token "" -Owner $Owner
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "member-exists=false"
        $output | Should -Contain "error-message=Missing required parameters: member_name, owner, and token must be provided."
    }

    It "verify_member_exists fails with empty owner" {
        Test-MemberExists -MemberName $MemberName -Token $Token -Owner ""
        $output = Get-Content $env:GITHUB_OUTPUT
        $output | Should -Contain "result=failure"
        $output | Should -Contain "member-exists=false"
        $output | Should -Contain "error-message=Missing required parameters: member_name, owner, and token must be provided."
    }
}
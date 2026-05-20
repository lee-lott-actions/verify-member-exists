Describe "Test-MemberExists" {
    BeforeAll {
        $script:MemberName = "test-user"
        $script:Owner      = "test-owner"
        $script:Token      = "fake-token"
        $script:MockApiUrl = "http://127.0.0.1:3000"
        . "$PSScriptRoot/../action.ps1"
    }
	
	BeforeEach {
        $env:GITHUB_OUTPUT = New-TemporaryFile
        $env:MOCK_API = $script:MockApiUrl
    }
	
    AfterEach {
        if (Test-Path $env:GITHUB_OUTPUT) { Remove-Item $env:GITHUB_OUTPUT }
        Remove-Item Env:MOCK_API -ErrorAction SilentlyContinue
    }

	Context "Success Cases" {
	    It "unit: Test-MemberExists succeeds with HTTP 204" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 204; Content = '' }
	        }
	        Test-MemberExists -MemberName $MemberName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "member-exists=true"
	    }
	}

	Context "HTTP Failure Cases" {
	    It "unit: Test-MemberExists fails with HTTP 404" {
	        Mock Invoke-WebRequest {
	            [PSCustomObject]@{ StatusCode = 404; Content = '{"message": "Not Found"}' }
	        }
	        Test-MemberExists -MemberName $MemberName -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=success"
	        $output | Should -Contain "member-exists=false"
	    }
	}

	Context "Parameter Validation Failure Cases" {
	    It "unit: Test-MemberExists fails with empty MemberName" {
	        Test-MemberExists -MemberName "" -Token $Token -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "member-exists=false"
	        $output | Should -Contain "error-message=Missing required parameters: member_name, owner, and token must be provided."
	    }
	
	    It "unit: Test-MemberExists fails with empty Token" {
	        Test-MemberExists -MemberName $MemberName -Token "" -Owner $Owner
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "member-exists=false"
	        $output | Should -Contain "error-message=Missing required parameters: member_name, owner, and token must be provided."
	    }
	
	    It "unit: Test-MemberExists fails with empty Owner" {
	        Test-MemberExists -MemberName $MemberName -Token $Token -Owner ""
	        $output = Get-Content $env:GITHUB_OUTPUT
	        $output | Should -Contain "result=failure"
	        $output | Should -Contain "member-exists=false"
	        $output | Should -Contain "error-message=Missing required parameters: member_name, owner, and token must be provided."
	    }
	}

	Context "Exception Failure Cases" {
		It "unit: Test-MemberExists fails with exception" {
			Mock Invoke-WebRequest { throw "API Error" }
	
			Test-MemberExists -MemberName $MemberName -Token $Token -Owner $Owner
	
			$output = Get-Content $env:GITHUB_OUTPUT
			$output | Should -Contain "result=failure"
			$output | Should -Contain "member-exists=false"
			$output | Where-Object { $_ -match "^error-message=Error: Failed to verify member '$MemberName' exists in organization '$Owner'\. Exception:" } |
				Should -Not -BeNullOrEmpty
		}	
	}
}

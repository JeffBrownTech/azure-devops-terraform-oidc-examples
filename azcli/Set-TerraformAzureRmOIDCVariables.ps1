#!/usr/bin/env pwsh
#Requires -Version 7.2

if ($env:SYSTEM_DEBUG -eq "true") {
    $InformationPreference = "Continue"
    $VerbosePreference = "Continue"
    $DebugPreference = "Continue"
    
    Get-ChildItem -Path Env: -Force -Recurse -Include * | Sort-Object -Property Name | Format-Table -AutoSize | Out-String
}

# Propagate Azure context to Terraform
az account show 2>$null | ConvertFrom-Json | Set-Variable account

if ($null -eq $account) {
    throw "Not logged into Azure CLI, no context to propagate as ARM_* environment variables"
}

if (![guid]::TryParse($account.user.name, [ref][guid]::Empty)) {
    throw "Azure CLI logged in with a User Principal instead of a Service Principal"
}

$env:ARM_CLIENT_ID       ??= $account.user.name
$env:ARM_CLIENT_SECRET   ??= $env:servicePrincipalKey # requires addSpnToEnvironment: true
$env:ARM_OIDC_TOKEN      ??= $env:idToken # requires addSpnToEnvironment: true
$env:ARM_SUBSCRIPTION_ID ??= $account.id  
$env:ARM_TENANT_ID       ??= $account.tenantId
$env:ARM_USE_CLI         ??= (!($env:idToken -or $env:servicePrincipalKey)).ToString().ToLower()
$env:ARM_USE_OIDC        ??= ($null -ne $env:idToken).ToString().ToLower()

if ($env:ARM_CLIENT_SECRET) {
    "Using ARM_CLIENT_SECRET"
}
elseif ($env:ARM_OIDC_TOKEN) {
    "Using ARM_OIDC_TOKEN"
}
else {
    throw -Message "No credentials found to propagate as ARM_* environment variables."
}

# Outputs non-secret/token values for validation
"`nTerraform Azure provider environment variables:"
Get-ChildItem -Path Env: -Recurse -Include ARM_* | ForEach-Object {
    if ($_.Name -imatch 'SECRET|TOKEN') {
        $_.Value = "***"
    }
    $_
} | Sort-Object -Property Name | Format-Table -HideTableHeader

# Gather ARM* environment variables and set pipeline variables for use in other tasks in the same pipeline job
Get-ChildItem -Path Env: -Recurse -Include ARM_* | ForEach-Object {
    Write-Host "##vso[task.setvariable variable=$($_.Name);]$($_.Value)"
}

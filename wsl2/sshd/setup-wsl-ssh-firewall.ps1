param(
    [Parameter(Mandatory = $true)]
    [string[]]$RemoteAddress,

    [ValidateRange(1, 65535)]
    [int]$Port = 22
)

$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$adminRole = [Security.Principal.WindowsBuiltInRole]::Administrator
if (-not $principal.IsInRole($adminRole)) {
    throw 'Run this script from PowerShell opened as Administrator.'
}

$vmCreatorId = '{40E0AC32-46A5-438A-A0B2-2B479E8F2E90}'
$ruleName = 'Codex-WSL-SSH'
$rule = Get-NetFirewallHyperVRule -Name $ruleName -ErrorAction SilentlyContinue
$parameters = @{
    Direction       = 'Inbound'
    VMCreatorId     = $vmCreatorId
    Protocol        = 'TCP'
    LocalPorts      = $Port
    RemoteAddresses = $RemoteAddress
    Action          = 'Allow'
    Enabled         = $true
}

if ($null -eq $rule) {
    New-NetFirewallHyperVRule -Name $ruleName `
        -DisplayName "WSL SSH (TCP $Port)" @parameters | Out-Null
} else {
    Set-NetFirewallHyperVRule -Name $ruleName `
        -NewDisplayName "WSL SSH (TCP $Port)" @parameters | Out-Null
}

Get-NetFirewallHyperVRule -Name $ruleName |
    Select-Object Name, DisplayName, Enabled, Direction, Protocol,
        LocalPorts, RemoteAddresses, Action |
    Format-List

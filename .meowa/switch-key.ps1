param(
	[Parameter(Mandatory = $true)]
	[string]$Profile
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root ".meowa\profiles\$Profile.env"
if (-not (Test-Path $source)) {
	throw "Profile not found: $source"
}

$targets = @(
	(Join-Path $root ".env"),
	(Join-Path $root ".agents\skills\game-assets\.env")
)
foreach ($target in $targets) {
	Copy-Item -Force $source $target
}
Set-Content -Encoding ascii -NoNewline -Path (Join-Path $root ".meowa\active") -Value $Profile
Write-Output "Active Meowa profile: $Profile"

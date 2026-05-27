param (
    [string]$ExePath = "..\src\TiaMcpServer\bin\Any CPU\Debug\net48\TiaMcpServer.exe",
    [string]$TiaVersion = "20.0"
)

# 1. Check for Admin rights
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator to write to HKLM."
    exit 1
}

$file = Get-Item $ExePath -ErrorAction SilentlyContinue
if (-not $file.Exists) {
    Write-Error "File not found: $ExePath"
    exit 1
}

# 2. Compute the SHA256 Hash
$hash = (Get-FileHash $file.FullName -Algorithm SHA256).Hash

# 3. Format the DateModified exactly how Siemens expects it (UTC, yyyy/MM/dd HH:mm:ss.fff)
$dateModified = $file.LastWriteTimeUtc.ToString("yyyy/MM/dd HH:mm:ss.fff")

# 4. Build the Registry Path
$regPath = "HKLM:\SOFTWARE\Siemens\Automation\Openness\$TiaVersion\Whitelist\$($file.Name)\Client"

# 5. Write to the Registry
if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

Set-ItemProperty -Path $regPath -Name "FileHash" -Value $hash
Set-ItemProperty -Path $regPath -Name "DateModified" -Value $dateModified

Write-Host "Successfully whitelisted $($file.Name) for TIA Portal V$TiaVersion" -ForegroundColor Green
Write-Host "Hash: $hash" -ForegroundColor DarkGray

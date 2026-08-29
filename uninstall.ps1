#Requires -Version 5.1
<#
.SYNOPSIS
  Stop Alula and remove its Windows startup shortcut. Does not uninstall AutoHotkey.
#>
$ErrorActionPreference = "Stop"
$startupDir = [Environment]::GetFolderPath("Startup")
$linkPath = Join-Path $startupDir "Alula.lnk"
$legacyLink = Join-Path $startupDir "WacomPenSwitcher.lnk"

Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey64.exe' OR Name = 'AutoHotkey.exe'" -ErrorAction SilentlyContinue |
    Where-Object { $_.CommandLine -match 'Alula\.ahk|WacomPenSwitcher\.ahk' } |
    ForEach-Object {
        Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        Write-Host "Stopped process $($_.ProcessId)."
    }

foreach ($link in @($linkPath, $legacyLink)) {
    if (Test-Path $link) {
        Remove-Item $link -Force
        Write-Host "Removed $link"
    }
}

Write-Host "Alula will not start with Windows. AutoHotkey was left installed."

#Requires -Version 5.1
<#
.SYNOPSIS
  Install Alula: AutoHotkey v2 (if needed), optional startup shortcut, then launch.
.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\install.ps1
#>
[CmdletBinding()]
param(
    [switch]$NoStart,
    [switch]$NoStartup
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$ahkScript = Join-Path $root "Alula.ahk"
$config = Join-Path $root "config.ini"
$example = Join-Path $root "config.example.ini"

function Find-AutoHotkey {
    $candidates = @(
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey.exe",
        "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
        "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey64.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path $path) { return $path }
    }
    $cmd = Get-Command "AutoHotkey64.exe" -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    return $null
}

if (-not (Test-Path $ahkScript)) {
    throw "Alula.ahk was not found next to install.ps1. Run this from the Alula folder."
}

if (-not (Test-Path $config) -and (Test-Path $example)) {
    Copy-Item $example $config
    Write-Host "Created config.ini from the example."
}

$ahk = Find-AutoHotkey
if (-not $ahk) {
    Write-Host "Installing AutoHotkey v2 with winget..."
    winget install --id AutoHotkey.AutoHotkey -e --accept-package-agreements --accept-source-agreements
    $ahk = Find-AutoHotkey
}

if (-not $ahk) {
    throw "AutoHotkey v2 was not found. Install it from https://www.autohotkey.com/ then run this script again, or follow docs\install-manual.md"
}

$startupDir = [Environment]::GetFolderPath("Startup")
$linkPath = Join-Path $startupDir "Alula.lnk"
$legacyLink = Join-Path $startupDir "WacomPenSwitcher.lnk"

if (-not $NoStartup) {
    $w = New-Object -ComObject WScript.Shell
    $s = $w.CreateShortcut($linkPath)
    $s.TargetPath = $ahk
    $s.Arguments = "`"$ahkScript`""
    $s.WorkingDirectory = $root
    $s.Description = "Alula pen button helper"
    $s.Save()
    Write-Host "Startup shortcut: $linkPath"
}

if (Test-Path $legacyLink) {
    Remove-Item $legacyLink -Force
    Write-Host "Removed old WacomPenSwitcher startup shortcut."
}

if (-not $NoStart) {
    Get-CimInstance Win32_Process -Filter "Name = 'AutoHotkey64.exe' OR Name = 'AutoHotkey.exe'" -ErrorAction SilentlyContinue |
        Where-Object { $_.CommandLine -match 'Alula\.ahk' } |
        ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }
    Start-Process -FilePath $ahk -ArgumentList "`"$ahkScript`""
    Write-Host "Alula is running (tray icon near the clock)."
}

Write-Host ""
Write-Host "Map your tablet buttons, then it is ready:"
Write-Host "  Rear / second button  ->  4th click (Back)     zoom / pan"
Write-Host "  Front / first button  ->  5th click (Forward)  undo / sample"
Write-Host ""
Write-Host "Wacom Center: device -> Pen -> each barrel button."
Write-Host "Any tablet or mouse that can send 4th/5th click works. See README.md"

#!/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
# is_vim_ancestor.ps1
#
# Exit 0 if any ancestor of the current process (by Windows PID) is a
# vim-like executable. Exit 1 otherwise.
#
# Usage:
#   powershell -NonInteractive -NoProfile -File is_vim_ancestor.ps1 [-Verbose]

param(
    [switch]$Verbose
)

# Ensure exit codes propagate correctly to the calling shell
$ErrorActionPreference = 'Stop'

$VimPattern = '^(.*[/\\])?g?\.?(view|l?n?vim?x?|fzf)(diff)?(-wrapped)?$'

function Log {
    param([string]$msg)
    if ($Verbose) { Write-Host "[DEBUG] $msg" -ForegroundColor DarkGray }
}

Log "Loading Win32_Process table via CIM..."

$procTable = @{}
Get-CimInstance Win32_Process | ForEach-Object {
    $procTable[[int]$_.ProcessId] = @{
        Parent = [int]$_.ParentProcessId
        Name   = $_.Name
        Path   = $_.ExecutablePath
    }
}

Log "Loaded $($procTable.Count) processes."

# $PID is the built-in PowerShell read-only variable for the current Windows PID.
$curPid = $PID
Log "Starting ancestor walk from Windows PID=$curPid"

$visited = @{}
$depth   = 0

while ($true) {
    if (-not $procTable.ContainsKey($curPid)) {
        Log "PID=$curPid not found in process table -- reached top."
        break
    }

    if ($visited.ContainsKey($curPid)) {
        Log "PID=$curPid already visited -- loop detected, stopping."
        break
    }
    $visited[$curPid] = $true

    $entry    = $procTable[$curPid]
    $name     = $entry.Name
    $parent   = $entry.Parent
    $fullPath = if ($entry.Path) { $entry.Path } else { "(unknown)" }
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($name).ToLower()

    Log "Depth=$depth curPid=$curPid parent=$parent name=$name baseName=$baseName path=$fullPath"

    if ($baseName -imatch $VimPattern) {
        Log "MATCH: '$baseName' (curPid=$curPid) matches vim pattern."
        Log "Exiting 0 -- vim ancestor found."
        [Environment]::Exit(0)
    }

    if ($parent -eq 0 -or $parent -eq $curPid) {
        Log "Reached root (parent=$parent). Stopping."
        break
    }

    $curPid = $parent
    $depth++

    if ($depth -gt 64) {
        Log "Depth limit reached. Stopping."
        break
    }
}

Log "No vim ancestor found. Exiting 1."
[Environment]::Exit(1)

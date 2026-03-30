#Requires -Version 5.1
<#
.SYNOPSIS
  Copy template directories from fahidsarker/startx (or STARTX_REPO / --repo).
#>
$ErrorActionPreference = 'Stop'

function Show-Usage {
  @'
Usage: get-template.ps1 [options] <template> [<template> ...]

Clone the repo once (shallow), then copy each template folder to a destination.

Options:
  --repo OWNER/NAME   GitHub repo (default: fahidsarker/startx, or STARTX_REPO)
  --out DIR           Output directory (only with exactly one template)
  --prefix DIR        Place each template under DIR/<name>/ (optional)
  -f, --force         Overwrite non-empty destination without prompting
  -h, --help          Show this help

Examples:
  .\get-template.ps1 express-js
  .\get-template.ps1 express-js --out .\my-api
  .\get-template.ps1 express-js other-template
  .\get-template.ps1 --prefix .\starters express-js other-template
'@ | Write-Host
}

function Test-DirNonempty {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return $false }
  return @(Get-ChildItem -LiteralPath $Path -Force -ErrorAction SilentlyContinue).Count -gt 0
}

function Confirm-Overwrite {
  param([string]$Dest)
  if ($script:Force) { return $true }
  $stdinOk = -not [Console]::IsInputRedirected
  if ($stdinOk) {
    $ans = Read-Host "Destination is not empty: ${Dest}. Remove and replace? [y/N]"
    return ($ans -eq 'y' -or $ans -eq 'Y' -or $ans -ieq 'yes')
  }
  Write-Host "Error: ${Dest} exists and is not empty. Use -Force to overwrite (non-interactive)." -ForegroundColor Red
  return $false
}

function Ensure-Parent {
  param([string]$Dest)
  $parent = Split-Path -Parent -LiteralPath $Dest
  if ([string]::IsNullOrEmpty($parent)) { $parent = '.' }
  if ($parent -ne '.' -and $parent -ne '/' -and $parent -ne '\') {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
}

function Show-TemplateHints {
  param([string]$Root)
  Write-Host 'Top-level directories in clone:' -ForegroundColor Yellow
  Get-ChildItem -LiteralPath $Root -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
    if ($_.Name -notmatch '^\.') {
      Write-Host "  $($_.Name)"
    }
  }
}

$Repo = if ($env:STARTX_REPO) { $env:STARTX_REPO } else { 'fahidsarker/startx' }
$Out = ''
$Prefix = ''
$script:Force = $false
$TEMPLATES = [System.Collections.Generic.List[string]]::new()

$argv = @($args)
$i = 0
while ($i -lt $argv.Count) {
  $a = $argv[$i]
  switch ($a) {
    '--repo' {
      if ($i + 1 -ge $argv.Count) { Write-Host 'Error: --repo requires OWNER/NAME' -ForegroundColor Red; exit 1 }
      $Repo = $argv[$i + 1]
      $i += 2
    }
    '--out' {
      if ($i + 1 -ge $argv.Count) { Write-Host 'Error: --out requires a directory' -ForegroundColor Red; exit 1 }
      $Out = $argv[$i + 1]
      $i += 2
    }
    '--prefix' {
      if ($i + 1 -ge $argv.Count) { Write-Host 'Error: --prefix requires a directory' -ForegroundColor Red; exit 1 }
      $Prefix = $argv[$i + 1]
      $i += 2
    }
    { $_ -eq '--force' -or $_ -eq '-f' } {
      $script:Force = $true
      $i += 1
    }
    { $_ -eq '--help' -or $_ -eq '-h' } {
      Show-Usage
      exit 0
    }
    default {
      if ($a.StartsWith('-')) {
        Write-Host "Error: unknown option: $a" -ForegroundColor Red
        Show-Usage
        exit 1
      }
      $TEMPLATES.Add($a) | Out-Null
      $i += 1
    }
  }
}

if ($TEMPLATES.Count -eq 0) {
  Write-Host 'Error: at least one template name is required.' -ForegroundColor Red
  Show-Usage
  exit 1
}

if ($Out -ne '' -and $TEMPLATES.Count -gt 1) {
  Write-Host 'Error: --out can only be used with exactly one template.' -ForegroundColor Red
  exit 1
}

if ($Out -ne '' -and $Prefix -ne '') {
  Write-Host 'Error: use only one of --out and --prefix.' -ForegroundColor Red
  exit 1
}

$tmpdir = Join-Path ([System.IO.Path]::GetTempPath()) ("startx_temp." + [Guid]::NewGuid().ToString())
try {
  New-Item -ItemType Directory -Path $tmpdir -Force | Out-Null
  $cloneUrl = "https://github.com/$Repo.git"
  git clone --depth 1 $cloneUrl $tmpdir
  if (-not $?) { exit 1 }

  foreach ($t in $TEMPLATES) {
    $src = Join-Path $tmpdir $t
    if (-not (Test-Path -LiteralPath $src -PathType Container)) {
      Write-Host "Error: no template directory '${t}' in ${Repo}." -ForegroundColor Red
      Show-TemplateHints -Root $tmpdir
      exit 1
    }

    if ($Out -ne '') {
      $dest = $Out
    }
    elseif ($Prefix -ne '') {
      $prefixNorm = $Prefix.TrimEnd('/', '\')
      $dest = Join-Path $prefixNorm $t
    }
    else {
      $dest = Join-Path '.' $t
    }

    Ensure-Parent -Dest $dest

    if (Test-DirNonempty -Path $dest) {
      if (-not (Confirm-Overwrite -Dest $dest)) { exit 1 }
      Remove-Item -LiteralPath $dest -Recurse -Force
    }

    Copy-Item -LiteralPath $src -Destination $dest -Recurse -Force
    Write-Host "Copied '${t}' -> $dest"
  }
}
finally {
  if (Test-Path -LiteralPath $tmpdir) {
    Remove-Item -LiteralPath $tmpdir -Recurse -Force -ErrorAction SilentlyContinue
  }
}

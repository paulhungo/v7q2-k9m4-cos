<#
.SYNOPSIS
  Deliver an answer from the computer-side Ox chat into Paul's OX Inbox.
.DESCRIPTION
  1. Appends the message to messages.json
  2. Commits + pushes to GitHub Pages (site updates within ~1 min)
  3. Fires an ntfy push so Paul's phone pops up instantly
.EXAMPLE
  .\Send-OXMessage.ps1 -Title "LOI draft ready" -Body "Paste the full answer text here..."
.EXAMPLE
  .\Send-OXMessage.ps1 -Title "Reminder" -Body "..." -NoPush   # inbox only, no phone alert
#>
param(
  [Parameter(Mandatory = $true)][string]$Body,
  [string]$Title = "Message from Ox",
  [string]$Topic = "atf-ox-p5wq8zr2nk4m",
  [switch]$NoPush
)
$ErrorActionPreference = "Stop"
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $dir

# ---- 1) Append to messages.json -------------------------------------------
$id = "m" + (Get-Date).ToString("yyyyMMddHHmmss")
$msgPath = Join-Path $dir "messages.json"

try { $json = Get-Content $msgPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { $json = $null }
if (-not $json -or -not $json.messages) { $json = [pscustomobject]@{ messages = @() } }

$list = @($json.messages) + [pscustomobject]@{
  id    = $id
  ts    = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ss")
  title = $Title
  body  = $Body
}
if ($list.Count -gt 300) { $list = $list | Select-Object -Last 300 }

$out = [pscustomobject]@{ messages = $list }
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($msgPath, ($out | ConvertTo-Json -Depth 5), $utf8NoBom)

# ---- 2) Publish to the website --------------------------------------------
git add messages.json | Out-Null
git commit -m ("OX message: " + $Title) | Out-Null
git push origin main | Out-Null

# ---- 3) Ring the phone ------------------------------------------------------
$sentPhone = $false
if (-not $NoPush) {
  $safeTitle = ($Title -replace "[^\x20-\x7E]", "").Trim()
  if (-not $safeTitle) { $safeTitle = "Message from Ox" }
  Invoke-RestMethod -Method Post -Uri "https://ntfy.sh/$Topic" `
    -Headers @{ Title = $safeTitle } `
    -ContentType "text/plain; charset=utf-8" -Body $Body | Out-Null
  $sentPhone = $true
}

Write-Host ""
Write-Host "Delivered." -ForegroundColor Green
Write-Host " - Inbox updated (live on the site within ~1 minute)"
if ($sentPhone) { Write-Host " - Phone alert sent via ntfy topic '$Topic'" }

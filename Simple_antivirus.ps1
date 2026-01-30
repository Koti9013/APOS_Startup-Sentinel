[Console]::OutputEncoding = [System.text.Encoding]::UTF8
$Host.UI.RawUI.WindowTitle = "Simple antivirus - v1.0"

$localPath = $PSCommandPath
$tempPath  = "$env:TEMP\update_temp.ps1"

Write-Host "--- Cheching for updates ---" -ForegroundColor Cyan

$filesToUpdate = @("Simple antivirus.ps1", "README.md", "LICENSE.md")
$repoUrl = 

foreach ($fileName in $filesToUpdate) {
    $localPath = Join-Path $PSScriptRoot $fileName
    $tempPath = "$localPath.tmp"
    $remoteUrl = #Add

    try {
        Invoke-WebRequest -Uri $remoteUrl -OutFile $tempPath -ErrorAction Stop -TimeoutSec 10
        
        $localHash = if (Test-Path $localPath) { (Get-FileHash $localPath).Hash } else { "" }
        $remoteHash = (Get-FileHash $tempPath).Hash

        if ($localHash -ne $remoteHash) {
            Write-Host "[!] Updating: $fileName" -ForegroundColor Yellow
            Move-Item -Path $tempPath -Destination $localPath -Force
        } else {
            Write-Host "[✓] $fileName is up to date." -ForegroundColor Green
            Remove-Item $tempPath
        }
    } catch {
        Write-Host "[!] Could not update $fileName (No connection)" -ForegroundColor Gray
        if (Test-Path $tempPath) { Remove-Item $tempPath }
    }
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Asking for administrator rights..." -ForegroundColor Yellow
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}



Write-Host "==================================================="
Write-Host "             Scanning the system...                "
Write-Host "==================================================="

$tasks = Get-ScheduledTask | Where-Object { $_.State -ne 'Disabled' }
$found = $false


foreach ($task in $tasks) {
    $allActions = @()
    foreach ($act in $Actions) {
        if ($act.Execute) { $allActions += $act.Execute }
        if ($act.Arguments) { $allActions += $act.Arguments }
}
$actionString = $allActions -join  " "

if ($actionString -match 'Appdata|Temp' -and $actionString -notmatch 'OneDrive|Discord|Steam|Zoom') {
   $found = $true
   Write-Host "[!] INTRUDER FOUND!" -ForegroundColor Red
   Write-Host "Task: $($task.TaskName)" -ForegroundColor Yellow
   Write-Host "Path: $actionString" -ForegroundColor White


   $choice = Read-Host "Disable this task? (y/n)"
   if ($choice -eq 'y') {
       Disable-ScheduledTask -TaskName $task.TaskName
       Write-Host "Succesfully disabled!" -ForegroundColor Cyan
   } else {
       Write-Host "Task remains enabled." -ForegroundColor Gray
   }
   Write-Host "---------------------------"
  }
 } 
 if (-not $found) {Write-Host "No threats found."-ForegroundColor Green}
 Write-Host "Scan complete"
 pause
 exit
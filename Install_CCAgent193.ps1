$logsPath = "C:\NextgenId\CCAgent\Logs"

if (Test-Path -LiteralPath $logsPath -PathType Leaf) {
    Remove-Item -LiteralPath $logsPath -Force
    Write-Host "DELETED: $logsPath (was a file, not a directory)"
}


$logSrc = "C:\NextgenId\CCAgent\Logs"
$logDst = "C:\NextgenId\CCAgent193\Logs"
if (Test-Path $logSrc) {
    New-Item -ItemType Directory -Path $logDst -Force | Out-Null
    Copy-Item -Path "$logSrc\*" -Destination $logDst -Recurse -Force
} else {
    Write-Host "SKIP: No source logs to copy."
}

$sourceFile = "C:\NextgenId\CCAgent\appsettings.json"
$destinationFile = "C:\NextgenId\CCAgent193\appsettings.json"
$licenseSource = "C:\NextgenId\CCAgent\license.lic"
$licenseDestination = "C:\NextgenId\CCAgent193\license.lic"
$serviceName = "NextgenIdCCAgent"
$newPath = "C:\NextgenId\CCAgent193\StationManagementService.exe"

try {
    
    Copy-Item -Path $sourceFile -Destination $destinationFile -Force -ErrorAction Stop
    
    Write-Host "SUCCESS: File copied and overwritten."
}
catch {
    
    Write-Host "FAILED: Could not copy file." 
    Write-Host "Reason: $($_.Exception.Message)" 
}

try {
    if ([string]::IsNullOrWhiteSpace($licenseSource) -or [string]::IsNullOrWhiteSpace($licenseDestination)) {
        throw "One or both path variables are null or empty. Please check your script variables."
    }

    if (-not (Test-Path -Path $licenseDestination)) {
        # Perform copy
        Copy-Item -Path $licenseSource -Destination $licenseDestination -ErrorAction Stop
        Write-Host "SUCCESS: File copied to destination."
    } 
    else {
        Write-Host "SKIP: File already exists at destination."
    }
}
catch {
    Write-Host "FAILED: $($_.Exception.Message)"
}



try {
    $service = Get-Service -Name $serviceName -ErrorAction Stop
    
    Write-Host "Service '$serviceName' found. Updating path..."

    $result = sc.exe config $serviceName binPath= $newPath

    if ($LASTEXITCODE -eq 0) {
        Write-Host "SUCCESS: Service path changed to: $newPath"
        Write-Host "Note: You may need to restart the service for changes to take effect." -ForegroundColor Gray
    } else {
        throw "sc.exe failed with exit code $LASTEXITCODE"
    }
}
catch {
    Write-Host "FAILED: Could not change service path."
    Write-Host "Error Details: $($_.Exception.Message)" 
}


$Path = "C:\NextgenId\CCAgent193\appsettings.json"  

$fullPath = $Path
if (-not (Test-Path -LiteralPath $fullPath -PathType Leaf)) {
    throw "File not found: $fullPath"
}


try {
    Get-Service -Name 'nextgenidccagent' -ErrorAction Stop

    Start-Process powershell -WindowStyle Hidden -ArgumentList "-Command `
        Start-Sleep -Seconds 2; `
        Restart-Service -Name 'nextgenidccagent' -Force"

    Write-Host "SUCCESS: Restart signal sent to '$serviceName' in background." -ForegroundColor Green
}
catch {
    Write-Host "FAILED: Service '$serviceName' not found or access denied." -ForegroundColor Red
}

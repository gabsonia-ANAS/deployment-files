
$originalPath = "C:\NextgenId\CCAgent"
$newName = "CCAgent191_Backedup"
$fullNewPath = "C:\NextgenId\$newName"

try {
    # 1. Check if the source folder actually exists
    if (Test-Path -Path $originalPath) {
        
        # 2. Check if the destination name is already taken
        if (-not (Test-Path -Path $fullNewPath)) {
            
            # 3. Perform the rename
            Rename-Item -Path $originalPath -NewName $newName -ErrorAction Stop
            Write-Host "SUCCESS: Folder renamed to $newName" -ForegroundColor Green
        } 
        else {
            Write-Host "SKIP: A folder named '$newName' already exists." -ForegroundColor Yellow
        }
    } 
    else {
        Write-Host "FAILED: Source folder '$originalPath' not found." -ForegroundColor Red
    }
}
catch {
    Write-Host "ERROR: Could not rename folder." -ForegroundColor Red
    Write-Host "Details: $($_.Exception.Message)" -ForegroundColor Yellow
}



$serviceName = "NextgenIdCCAgent"
$newPath = "C:\NextgenId\CCAgent\StationManagementService.exe"

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


$sourceDir = "C:\NextgenId\CCAgent192\*"
$destDir = "C:\NextgenId\CCAgent"

try {
    # 1. Check if the source folder exists (without the wildcard)
    if (Test-Path -Path "C:\NextgenId\CCAgent192") {
        
        # 2. Create the destination folder if it's missing
        if (-not (Test-Path -Path $destDir)) {
            New-Item -Path $destDir -ItemType Directory -Force | Out-Null
            Write-Host "NOTE: Created destination folder $destDir" -ForegroundColor Cyan
        }

        # 3. Copy everything inside (Recurse for subfolders, Force to overwrite)
        Copy-Item -Path $sourceDir -Destination $destDir -Recurse -Force -ErrorAction Stop
        
        Write-Host "SUCCESS: All contents from CCAgent192 copied to CCAgent." -ForegroundColor Green
    } 
    else {
        Write-Host "FAILED: Source folder 'CCAgent192' not found." -ForegroundColor Red
    }
}
catch {
    Write-Host "ERROR: Could not copy contents." -ForegroundColor Red
    Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor Yellow
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

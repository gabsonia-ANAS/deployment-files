$sourceDir = "C:\NextgenId\CCAgent192"

try {
    if (Test-Path -Path $sourceDir) {
        
        Remove-Item -Path $sourceDir -Recurse -Force -ErrorAction Stop
        
        Write-Host "SUCCESS: Folder '$sourceDir' has been deleted."
    } 
    else {
        Write-Host "SKIP: Folder '$sourceDir' does not exist."
    }
}
catch {
    Write-Host "FAILED: Could not delete folder."
    Write-Host "Error: $($_.Exception.Message)"
}

Get-ChildItem -Path "C:\NextgenId\CCAgent\*.exe" | ForEach-Object {
    [PSCustomObject]@{
        FileName    = $_.Name
        FileVersion = $_.VersionInfo.FileVersion
    }
} | Format-Table -AutoSize
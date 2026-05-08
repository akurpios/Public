$TargetDir = "C:\support\NetPritnerDeployer"
$FileName = "NetPrinterDeployer.ps1"
$TargetPath = Join-Path $TargetDir $FileName

# Remove the file
if (Test-Path $TargetPath) {
    Remove-Item -Path $TargetPath -Force
}

# Optional: Remove folder if empty
if (Test-Path $TargetDir) {
    if ((Get-ChildItem $TargetDir).Count -eq 0) {
        Remove-Item -Path $TargetDir -Force
    }
}

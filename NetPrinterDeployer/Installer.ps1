$TargetDir  = "C:\support\NetPritnerDeployer"
$ScriptName = "NetPrinterDeployer.ps1"
$TargetPath = Join-Path $TargetDir $ScriptName

# 1. Create directory
if (-not (Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir -Force }

# 2. Copy the script
$CurrentDir = Split-Path $MyInvocation.MyCommand.Path -Parent
Copy-Item -Path "$CurrentDir\$ScriptName" -Destination $TargetPath -Force

# 3. Create Start Menu Shortcut
$WshShell = New-Object -ComObject WScript.Shell
$ShortcutPath = "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\NetPrinterDeployer.lnk"
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -WindowStyle Hidden -File ""$TargetPath"""
$Shortcut.WindowStyle = 7 # Minimized/Hidden start
$Shortcut.Description = "Network Printer Installer"
$Shortcut.Save()

# 4. Launch it immediately for the first time
#Powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File "$TargetPath"
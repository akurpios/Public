# === PART 0: Define varibles ===

# Define account details
$Username = "sa-ServiceRestarterAccount"
$Password = "5up3rH@rdP@55w0rd"  # Change this to your desired password
$Description = "Service account for service restart"
# Task details
$TaskName = "RestartServiceDaily"
$TaskDescription = "Restarts service daily at 8:00 AM"
$ServiceName = "Zabbix Agent"
$TaskFilePath = "C:\Windows\System32\Tasks\$TaskName"
# Launcher details
$PublicDesktop = "$env:PUBLIC\Desktop"
$PublicFolder = "$env:PUBLIC"
$LauncherName  = "Restart-$ServiceName-Task.ps1"
$LauncherLink = "RestartService.lnk"
$LauncherPath  = Join-Path -Path $PublicFolder -ChildPath $LauncherName
$LauncherLinkPath = Join-Path -Path $PublicDesktop -ChildPath $LauncherLink


# === PART 1: Create Local Administrator Account ===
try {
    # Create secure password
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
    
    # Create new local user account
    New-LocalUser -Name $Username -Password $SecurePassword -Description $Description -PasswordNeverExpires -UserMayNotChangePassword -AccountNeverExpires
    Write-Host "User account '$Username' created successfully" -ForegroundColor Green
    
    # Get Administrators group by SID (S-1-5-32-544 is the well-known SID for local Administrators group)
    $AdminGroupSID = "S-1-5-32-544"
    $AdminGroup = Get-LocalGroup | Where-Object { $_.SID -eq $AdminGroupSID }
    
    # Add user to Administrators group using SID
    Add-LocalGroupMember -SID $AdminGroupSID -Member $Username
    Write-Host "User '$Username' added to Administrators group (SID: $AdminGroupSID)" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to create user account: $_"
    exit 1
}

Start-Sleep -Seconds 3


# === PART 2: Create Scheduled Task ===

try {
    # Create task action - restart service
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command `"Restart-Service -Name '$ServiceName' -Force`""

    # Create task trigger - daily at 8:00 AM
    $Trigger = New-ScheduledTaskTrigger -Daily -At "08:00"
    
    # Create task principal settings
    $Principal = New-ScheduledTaskPrincipal -UserId $Username -LogonType Password -RunLevel Highest
    
    # Create task settings
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -DontStopOnIdleEnd
    
    # Register the scheduled task
    Register-ScheduledTask -TaskName $TaskName -Action $Action -Trigger $Trigger -User $Username -Password $Password -Settings $Settings -Description $TaskDescription -Force
    
    # Set task to allow execution by all users
    $TaskPath = "\$TaskName"
    schtasks.exe /change /tn $TaskPath /ru $Username /rp $Password
    
    # Grant "Log on as a batch job" right to the user (required for scheduled tasks)
    $UserSID = (New-Object System.Security.Principal.NTAccount($Username)).Translate([System.Security.Principal.SecurityIdentifier]).Value
    
    # Export current security policy
    secedit /export /cfg "$env:TEMP\secpol.cfg" | Out-Null
    
    # Read current policy
    $SecurityPolicy = Get-Content "$env:TEMP\secpol.cfg"
    
    # Find and update SeBatchLogonRight
    $UpdatedPolicy = $SecurityPolicy | ForEach-Object {
        if ($_ -match "SeBatchLogonRight") {
            if ($_ -notmatch $UserSID) {
                $_ + ",*$UserSID"
            } else {
                $_
            }
        } else {
            $_
        }
    }
    
    # If SeBatchLogonRight doesn't exist, add it
    if ($SecurityPolicy -notmatch "SeBatchLogonRight") {
        $UpdatedPolicy += "SeBatchLogonRight = *$UserSID"
    }
    
    # Write updated policy
    $UpdatedPolicy | Set-Content "$env:TEMP\secpol_updated.cfg"
    
    # Import updated policy
    secedit /configure /db "$env:TEMP\secedit.sdb" /cfg "$env:TEMP\secpol_updated.cfg" /areas USER_RIGHTS | Out-Null
    
    # Clean up temporary files
    Remove-Item "$env:TEMP\secpol.cfg" -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\secpol_updated.cfg" -ErrorAction SilentlyContinue
    Remove-Item "$env:TEMP\secedit.sdb" -ErrorAction SilentlyContinue
    
    Write-Host "Scheduled task '$TaskName' created successfully" -ForegroundColor Green
    Write-Host "Task configured to run daily at 8:00 AM with highest privileges" -ForegroundColor Green
    Write-Host "Task will run whether user is logged on or not" -ForegroundColor Green
    Write-Host "User rights configured for batch job execution" -ForegroundColor Green
    
} catch {
    Write-Error "Failed to create scheduled task: $_"
    exit 1
}

# === PART 3: Allow Authenticated users run this task ===

$TaskPath = "\" #Scheduled Tasks at the base level use this path. If you have folders in your Task Scheduler, just add in the folder path here after the backslash.
$Scheduler = New-Object -ComObject "Schedule.Service"
$Scheduler.Connect()
$GetTask = $Scheduler.GetFolder($TaskPath).GetTask($TaskName)
$GetSecurityDescriptor = $GetTask.GetSecurityDescriptor(0xF)
if ($GetSecurityDescriptor -notmatch 'A;;0x1200a9;;;AU') {
    $GetSecurityDescriptor = $GetSecurityDescriptor + '(A;;GRGX;;;AU)'
    $GetTask.SetSecurityDescriptor($GetSecurityDescriptor, 0)
}

# === PART 4: Create Powershell Script for everyone to run this task manually ===
$LauncherContent = @"
Try {
    Write-Host 'Starting scheduled task: $TaskName' -ForegroundColor Cyan
    schtasks.exe /run /tn "$TaskName"
    Write-Host 'Task executed successfully.' -ForegroundColor Green
}
Catch {
    Write-Error "Failed to execute scheduled task. Please contact IT support"
}

pause
"@


# Write the .ps1 file to Public Desktop
$LauncherContent | Out-File -FilePath $LauncherPath -Encoding UTF8 -Force

# Create link to run Powershell
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($LauncherLinkPath)
$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$LauncherPath`""
$Shortcut.IconLocation = "powershell.exe,0"
$Shortcut.Save()


# === PART 5: Verification ===
Write-Host "`n=== VERIFICATION ===" -ForegroundColor Yellow

# Verify user account
$UserAccount = Get-LocalUser -Name $Username -ErrorAction SilentlyContinue
if ($UserAccount) {
    Write-Host "User account '$Username' exists" -ForegroundColor Green
    Write-Host "Password expires: $($UserAccount.PasswordExpires)" -ForegroundColor Cyan
    Write-Host "User may change password: $($UserAccount.UserMayChangePassword)" -ForegroundColor Cyan
    Write-Host "Account expires: $($UserAccount.AccountExpires)" -ForegroundColor Cyan
}

# Verify group membership
$GroupMembership = Get-LocalGroupMember -SID $AdminGroupSID | Where-Object { $_.Name -like "*$Username" }
if ($GroupMembership) {
    Write-Host "User '$Username' is member of Administrators group" -ForegroundColor Green
}

# Verify scheduled task
$Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
if ($Task) {
    Write-Host "Scheduled task '$TaskName' exists" -ForegroundColor Green
    Write-Host "State: $($Task.State)" -ForegroundColor Cyan
    Write-Host "Next run time: $(Get-ScheduledTaskInfo -TaskName $TaskName | Select-Object -ExpandProperty NextRunTime)" -ForegroundColor Cyan
}

Write-Host "`n=== SCRIPT COMPLETED SUCCESSFULLY ===" -ForegroundColor Green

cls
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
#credits#
$credits=@"
#
#
#
#SCRIPT CREATED BY ALEKSANDER KUPRIOS
#ALL RIGHTS RESERVED
#NO RIGHTS FOR PROPAGATION WITHOUT CONSULTATION WITH AUTHOR
#CONTACT: kontakt@kurpios.it
#
#
#
########################################################################

"@
Write-Host $credits
if (Get-Module -ListAvailable -Name MSOnline) {
    Write-Host "MSOnline Module Installed"
} 
else {
    Write-Host MSOnline Module not installed. Please install the MSOnline module using below command: `nInstall-Module MSOnline  -ForegroundColor yellow
    #Install-Module MSOnline
    Pause
    exit
}
<#
If problem with log-in to O365 with MFA please update MSOnline with that
Install-module MSOnline -Force -AllowClobber
#>
Connect-MsolService



do{
$menu = Read-Host "`n 1. Enable MFA `n 2. Disable MFA `n 3. Reset MFA `n 4. Check MFA status `n Pick your number"
if ($menu -eq "1")
{
do{
$emailbool = "false"
$email = Read-host "Type-in the user's email address"
if ($email -like "*@company.com")
{
$emailbool = "true"
}
else
{
Write-Host "Wrong email address! Please use @company.com address" -fore red
} 
}until ($emailbool -eq "true")
$st = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
$st.RelyingParty = "*"
$st.State = "Enabled"
$sta = @($st)
Set-MsolUser -UserPrincipalName $email -StrongAuthenticationRequirements $sta
Pause
exit
}
elseif ($menu -eq "2")
{
do{
$emailbool = "false"
$email = Read-host "Type-in the user's email address"
if ($email -like "*@company.com")
{
$emailbool = "true"
}
else
{
Write-Host "Wrong email address! Please use @company.com address" -fore red
} 
}until ($emailbool -eq "true")
Set-MsolUser -UserPrincipalName $email -StrongAuthenticationRequirements @()
Pause
exit
}
elseif ($menu -eq "3")
{
do{
$emailbool = "false"
$email = Read-host "Type-in the user's email address"
if ($email -like "*@company.com")
{
$emailbool = "true"
}
else
{
Write-Host "Wrong email address! Please use @company.com address" -fore red
} 
}until ($emailbool -eq "true")
Reset-MsolStrongAuthenticationMethodByUpn -UserPrincipalName @email
Pause
exit
} 
elseif ($menu -eq "4")
{
do{
$emailbool = "false"
$email = Read-host "Type-in the user's email address"
if ($email -like "*@company.com")
{
$emailbool = "true"
}
else
{
Write-Host "Wrong email address! Please use @company.com address" -fore red
} 
}until ($emailbool -eq "true")

Get-msoluser -UserPrincipalName $email | select DisplayName,@{N='Email';E={$_.UserPrincipalName}},@{n="MFA_Methods";e={($_.StrongAuthenticationMethods).MethodType}},@{N='MFA_Requirements';E={($_.StrongAuthenticationRequirements).state}} | Sort-Object DisplayName | Out-Gridview
pause
}
else
{
Write-Host "wrong choose. Pick correct one" -fore red
}
}
until (($menu -eq "1") -and ($menu -eq "2") -and ($menu -eq "3") -and ($menu -eq "4"))

$username="BreakGlass"
$password=ConvertTo-SecureString "Br3@kGl@55P@55w0rd" -AsPlainText -Force 
$name="Break Glass Admin Account"
$desc="Local Admin account deployed via Powershell"
$group="Administrators"


New-LocalUser $username -Password $password -FullName $name -Description $desc

Add-LocalGroupMember -Group $group -Member $username

Set-LocalUser -Name $username -PasswordNeverExpires 1

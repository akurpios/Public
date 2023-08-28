cls
#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
Add-Type -assembly System.Windows.Forms
#credits#
$credits=@"
#
#
#
#SCRIPT CREATED BY ALEKSANDER KUPRIOS
#ALL RIGHTS RESERVED
#CONTACT: kontakt@kurpios.it
#
#
#
########################################################################

"@
#Write-Host $credits

$main_form = New-Object System.Windows.Forms.Form
$main_form.Text ='Force sync 2 AzureAD'
#$main_form.Width = 300
$main_form.Height = 180
$main_form.AutoScale = $true
$main_form.AutoSize = $true

$StatusModuleOK = New-Object System.Windows.Forms.label
#$StatusModuleOK.Location = New-Object System.Drawing.Size(0,10)
$StatusModuleOK.Size = New-Object System.Drawing.Size(130,15)
$StatusModuleOK.ForeColor = "green"
$StatusModuleOK.Text = "Module loaded"

$StatusModuleNotOK = New-Object System.Windows.Forms.label
#$StatusModuleNotOK.Location = New-Object System.Drawing.Size(0,10)
$StatusModuleNotOK.Size = New-Object System.Drawing.Size(130,15)
$StatusModuleNotOK.ForeColor = "red"
$StatusModuleNotOK.Text = "Module NOT loaded"

if (Get-Module -ListAvailable -Name ADSync) {
    $main_form.Controls.Add($StatusModuleOK)
} 
else {
    $main_form.Controls.Add($StatusModuleNotOK)
}

$StatusOK = New-Object System.Windows.Forms.label
$StatusOK.Location = New-Object System.Drawing.Size(0,136)
$StatusOK.Size = New-Object System.Drawing.Size(130,15)
$StatusOK.ForeColor = "green"
$StatusOK.Text = "Command sent"

$StatusNotOK = New-Object System.Windows.Forms.label
$StatusNotOK.Location = New-Object System.Drawing.Size(0,136)
$StatusNotOK.Size = New-Object System.Drawing.Size(130,15)
$StatusNotOK.ForeColor = "red"
$StatusNotOK.Text = "Command NOT sent"


$btn_full = new-object windows.forms.button
$btn_full.text = "Full Sync"
$btn_full.Location = New-Object System.Drawing.Size(0,15)
$btn_full.size = New-Object System.Drawing.Size(300,60)
$btn_full.add_click({
Try {
 Start-ADSyncSyncCycle -PolicyType Initial
 $main_form.Controls.Add($StatusOK)
} Catch {
  $main_form.Controls.Add($StatusNotOK)
}
})
$main_form.Controls.Add($btn_full)


$btn_delta = new-object windows.forms.button
$btn_delta.text = "Sync changes"
$btn_delta.Location = New-Object System.Drawing.Size(0,76)
$btn_delta.size = New-Object System.Drawing.Size(300,60)
$btn_delta.add_click({
Try {
 Start-ADSyncSyncCycle -PolicyType Delta
 $main_form.Controls.Add($StatusOK)
} Catch {
  $main_form.Controls.Add($StatusNotOK)
}
})
$main_form.Controls.Add($btn_delta)

$main_form.AutoSize = $true
$main_form.ShowDialog()

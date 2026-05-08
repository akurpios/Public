# --- Hide console ---
$code = @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$winApi = Add-Type -MemberDefinition $code -Name "Win32ShowWindow" -Namespace Win32Functions -PassThru
$hwnd = (Get-Process -Id $PID).MainWindowHandle
if ($hwnd -ne 0) { $winApi::ShowWindow($hwnd, 0) }

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Window configuration ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Personio to AD Sync & Compare Tool"; $Form.Size = "1100,950"; $Form.StartPosition = "CenterScreen"
$FontLabel = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

# Inputs
$lblClientId = New-Object System.Windows.Forms.Label; $lblClientId.Text = "Personio Client ID:"; $lblClientId.Location = "20,20"; $lblClientId.Size = "300,20"; $lblClientId.Font = $FontLabel; $Form.Controls.Add($lblClientId)
$txtClientId = New-Object System.Windows.Forms.TextBox; $txtClientId.Location = "20,45"; $txtClientId.Size = "300,25"; $Form.Controls.Add($txtClientId)
$lblSecret = New-Object System.Windows.Forms.Label; $lblSecret.Text = "Personio Client Secret:"; $lblSecret.Location = "340,20"; $lblSecret.Size = "300,20"; $lblSecret.Font = $FontLabel; $Form.Controls.Add($lblSecret)
$txtSecret = New-Object System.Windows.Forms.TextBox; $txtSecret.Location = "340,45"; $txtSecret.Size = "300,25"; $txtSecret.PasswordChar = '*'; $Form.Controls.Add($txtSecret)
$lblFolder = New-Object System.Windows.Forms.Label; $lblFolder.Text = "Export Folder:"; $lblFolder.Location = "20,80"; $lblFolder.Size = "300,20"; $lblFolder.Font = $FontLabel; $Form.Controls.Add($lblFolder)
$txtFolder = New-Object System.Windows.Forms.TextBox; $txtFolder.Location = "20,105"; $txtFolder.Size = "530,25"; $Form.Controls.Add($txtFolder)
$btnBrowse = New-Object System.Windows.Forms.Button; $btnBrowse.Text = "Browse..."; $btnBrowse.Location = "560,104"; $btnBrowse.Size = "80,26"
$btnBrowse.Add_Click({ $fb = New-Object System.Windows.Forms.FolderBrowserDialog; if($fb.ShowDialog() -eq "OK") { $txtFolder.Text = $fb.SelectedPath } })
$Form.Controls.Add($btnBrowse)

# Main buttons
$btnRun = New-Object System.Windows.Forms.Button; $btnRun.Text = "1. Compare Systems"; $btnRun.Location = "20,150"; $btnRun.Size = "520,40"; $btnRun.BackColor = "#0078D7"; $btnRun.ForeColor = "White"; $btnRun.Font = $FontLabel; $Form.Controls.Add($btnRun)
$btnSync = New-Object System.Windows.Forms.Button; $btnSync.Text = "2. Sync Selected to AD"; $btnSync.Location = "560,150"; $btnSync.Size = "500,40"; $btnSync.BackColor = "#28A745"; $btnSync.ForeColor = "White"; $btnSync.Font = $FontLabel; $btnSync.Enabled = $false; $Form.Controls.Add($btnSync)

# Filtering and Table setup (Remaining UI code same as before)
$lblSearch = New-Object System.Windows.Forms.Label; $lblSearch.Text = "Filter:"; $lblSearch.Location = "20,205"; $lblSearch.Size = "50,20"; $lblSearch.Font = $FontLabel; $lblSearch.Visible = $false; $Form.Controls.Add($lblSearch)
$txtSearch = New-Object System.Windows.Forms.TextBox; $txtSearch.Location = "80,202"; $txtSearch.Size = "980,25"; $txtSearch.Visible = $false; $Form.Controls.Add($txtSearch)
$pnlSelect = New-Object System.Windows.Forms.Panel; $pnlSelect.Location = "20,235"; $pnlSelect.Size = "1040,75"; $pnlSelect.Visible = $false; $Form.Controls.Add($pnlSelect)
$btnSelAll = New-Object System.Windows.Forms.Button; $btnSelAll.Text = "Select All"; $btnSelAll.Size = "125,28"; $btnSelAll.Location = "0,0"; $pnlSelect.Controls.Add($btnSelAll)
$btnUnselAll = New-Object System.Windows.Forms.Button; $btnUnselAll.Text = "Unselect All"; $btnUnselAll.Size = "125,28"; $btnUnselAll.Location = "130,0"; $pnlSelect.Controls.Add($btnUnselAll)
$btnSelFilt = New-Object System.Windows.Forms.Button; $btnSelFilt.Text = "Select Filtered"; $btnSelFilt.Size = "125,28"; $btnSelFilt.Location = "260,0"; $pnlSelect.Controls.Add($btnSelFilt)
$btnUnselFilt = New-Object System.Windows.Forms.Button; $btnUnselFilt.Text = "Unselect Filtered"; $btnUnselFilt.Size = "125,28"; $btnUnselFilt.Location = "390,0"; $pnlSelect.Controls.Add($btnUnselFilt)
$btnSelPEmpty = New-Object System.Windows.Forms.Button; $btnSelPEmpty.Text = "Select Personio Empty"; $btnSelPEmpty.Size = "140,28"; $btnSelPEmpty.Location = "0,35"; $pnlSelect.Controls.Add($btnSelPEmpty)
$btnUnselPEmpty = New-Object System.Windows.Forms.Button; $btnUnselPEmpty.Text = "Unsel Personio Empty"; $btnUnselPEmpty.Size = "140,28"; $btnUnselPEmpty.Location = "145,35"; $pnlSelect.Controls.Add($btnUnselPEmpty)
$btnSelADEmpty = New-Object System.Windows.Forms.Button; $btnSelADEmpty.Text = "Select AD Empty"; $btnSelADEmpty.Size = "140,28"; $btnSelADEmpty.Location = "290,35"; $pnlSelect.Controls.Add($btnSelADEmpty)
$btnUnselADEmpty = New-Object System.Windows.Forms.Button; $btnUnselADEmpty.Text = "Unsel AD Empty"; $btnUnselADEmpty.Size = "140,28"; $btnUnselADEmpty.Location = "435,35"; $pnlSelect.Controls.Add($btnUnselADEmpty)
$dgv = New-Object System.Windows.Forms.DataGridView; $dgv.Location = "20,315"; $dgv.Size = "1040,410"; $dgv.AllowUserToAddRows = $false; $dgv.RowHeadersVisible = $false; $dgv.SelectionMode = "FullRowSelect"; $Form.Controls.Add($dgv)
$pb = New-Object System.Windows.Forms.ProgressBar; $pb.Location = "20,740"; $pb.Size = "1040,20"; $Form.Controls.Add($pb)
$lblStatus = New-Object System.Windows.Forms.Label; $lblStatus.Text = "Ready."; $lblStatus.Location = "20,770"; $lblStatus.Size = "1000,40"; $lblStatus.ForeColor = "Gray"; $Form.Controls.Add($lblStatus)

$script:dt = New-Object System.Data.DataTable

$dgv.Add_CellContentClick({ param($sender, $e) if ($e.ColumnIndex -eq 0) { $dgv.EndEdit() } })
$btnSelAll.Add_Click({ foreach($r in $script:dt.Rows) { $r["Sync"] = $true } })
$btnUnselAll.Add_Click({ foreach($r in $script:dt.Rows) { $r["Sync"] = $false } })
$btnSelFilt.Add_Click({ foreach($rv in $script:dt.DefaultView) { $rv.Row["Sync"] = $true } })
$btnUnselFilt.Add_Click({ foreach($rv in $script:dt.DefaultView) { $rv.Row["Sync"] = $false } })
$btnSelPEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["PersonioValue"])) { $r["Sync"] = $true } } })
$btnUnselPEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["PersonioValue"])) { $r["Sync"] = $false } } })
$btnSelADEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["ADValue"])) { $r["Sync"] = $true } } })
$btnUnselADEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["ADValue"])) { $r["Sync"] = $false } } })

$txtSearch.Add_TextChanged({
    if ($script:dt.Columns.Count -gt 0) {
        $t = $txtSearch.Text.Replace("'", "''")
        $script:dt.DefaultView.RowFilter = "Email LIKE '*$t*' OR AD_DisplayName LIKE '*$t*' OR Attribute LIKE '*$t*' OR PersonioValue LIKE '*$t*'"
    }
})

# --- Analyze Logic (v1.1.1 improvements kept) ---
$btnRun.Add_Click({
    if ([string]::IsNullOrWhiteSpace($txtClientId.Text) -or [string]::IsNullOrWhiteSpace($txtFolder.Text)) { return }
    $btnRun.Enabled = $false; $pb.Value = 0; $lblStatus.Text = "Connecting to Personio..."; $Form.Refresh()
    
    $script:dt = New-Object System.Data.DataTable
    $null = $script:dt.Columns.Add("Sync", [bool]); $null = $script:dt.Columns.Add("Email", [string])
    $null = $script:dt.Columns.Add("AD_DisplayName", [string]); $null = $script:dt.Columns.Add("AD_Active", [string])
    $null = $script:dt.Columns.Add("Attribute", [string]); $null = $script:dt.Columns.Add("PersonioValue", [string]); $null = $script:dt.Columns.Add("ADValue", [string])

    try {
        $authBody = @{ client_id = $txtClientId.Text; client_secret = $txtSecret.Text } | ConvertTo-Json
        $auth = Invoke-RestMethod -Method Post -Uri "https://api.personio.de/v1/auth" -Body $authBody -ContentType "application/json" -UseBasicParsing
        $headers = @{ "Authorization" = "Bearer $($auth.data.token)"; "Accept" = "application/json" }

        $pList = @(); $offset = 0; $hasMore = $true; $totalCount = 0
        while ($hasMore) {
            $jsonResponse = (Invoke-WebRequest -Uri "https://api.personio.de/v1/company/employees?limit=200&offset=$offset" -Headers $headers -UseBasicParsing).Content | ConvertFrom-Json
            if ($offset -eq 0) { $totalCount = if($jsonResponse.metadata.total_elements) { $jsonResponse.metadata.total_elements } else { 0 }; $pb.Maximum = $totalCount * 2 }
            if ($null -eq $jsonResponse.data -or $jsonResponse.data.Count -eq 0) { $hasMore = $false } else {
                foreach ($e in $jsonResponse.data) { 
                    $a = $e.attributes
                    $pList += [PSCustomObject]@{ 
                        Email = [string]$a.email.value; GivenName = [string]$a.first_name.value; Surname = [string]$a.last_name.value; 
                        Title = [string]$a.position.value; Office = [string]$a.office.value.attributes.name; Dept = [string]$a.department.value.attributes.name; 
                        Mgr = [string]$a.supervisor.value.attributes.email.value; Co = [string]$a.subcompany.value.attributes.name;
                        Status = [string]$a.status.value 
                    }
                }
                $offset += 200
                $pb.Value = [Math]::Min($pList.Count, $totalCount)
                $lblStatus.Text = "Fetching Personio users $($pList.Count) of $totalCount"; $Form.Refresh()
            }
        }

        if (!(Get-Module -Name ActiveDirectory)) { Import-Module ActiveDirectory }
        $adList = @(); $counter = 0
        foreach ($p in $pList) {
            $counter++; $pb.Value = $totalCount + $counter
            $lblStatus.Text = "Comparing $($p.Email) ($counter of $totalCount)"; $Form.Refresh()
            if ([string]::IsNullOrWhiteSpace($p.Email)) { continue }
            $ad = Get-ADUser -Filter "UserPrincipalName -eq '$($p.Email)'" -Properties GivenName, Surname, Title, Department, Manager, Company, DisplayName, Enabled, physicalDeliveryOfficeName -ErrorAction SilentlyContinue
            if ($ad) {
                $adMgrMail = ""; if ($ad.Manager) { $mObj = Get-ADUser $ad.Manager -Properties EmailAddress -ErrorAction SilentlyContinue; if($mObj){$adMgrMail = [string]$mObj.EmailAddress} }
                $adObj = [PSCustomObject]@{ ADStatus="Found"; Email=[string]$p.Email; GivenName=[string]$ad.GivenName; Surname=[string]$ad.Surname; DisplayName=[string]$ad.DisplayName; Enabled=$ad.Enabled; Title=[string]$ad.Title; Office=[string]$ad.physicalDeliveryOfficeName; Company=[string]$ad.Company; Department=[string]$ad.Department; ManagerEmail=[string]$adMgrMail }
                $adList += $adObj
                $fields = @{ "GivenName"=$p.GivenName; "Surname"=$p.Surname; "Title"=$p.Title; "Office"=$p.Office; "Department"=$p.Dept; "ManagerEmail"=$p.Mgr; "Company"=$p.Co }
                foreach ($f in $fields.Keys) {
                    $pVal = ([string]$fields[$f]).Trim(); $aVal = ([string]$adObj.$f).Trim()
                    if ($pVal -ne $aVal) {
                        $row = $script:dt.NewRow(); $row["Sync"]=$false; $row["Email"]=$p.Email; $row["AD_DisplayName"]=$adObj.DisplayName; 
                        if($adObj.Enabled){$row["AD_Active"]="Yes"}else{$row["AD_Active"]="No"}
                        $row["Attribute"]=$f; $row["PersonioValue"]=$pVal; $row["ADValue"]=$aVal; $script:dt.Rows.Add($row)
                    }
                }
            } else { $adList += [PSCustomObject]@{ ADStatus="Not Found"; Email=$p.Email; GivenName=""; Surname=""; DisplayName=""; Enabled=""; Title=""; Office=""; Company=""; Department=""; ManagerEmail="" } }
        }
        $nowdate = Get-Date -Format "dd-MM-yyyyTHH-mm"
        $excelPath = Join-Path $txtFolder.Text "EmployeeComparison_$nowdate.xlsx"
        if (!(Get-Module -ListAvailable -Name ImportExcel)) { Install-Module -Name ImportExcel -Scope CurrentUser -Force }
        $pList | Export-Excel -Path $excelPath -WorksheetName "Personio" -AutoSize -BoldTopRow
        $adList | Export-Excel -Path $excelPath -WorksheetName "AD" -AutoSize -BoldTopRow
        if ($script:dt.Rows.Count -gt 0) { $script:dt | Export-Excel -Path $excelPath -WorksheetName "Mismatches" -AutoSize -BoldTopRow }
        $dgv.DataSource = $script:dt.DefaultView; $pnlSelect.Visible = $true; $lblSearch.Visible = $true; $txtSearch.Visible = $true
        $lblStatus.Text = "Analysis done. Reports saved."; $lblStatus.ForeColor = "DarkGreen"; $btnSync.Enabled = $true
    } catch { $lblStatus.Text = "Error: $($_.Exception.Message)"; $lblStatus.ForeColor = "Red" } finally { $btnRun.Enabled = $true }
})

# --- UPDATED: Sync logic with Confirmation Window ---
$btnSync.Add_Click({
    $rows = $script:dt.Select("Sync = True")
    if ($rows.Count -eq 0) { return }

    # Generate list of users for confirmation
    $uniqueUsers = $rows.Email | Select-Object -Unique
    $userListString = [string]::Join("`n", $uniqueUsers)
    $msg = "You are about to update AD for $($uniqueUsers.Count) users.`n`nTarget Users:`n$userListString`n`nDo you want to proceed?"
    
    $confirm = [System.Windows.Forms.MessageBox]::Show($msg, "Confirm AD Synchronization", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    
    if ($confirm -eq [System.Windows.Forms.DialogResult]::No) {
        $lblStatus.Text = "Sync cancelled by user."; return
    }
    
    $logPath = Join-Path $txtFolder.Text "SyncLog.txt"
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $pb.Value = 0; $pb.Maximum = $rows.Count; $s = 0

    foreach ($r in $rows) {
        try {
            $s++; $pb.Value = $s
            $email = $r["Email"]; $attr = $r["Attribute"]; $val = $r["PersonioValue"]; $oldVal = $r["ADValue"]
            $adMap = @{ "Title"="Title"; "Department"="Department"; "Company"="Company"; "GivenName"="GivenName"; "Surname"="Surname"; "Office"="physicalDeliveryOfficeName" }
            
            $u = Get-ADUser -Filter "UserPrincipalName -eq '$email'"
            if ($attr -eq "ManagerEmail") {
                if ([string]::IsNullOrWhiteSpace($val)) { Set-ADUser -Identity $u.SamAccountName -Manager $null }
                else { $mgr = Get-ADUser -Filter "EmailAddress -eq '$val'"; Set-ADUser -Identity $u.SamAccountName -Manager $mgr.DistinguishedName }
            } elseif ($adMap.ContainsKey($attr)) {
                Set-ADUser -Identity $u.SamAccountName -Replace @{ $($adMap[$attr]) = $val }
            }
            
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $logPath -Value "[$timestamp] Admin: $currentUser | Target: $email | Attr: $attr | Old: '$oldVal' | New: '$val'"
            $r["Sync"] = $false
        } catch {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $logPath -Value "[$timestamp] ERROR for $email ($attr): $($_.Exception.Message)"
        }
    }
    $lblStatus.Text = "Sync finished. Check SyncLog.txt."; $Form.Refresh()
})

[void]$Form.ShowDialog()

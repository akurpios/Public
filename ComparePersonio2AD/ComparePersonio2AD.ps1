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
$btnRun = New-Object System.Windows.Forms.Button; $btnRun.Text = "1. Compare Systems"; $btnRun.Location = "20,150"; $btnRun.Size = "250,40"; $btnRun.BackColor = "#0078D7"; $btnRun.ForeColor = "White"; $btnRun.Font = $FontLabel; $Form.Controls.Add($btnRun)
$btnExport = New-Object System.Windows.Forms.Button; $btnExport.Text = "Export Selected"; $btnExport.Location = "280,150"; $btnExport.Size = "250,40"; $btnExport.BackColor = "#6C757D"; $btnExport.ForeColor = "White"; $btnExport.Font = $FontLabel; $btnExport.Enabled = $false; $Form.Controls.Add($btnExport)
$btnImport = New-Object System.Windows.Forms.Button; $btnImport.Text = "Import Preconfigured"; $btnImport.Location = "540,150"; $btnImport.Size = "250,40"; $btnImport.BackColor = "#17A2B8"; $btnImport.ForeColor = "White"; $btnImport.Font = $FontLabel; $Form.Controls.Add($btnImport)
$btnSync = New-Object System.Windows.Forms.Button; $btnSync.Text = "Sync Selected to AD"; $btnSync.Location = "800,150"; $btnSync.Size = "260,40"; $btnSync.BackColor = "#28A745"; $btnSync.ForeColor = "White"; $btnSync.Font = $FontLabel; $btnSync.Enabled = $false; $Form.Controls.Add($btnSync)

# Filtering
$lblSearch = New-Object System.Windows.Forms.Label; $lblSearch.Text = "Filter:"; $lblSearch.Location = "20,205"; $lblSearch.Size = "50,20"; $lblSearch.Font = $FontLabel; $lblSearch.Visible = $false; $Form.Controls.Add($lblSearch)
$txtSearch = New-Object System.Windows.Forms.TextBox; $txtSearch.Location = "80,202"; $txtSearch.Size = "980,25"; $txtSearch.Visible = $false; $Form.Controls.Add($txtSearch)

# Selection buttons
$pnlSelect = New-Object System.Windows.Forms.Panel; $pnlSelect.Location = "20,235"; $pnlSelect.Size = "1040,75"; $pnlSelect.Visible = $false; $Form.Controls.Add($pnlSelect)
$btnSelAll = New-Object System.Windows.Forms.Button; $btnSelAll.Text = "Select All"; $btnSelAll.Size = "125,28"; $btnSelAll.Location = "0,0"; $pnlSelect.Controls.Add($btnSelAll)
$btnUnselAll = New-Object System.Windows.Forms.Button; $btnUnselAll.Text = "Unselect All"; $btnUnselAll.Size = "125,28"; $btnUnselAll.Location = "130,0"; $pnlSelect.Controls.Add($btnUnselAll)
$btnSelFilt = New-Object System.Windows.Forms.Button; $btnSelFilt.Text = "Select Filtered"; $btnSelFilt.Size = "125,28"; $btnSelFilt.Location = "260,0"; $pnlSelect.Controls.Add($btnSelFilt)
$btnUnselFilt = New-Object System.Windows.Forms.Button; $btnUnselFilt.Text = "Unselect Filtered"; $btnUnselFilt.Size = "125,28"; $btnUnselFilt.Location = "390,0"; $pnlSelect.Controls.Add($btnUnselFilt)

$btnSelPEmpty = New-Object System.Windows.Forms.Button; $btnSelPEmpty.Text = "Select Personio Empty"; $btnSelPEmpty.Size = "140,28"; $btnSelPEmpty.Location = "0,35"; $pnlSelect.Controls.Add($btnSelPEmpty)
$btnUnselPEmpty = New-Object System.Windows.Forms.Button; $btnUnselPEmpty.Text = "Unsel Personio Empty"; $btnUnselPEmpty.Size = "140,28"; $btnUnselPEmpty.Location = "145,35"; $pnlSelect.Controls.Add($btnUnselPEmpty)
$btnSelADEmpty = New-Object System.Windows.Forms.Button; $btnSelADEmpty.Text = "Select AD Empty"; $btnSelADEmpty.Size = "140,28"; $btnSelADEmpty.Location = "290,35"; $pnlSelect.Controls.Add($btnSelADEmpty)
$btnUnselADEmpty = New-Object System.Windows.Forms.Button; $btnUnselADEmpty.Text = "Unsel AD Empty"; $btnUnselADEmpty.Size = "140,28"; $btnUnselADEmpty.Location = "435,35"; $pnlSelect.Controls.Add($btnUnselADEmpty)

# Table
$dgv = New-Object System.Windows.Forms.DataGridView; $dgv.Location = "20,315"; $dgv.Size = "1040,410"; $dgv.AllowUserToAddRows = $false; $dgv.RowHeadersVisible = $false; $dgv.SelectionMode = "FullRowSelect"; $Form.Controls.Add($dgv)

# Progress and status
$pb = New-Object System.Windows.Forms.ProgressBar; $pb.Location = "20,740"; $pb.Size = "1040,20"; $Form.Controls.Add($pb)
$lblStatus = New-Object System.Windows.Forms.Label; $lblStatus.Text = "Ready."; $lblStatus.Location = "20,770"; $lblStatus.Size = "1000,40"; $lblStatus.ForeColor = "Gray"; $Form.Controls.Add($lblStatus)

$script:dt = New-Object System.Data.DataTable

# checkboxes in table
$dgv.Add_CellContentClick({
    param($sender, $e)
    if ($e.ColumnIndex -eq 0) { $dgv.EndEdit() }
})

# Prevent checking the box if user is missing in AD
$dgv.Add_CellBeginEdit({
    param($sender, $e)
    if ($e.RowIndex -ge 0 -and $e.ColumnIndex -eq 0) {
        $row = $dgv.Rows[$e.RowIndex]
        if ($row.Cells["ADValue"].Value -eq "Missing in AD") {
            $e.Cancel = $true
        }
    }
})

# Selection logic
$btnSelAll.Add_Click({ foreach($r in $script:dt.Rows) { if ($r["ADValue"] -ne "Missing in AD") { $r["Sync"] = $true } } })
$btnUnselAll.Add_Click({ foreach($r in $script:dt.Rows) { $r["Sync"] = $false } })
$btnSelFilt.Add_Click({ foreach($rv in $script:dt.DefaultView) { if ($rv.Row["ADValue"] -ne "Missing in AD") { $rv.Row["Sync"] = $true } } })
$btnUnselFilt.Add_Click({ foreach($rv in $script:dt.DefaultView) { $rv.Row["Sync"] = $false } })
$btnSelPEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["PersonioValue"]) -and $r["ADValue"] -ne "Missing in AD") { $r["Sync"] = $true } } })
$btnUnselPEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["PersonioValue"])) { $r["Sync"] = $false } } })
$btnSelADEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["ADValue"]) -and $r["ADValue"] -ne "Missing in AD") { $r["Sync"] = $true } } })
$btnUnselADEmpty.Add_Click({ foreach($r in $script:dt.Rows) { if ([string]::IsNullOrWhiteSpace($r["ADValue"])) { $r["Sync"] = $false } } })

$txtSearch.Add_TextChanged({
    if ($script:dt.Columns.Count -gt 0) {
        $t = $txtSearch.Text.Replace("'", "''")
        $script:dt.DefaultView.RowFilter = "Email LIKE '*$t*' OR AD_DisplayName LIKE '*$t*' OR Attribute LIKE '*$t*' OR PersonioValue LIKE '*$t*'"
    }
})

# --- Export Logic ---
$btnExport.Add_Click({
    $rowsToExport = $script:dt.Select("Sync = True")
    if ($rowsToExport.Count -eq 0) {
        $rowsToExport = $script:dt.Select("") 
    }
    
    $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveDialog.Filter = "CSV Files (*.csv)|*.csv"
    $saveDialog.FileName = "Personio_Offline_Sync.csv"
    if ($saveDialog.ShowDialog() -eq "OK") {
        $exportData = @()
        foreach ($r in $rowsToExport) {
            $exportData += [PSCustomObject]@{
                Sync = $r["Sync"]; Email = $r["Email"]; AD_DisplayName = $r["AD_DisplayName"]
                AD_Active = $r["AD_Active"]; Attribute = $r["Attribute"]
                PersonioValue = $r["PersonioValue"]; ADValue = $r["ADValue"]
            }
        }
        $exportData | Export-Csv -Path $saveDialog.FileName -NoTypeInformation -Encoding UTF8
        [System.Windows.Forms.MessageBox]::Show("Export completed successfully.", "Success", 0, 64)
    }
})

# --- Import Logic ---
$btnImport.Add_Click({
    $openDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openDialog.Filter = "CSV Files (*.csv)|*.csv"
    if ($openDialog.ShowDialog() -eq "OK") {
        try {
            $importedData = Import-Csv -Path $openDialog.FileName -Encoding UTF8
            
            if ($script:dt.Columns.Count -eq 0) {
                $null = $script:dt.Columns.Add("Sync", [bool]); $null = $script:dt.Columns.Add("Email", [string])
                $null = $script:dt.Columns.Add("AD_DisplayName", [string]); $null = $script:dt.Columns.Add("AD_Active", [string])
                $null = $script:dt.Columns.Add("Attribute", [string]); $null = $script:dt.Columns.Add("PersonioValue", [string]); $null = $script:dt.Columns.Add("ADValue", [string])
            }
            
            $script:dt.Clear()
            
            foreach ($row in $importedData) {
                $newRow = $script:dt.NewRow()
                $syncVal = $false
                if ($row.Sync -match "(?i)True|1") { $syncVal = $true }
                
                $newRow["Sync"] = $syncVal
                $newRow["Email"] = $row.Email
                $newRow["AD_DisplayName"] = $row.AD_DisplayName
                $newRow["AD_Active"] = $row.AD_Active
                $newRow["Attribute"] = $row.Attribute
                $newRow["PersonioValue"] = $row.PersonioValue
                $newRow["ADValue"] = $row.ADValue
                $script:dt.Rows.Add($newRow)
            }
            
            $dgv.DataSource = $script:dt.DefaultView
            $dgv.Columns["Sync"].SortMode = "Automatic"
            $pnlSelect.Visible = $true; $lblSearch.Visible = $true; $txtSearch.Visible = $true
            $btnSync.Enabled = $true
            $btnExport.Enabled = $true
            $lblStatus.Text = "Imported $($script:dt.Rows.Count) rows from CSV. Ready to Sync."
            $lblStatus.ForeColor = "DarkGreen"
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to import CSV: $($_.Exception.Message)", "Error", 0, 16)
        }
    }
})

# --- Analyze ---
$btnRun.Add_Click({
    if ([string]::IsNullOrWhiteSpace($txtClientId.Text) -or [string]::IsNullOrWhiteSpace($txtSecret.Text)) { 
        [System.Windows.Forms.MessageBox]::Show("Please provide Personio Client ID and Secret.", "Missing Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return 
    }
    
    # FOLDER VALIDATION
    if ([string]::IsNullOrWhiteSpace($txtFolder.Text) -or -not (Test-Path $txtFolder.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Export Folder is missing or does not exist. Please provide a valid folder path.", "Invalid Folder", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $btnRun.Enabled = $false; $pb.Value = 0; $lblStatus.Text = "Connecting to Personio..."; $Form.Refresh()
    
    $script:dt = New-Object System.Data.DataTable
    $null = $script:dt.Columns.Add("Sync", [bool]); $null = $script:dt.Columns.Add("Email", [string])
    $null = $script:dt.Columns.Add("AD_DisplayName", [string]); $null = $script:dt.Columns.Add("AD_Active", [string])
    $null = $script:dt.Columns.Add("Attribute", [string]); $null = $script:dt.Columns.Add("PersonioValue", [string]); $null = $script:dt.Columns.Add("ADValue", [string])

    try {
        $authBody = @{ client_id = $txtClientId.Text; client_secret = $txtSecret.Text } | ConvertTo-Json
        $auth = Invoke-RestMethod -Method Post -Uri "https://api.personio.de/v1/auth" -Body $authBody -ContentType "application/json" -UseBasicParsing
        $headers = @{ "Authorization" = "Bearer $($auth.data.token)"; "Accept" = "application/json" }

        # FETCHING DATA WITH PROGRESS
        $pList = @(); $offset = 0; $hasMore = $true; $totalCount = 0
        
        while ($hasMore) {
            $jsonResponse = (Invoke-WebRequest -Uri "https://api.personio.de/v1/company/employees?limit=200&offset=$offset" -Headers $headers -UseBasicParsing).Content | ConvertFrom-Json
            
            # Get total count from metadata on first run
            if ($offset -eq 0) { 
                $totalCount = if($jsonResponse.metadata.total_elements) { $jsonResponse.metadata.total_elements } else { 0 }
                $pb.Maximum = $totalCount * 2 # Stage 1: Fetching, Stage 2: Comparing
            }

            if ($null -eq $jsonResponse.data -or $jsonResponse.data.Count -eq 0) { $hasMore = $false } else {
                foreach ($e in $jsonResponse.data) { 
                    $a = $e.attributes
                    $pList += [PSCustomObject]@{ 
                        Email = [string]$a.email.value; GivenName = [string]$a.first_name.value; Surname = [string]$a.last_name.value; 
                        Title = [string]$a.position.value; Office = [string]$a.office.value.attributes.name; Dept = [string]$a.department.value.attributes.name; 
                        Mgr = [string]$a.supervisor.value.attributes.email.value; Co = [string]$a.subcompany.value.attributes.name; Mob = [string]$a.mobile_phone.value; Ph = [string]$a.office_number.value 
                    }
                }
                $offset += 200
                $pb.Value = [Math]::Min($pList.Count, $totalCount)
                $lblStatus.Text = "Fetching Personio users $($pList.Count) of $totalCount"
                $Form.Refresh()
            }
        }

        if (!(Get-Module -Name ActiveDirectory)) { Import-Module ActiveDirectory }
        $adList = @(); $counter = 0

        # COMPARING DATA WITH PROGRESS
        foreach ($p in $pList) {
            $counter++
            $pb.Value = $totalCount + $counter
            $lblStatus.Text = "Comparing $($p.Email) user with AD ($counter of $totalCount)"
            $Form.Refresh()

            if ([string]::IsNullOrWhiteSpace($p.Email)) { continue }
            
            # FALLBACK TO EMAILADDRESS LOGIC
            $ad = Get-ADUser -Filter "UserPrincipalName -eq '$($p.Email)'" -Properties GivenName, Surname, Title, Office, Department, Manager, Company, MobilePhone, OfficePhone, DisplayName, Enabled -ErrorAction SilentlyContinue
            
            if (-not $ad) {
                $ad = Get-ADUser -Filter "EmailAddress -eq '$($p.Email)'" -Properties GivenName, Surname, Title, Office, Department, Manager, Company, MobilePhone, OfficePhone, DisplayName, Enabled -ErrorAction SilentlyContinue
            }

            if ($ad) {
                $adMgrMail = ""; if ($ad.Manager) { $mObj = Get-ADUser $ad.Manager -Properties EmailAddress -ErrorAction SilentlyContinue; if($mObj){$adMgrMail = [string]$mObj.EmailAddress} }
                
                $adObj = [PSCustomObject]@{ 
                    ADStatus="Found"; Email=[string]$p.Email; GivenName=[string]$ad.GivenName; Surname=[string]$ad.Surname; DisplayName=[string]$ad.DisplayName; 
                    Enabled=$ad.Enabled; Title=[string]$ad.Title; Office=[string]$ad.Office; Company=[string]$ad.Company; Department=[string]$ad.Department; 
                    ManagerEmail=[string]$adMgrMail; MobilePhone=[string]$ad.MobilePhone; OfficePhone=[string]$ad.OfficePhone
                }
                $adList += $adObj

                $fields = @{ "GivenName"=$p.GivenName; "Surname"=$p.Surname; "Title"=$p.Title; "Office"=$p.Office; "Department"=$p.Dept; "ManagerEmail"=$p.Mgr; "Company"=$p.Co; "Mobile"=$p.Mob; "Phone"=$p.Ph }
                foreach ($f in $fields.Keys) {
                    $pVal = ([string]$fields[$f]).Trim(); $aVal = ([string]$adObj.$f).Trim()
                    if ($pVal -ne $aVal) {
                        $row = $script:dt.NewRow()
                        $row["Sync"]=$false; $row["Email"]=$p.Email; $row["AD_DisplayName"]=$adObj.DisplayName; 
                        if($adObj.Enabled){$row["AD_Active"]="Yes"}else{$row["AD_Active"]="No"}
                        $row["Attribute"]=$f; $row["PersonioValue"]=$pVal; $row["ADValue"]=$aVal
                        $script:dt.Rows.Add($row)
                    }
                }
            } else { 
                # MISSING IN AD LOGIC
                $adList += [PSCustomObject]@{ ADStatus="Not Found"; Email=$p.Email; GivenName=""; Surname=""; DisplayName=""; Enabled=""; Title=""; Office=""; Company=""; Department=""; ManagerEmail=""; MobilePhone=""; OfficePhone="" } 
                
                $row = $script:dt.NewRow()
                $row["Sync"]=$false
                $row["Email"]=$p.Email
                $row["AD_DisplayName"]="NOT FOUND"
                $row["AD_Active"]="N/A"
                $row["Attribute"]="Account"
                $row["PersonioValue"]="Exists in Personio"
                $row["ADValue"]="Missing in AD"
                $script:dt.Rows.Add($row)
            }
        }

        $excelPath = Join-Path $txtFolder.Text "EmployeeComparison.xlsx"
        if (!(Get-Module -ListAvailable -Name ImportExcel)) { Install-Module -Name ImportExcel -Scope CurrentUser -Force }
        $pList | Export-Excel -Path $excelPath -WorksheetName "Personio" -AutoSize -BoldTopRow
        $adList | Export-Excel -Path $excelPath -WorksheetName "AD" -AutoSize -BoldTopRow
        if ($script:dt.Rows.Count -gt 0) { $script:dt | Export-Excel -Path $excelPath -WorksheetName "Mismatches" -AutoSize -BoldTopRow }

        $dgv.DataSource = $script:dt.DefaultView
        $dgv.Columns["Sync"].SortMode = "Automatic"
        $pnlSelect.Visible = $true; $lblSearch.Visible = $true; $txtSearch.Visible = $true
        $lblStatus.Text = "Analysis done. Reports saved to Excel."; $lblStatus.ForeColor = "DarkGreen"
        $btnSync.Enabled = $true
        $btnExport.Enabled = $true

    } catch {
        $lblStatus.Text = "Error: $($_.Exception.Message)"; $lblStatus.ForeColor = "Red"
    } finally { $btnRun.Enabled = $true }
})

# --- Sync logic and log to TXT ---
$btnSync.Add_Click({
    # FOLDER VALIDATION BEFORE SYNC
    if ([string]::IsNullOrWhiteSpace($txtFolder.Text) -or -not (Test-Path $txtFolder.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Export Folder is missing or does not exist. Please provide a valid path to save the SyncLog.txt file.", "Invalid Folder", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    $rows = $script:dt.Select("Sync = True AND ADValue <> 'Missing in AD'")
    if ($rows.Count -eq 0) { 
        [System.Windows.Forms.MessageBox]::Show("No valid items selected for synchronization.", "Information", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return 
    }
    
    # CONFIRMATION DIALOG WITH USER LIST
    $uniqueUsers = @()
    foreach ($r in $rows) {
        if ($r["Email"] -notin $uniqueUsers) { $uniqueUsers += $r["Email"] }
    }

    $displayUsers = $uniqueUsers | Select-Object -First 15
    $usersList = $displayUsers -join "`n"
    if ($uniqueUsers.Count -gt 15) {
        $usersList += "`n... and $($uniqueUsers.Count - 15) more."
    }

    $confirmMsg = "You are about to modify Active Directory attributes for $($uniqueUsers.Count) user(s):`n`n$usersList`n`nDo you want to proceed?"
    $dialogResult = [System.Windows.Forms.MessageBox]::Show($confirmMsg, "Confirm Synchronization", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    
    if ($dialogResult -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    # SYNC EXECUTION
    $logPath = Join-Path $txtFolder.Text "SyncLog.txt"
    $currentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    
    $pb.Value = 0; $pb.Maximum = $rows.Count; $s = 0
    foreach ($r in $rows) {
        try {
            $s++; $pb.Value = $s
            $email = $r["Email"]; $attr = $r["Attribute"]; $val = $r["PersonioValue"]; $oldVal = $r["ADValue"]
            $adMap = @{ "Title"="Title"; "Department"="Department"; "Company"="Company"; "GivenName"="GivenName"; "Surname"="Surname"; "Office"="Office"; "Mobile"="MobilePhone"; "Phone"="OfficePhone" }
            
            $u = Get-ADUser -Filter "UserPrincipalName -eq '$email'"
            if (-not $u) { $u = Get-ADUser -Filter "EmailAddress -eq '$email'" } # Safety fallback during sync
            
            if ($attr -eq "ManagerEmail") {
                if ([string]::IsNullOrWhiteSpace($val)) { Set-ADUser -Identity $u.SamAccountName -Manager $null }
                else { $mgr = Get-ADUser -Filter "EmailAddress -eq '$val'"; Set-ADUser -Identity $u.SamAccountName -Manager $mgr.DistinguishedName }
            } elseif ($adMap.ContainsKey($attr)) {
                Set-ADUser -Identity $u.SamAccountName -Replace @{ $($adMap[$attr]) = $val }
            }
            
            # RECORD THE LOG OF CHANGE
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            $logEntry = "[$timestamp] Admin: $currentUser | Target: $email | Attr: $attr | Old: '$oldVal' | New: '$val'"
            Add-Content -Path $logPath -Value $logEntry
            
            $r["Sync"] = $false
        } catch {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            Add-Content -Path $logPath -Value "[$timestamp] ERROR for $email ($attr): $($_.Exception.Message)"
        }
    }
    $lblStatus.Text = "Sync finished. Check SyncLog.txt for details."; $Form.Refresh()
})

[void]$Form.ShowDialog()

# =====================================================================
# Script Name: ComparePersonio2AD.ps1
# Description: GUI Tool to audit Personio HR data vs Active Directory
# =====================================================================

# --- HIDE THE CONSOLE WINDOW ON STARTUP ---
$code = @"
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
"@
$winApi = Add-Type -MemberDefinition $code -Name "Win32ShowWindow" -Namespace Win32Functions -PassThru
$hwnd = (Get-Process -Id $PID).MainWindowHandle
if ($hwnd -ne 0) {
    $winApi::ShowWindow($hwnd, 0) # 0 = SW_HIDE
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- GUI Form Setup ---
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Personio to Active Directory comparison tool"
$Form.Size = New-Object System.Drawing.Size(500,450)
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

$FontLabel = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

# Client ID
$lblClientId = New-Object System.Windows.Forms.Label
$lblClientId.Text = "Personio Client ID:"
$lblClientId.Location = "20,20"; $lblClientId.Size = "440,20"; $lblClientId.Font = $FontLabel
$Form.Controls.Add($lblClientId)

$txtClientId = New-Object System.Windows.Forms.TextBox
$txtClientId.Location = "20,45"; $txtClientId.Size = "440,25"
$Form.Controls.Add($txtClientId)

# Client Secret
$lblSecret = New-Object System.Windows.Forms.Label
$lblSecret.Text = "Personio Client Secret:"
$lblSecret.Location = "20,80"; $lblSecret.Size = "440,20"; $lblSecret.Font = $FontLabel
$Form.Controls.Add($lblSecret)

$txtSecret = New-Object System.Windows.Forms.TextBox
$txtSecret.Location = "20,105"; $txtSecret.Size = "440,25"; $txtSecret.PasswordChar = '*'
$Form.Controls.Add($txtSecret)

# Export Folder
$lblFolder = New-Object System.Windows.Forms.Label
$lblFolder.Text = "Export Folder (Paste path or Browse):"
$lblFolder.Location = "20,140"; $lblFolder.Size = "440,20"; $lblFolder.Font = $FontLabel
$Form.Controls.Add($lblFolder)

$txtFolder = New-Object System.Windows.Forms.TextBox
$txtFolder.Location = "20,165"; $txtFolder.Size = "340,25"
$txtFolder.ReadOnly = $false 
$Form.Controls.Add($txtFolder)

$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Text = "Browse..."
$btnBrowse.Location = "370,164"; $btnBrowse.Size = "90,26"
$btnBrowse.Add_Click({
    $FolderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if($FolderBrowser.ShowDialog() -eq "OK") { $txtFolder.Text = $FolderBrowser.SelectedPath }
})
$Form.Controls.Add($btnBrowse)

# Status Label
$lblStatus = New-Object System.Windows.Forms.Label
$lblStatus.Text = "Ready."
$lblStatus.Location = "20,280"; $lblStatus.Size = "440,60"; $lblStatus.ForeColor = "Gray"
$Form.Controls.Add($lblStatus)

# Run Button
$btnRun = New-Object System.Windows.Forms.Button
$btnRun.Text = "Start Sync Process"
$btnRun.Location = "20,220"; $btnRun.Size = "440,40"
$btnRun.BackColor = "#0078D7"; $btnRun.ForeColor = "White"; $btnRun.Font = $FontLabel

# --- MAIN LOGIC ---
$btnRun.Add_Click({
    $ProgressPreference = 'SilentlyContinue'
    $WarningPreference = 'SilentlyContinue'
    
    if ([string]::IsNullOrWhiteSpace($txtClientId.Text) -or [string]::IsNullOrWhiteSpace($txtSecret.Text) -or [string]::IsNullOrWhiteSpace($txtFolder.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please fill in all fields.", "Input Required")
        return
    }

    if (!(Test-Path $txtFolder.Text)) {
        [System.Windows.Forms.MessageBox]::Show("The provided export path does not exist.", "Invalid Path")
        return
    }

    $btnRun.Enabled = $false
    $lblStatus.Text = "Authenticating with Personio..."
    $lblStatus.ForeColor = "Blue"
    $Form.Refresh()

    try {
        $path = $txtFolder.Text
        $personioCsv = Join-Path $path "PersonioEmployees.csv"
        $adCsv       = Join-Path $path "ADEmployees.csv"
        $excelExport = Join-Path $path "EmployeeComparison.xlsx"

        # 1. Auth
        $authUri = "https://api.personio.de/v1/auth"
        $authBody = @{ client_id = $txtClientId.Text; client_secret = $txtSecret.Text } | ConvertTo-Json
        $authResponse = Invoke-RestMethod -Method Post -Uri $authUri -Body $authBody -ContentType "application/json" -UseBasicParsing
        $token = $authResponse.data.token
        $headers = @{ "Authorization" = "Bearer $token"; "Accept" = "application/json" }

        # 2. Fetch Personio
        $lblStatus.Text = "Downloading Personio data..." ; $Form.Refresh()
        $personioEmployees = @(); $offset = 0; $limit = 200; $hasMore = $true

        while ($hasMore) {
            $uri = "https://api.personio.de/v1/company/employees?limit=$limit&offset=$offset"
            $response = Invoke-WebRequest -Method Get -Uri $uri -Headers $headers -UseBasicParsing
            if ($response.Headers.ContainsKey("Authorization")) { $headers["Authorization"] = $response.Headers["Authorization"] }
            $jsonContent = $response.Content | ConvertFrom-Json
            if ($null -eq $jsonContent.data -or $jsonContent.data.Count -eq 0) { $hasMore = $false } 
            else {
                foreach ($emp in $jsonContent.data) {
                    $attr = $emp.attributes
                    $personioEmployees += [PSCustomObject]@{
                        EmailAddress = if ($attr.email) { $attr.email.value } else { $null }
                        GivenName    = if ($attr.first_name) { $attr.first_name.value } else { $null }
                        Surname      = if ($attr.last_name) { $attr.last_name.value } else { $null }
                        Title        = if ($attr.position) { $attr.position.value } else { $null }
                        Office       = if ($attr.office.value) { $attr.office.value.attributes.name } else { $null }
                        Company      = if ($attr.subcompany.value) { $attr.subcompany.value.attributes.name } else { "Company" }
                        Department   = if ($attr.department.value) { $attr.department.value.attributes.name } else { $null }
                        ManagerEmail = if ($attr.supervisor.value) { $attr.supervisor.value.attributes.email.value } else { $null }
                        MobilePhone  = if ($attr.mobile_phone) { $attr.mobile_phone.value } else { $null }
                        OfficePhone  = if ($attr.office_number) { $attr.office_number.value } else { $null }
                    }
                }
                $offset += $limit
            }
        }

        # 3. AD & Compare
        $lblStatus.Text = "Auditing against Active Directory..." ; $Form.Refresh()
        if (!(Get-Module -Name ActiveDirectory)) { Import-Module ActiveDirectory }
        $adEmployees = @(); $differences = @()
        $fields = @("GivenName", "Surname", "Title", "Office", "Company", "Department", "ManagerEmail", "MobilePhone", "OfficePhone")

        foreach ($pEmp in $personioEmployees) {
            if ([string]::IsNullOrWhiteSpace($pEmp.EmailAddress)) { continue }
            $adUser = Get-ADUser -Filter "UserPrincipalName -eq '$($pEmp.EmailAddress)'" -Properties GivenName, Surname, Title, Office, Company, Department, Manager, MobilePhone, OfficePhone -ErrorAction SilentlyContinue
            
            if ($adUser) {
                $mgrEmail = $null
                if ($adUser.Manager) { $mgrEmail = (Get-ADUser -Identity $adUser.Manager -Properties EmailAddress -ErrorAction SilentlyContinue).EmailAddress }
                $adObj = [PSCustomObject]@{ ADStatus = "Found"; EmailAddress = $pEmp.EmailAddress; GivenName = $adUser.GivenName; Surname = $adUser.Surname; Title = $adUser.Title; Office = $adUser.Office; Company = $adUser.Company; Department = $adUser.Department; ManagerEmail = $mgrEmail; MobilePhone = $adUser.MobilePhone; OfficePhone = $adUser.OfficePhone }
                $adEmployees += $adObj
                foreach ($f in $fields) {
                    if (([string]$pEmp.$f).Trim() -ne ([string]$adObj.$f).Trim()) {
                        $differences += [PSCustomObject]@{ EmailAddress = $pEmp.EmailAddress; Attribute = $f; PersonioValue = $pEmp.$f; ADValue = $adObj.$f }
                    }
                }
            } else {
                $adEmployees += [PSCustomObject]@{ ADStatus = "Not Found"; EmailAddress = $pEmp.EmailAddress }
                $differences += [PSCustomObject]@{ EmailAddress = $pEmp.EmailAddress; Attribute = "Account"; PersonioValue = "Exists"; ADValue = "MISSING" }
            }
        }

        # 4. Final Exports
        $lblStatus.Text = "Saving all files..." ; $Form.Refresh()
        
        # Save CSVs
        $personioEmployees | Export-Csv -Path $personioCsv -NoTypeInformation -Encoding UTF8
        $adEmployees       | Export-Csv -Path $adCsv -NoTypeInformation -Encoding UTF8
        
        # Save XLSX
        if (!(Get-Module -ListAvailable -Name ImportExcel)) { Install-Module -Name ImportExcel -Scope CurrentUser -Force -AllowClobber }
        if (Test-Path $excelExport) { Remove-Item $excelExport -Force }
        $personioEmployees | Export-Excel -Path $excelExport -WorksheetName "Personio" -AutoSize -BoldTopRow
        $adEmployees       | Export-Excel -Path $excelExport -WorksheetName "AD" -AutoSize -BoldTopRow
        if ($differences.Count -gt 0) { $differences | Export-Excel -Path $excelExport -WorksheetName "Mismatches" -AutoSize -BoldTopRow }

        $lblStatus.Text = "Success! Files saved to export folder."
        $lblStatus.ForeColor = "DarkGreen"
        [System.Windows.Forms.MessageBox]::Show("Process completed successfully!", "Done")

    } catch {
        $lblStatus.Text = "Error: $($_.Exception.Message)"
        $lblStatus.ForeColor = "Red"
    } finally {
        $btnRun.Enabled = $true
    }
})
$Form.Controls.Add($btnRun)

[void]$Form.ShowDialog()

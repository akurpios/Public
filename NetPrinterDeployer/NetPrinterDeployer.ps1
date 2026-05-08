# --- Hide the Console Window ---
$ShowWindowAsync = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
$ShowWindowType = Add-Type -MemberDefinition $ShowWindowAsync -Name "Win32ShowWindowAsync" -Namespace "Win32" -PassThru
$hwnd = (Get-Process -Id $pid).MainWindowHandle
$ShowWindowType::ShowWindowAsync($hwnd, 0) | Out-Null

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Configuration ---
$PrimaryServer = "PrintServer"
$FallbackIP    = "10.10.10.10"
$PrintServerPath = "\\10.10.10.10" # UNC path used for mapping

# --- Connectivity Check ---
$IsOnline = $false
foreach ($Target in @($PrimaryServer, $FallbackIP)) {
    if (Test-Connection -ComputerName $Target -Count 1 -Quiet) {
        $IsOnline = $true
        break
    }
}

if (-not $IsOnline) {
    [Windows.Forms.MessageBox]::Show("Connection Error:`n`nNeither $PrimaryServer nor $FallbackIP could be reached. Please check your VPN or Network connection.", "Network Unavailable", [Windows.Forms.MessageBoxButtons]::OK, [Windows.Forms.MessageBoxIcon]::Error)
    exit # Close the app
}

# --- Form Setup ---
$Form = New-Object Windows.Forms.Form
$Form.Text = "NetPrinter Deployer"
$Form.Size = New-Object Drawing.Size(400, 600)
$Form.StartPosition = "CenterScreen"
$Form.BackColor = [Drawing.Color]::White
$Form.FormBorderStyle = "FixedDialog"
$Form.MaximizeBox = $false

$Label = New-Object Windows.Forms.Label
$Label.Text = "Printers on $PrimaryServer"
$Label.Font = New-Object Drawing.Font("Segoe UI", 10, [Drawing.FontStyle]::Bold)
$Label.Location = New-Object Drawing.Point(15, 15)
$Label.AutoSize = $true
$Form.Controls.Add($Label)

$FlowPanel = New-Object Windows.Forms.FlowLayoutPanel
$FlowPanel.Location = New-Object Drawing.Point(15, 50)
$FlowPanel.Size = New-Object Drawing.Size(355, 460)
$FlowPanel.AutoScroll = $true
$Form.Controls.Add($FlowPanel)

$StatusStrip = New-Object Windows.Forms.StatusBar
$Form.Controls.Add($StatusStrip)

# --- Logic: Check and Update Button Colors ---
function Update-ButtonStates {
    $LocalPrinters = Get-Printer | Select-Object -ExpandProperty Name
    foreach ($Btn in $FlowPanel.Controls) {
        $FullID = "$PrintServerPath\$($Btn.Text)"
        if ($LocalPrinters -contains $FullID) {
            $Btn.BackColor = [Drawing.Color]::LightGreen
            $Btn.Enabled = $false
        } else {
            $Btn.BackColor = [Drawing.Color]::FromArgb(240, 240, 240)
            $Btn.Enabled = $true
        }
    }
}

# --- Function to add buttons ---
function Add-PrinterButton($Name) {
    $Btn = New-Object Windows.Forms.Button
    $Btn.Text = $Name
    $Btn.Width = 320
    $Btn.Height = 45
    $Btn.FlatStyle = "Flat"
    $Btn.Margin = New-Object Windows.Forms.Padding(0, 0, 0, 10)
    
    $Btn.Add_Click({
        $PName = $this.Text
        $FullConnection = "$PrintServerPath\$PName"
        
        $this.Enabled = $false
        $this.BackColor = [Drawing.Color]::LightGoldenrodYellow
        $StatusStrip.Text = "Requesting $PName..."
        $Form.Update()

        try {
            Start-Process "rundll32.exe" -ArgumentList "printui.dll,PrintUIEntry /in /n ""$FullConnection""" -Wait
            Start-Sleep -Seconds 2
            Update-ButtonStates
            $StatusStrip.Text = "Process finished for $PName"
        } catch {
            $this.BackColor = [Drawing.Color]::LightCoral
            $StatusStrip.Text = "Error installing $PName"
        }
    })
    $FlowPanel.Controls.Add($Btn)
}

# --- Logic: Initial Load ---
try {
    # Query using the primary hostname
    $Printers = Get-Printer -ComputerName $PrimaryServer | Where-Object { $_.Shared -eq $true }
    foreach ($P in ($Printers | Sort-Object Name)) {
        Add-PrinterButton $P.Name
    }
    Update-ButtonStates
    $StatusStrip.Text = "Ready. Green = Already Installed."
} catch {
    $StatusStrip.Text = "Could not fetch printer list."
}

$Form.ShowDialog() | Out-Null

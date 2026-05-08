# NetPrinter Deployer

A lightweight, GUI-based PowerShell application designed to simplify the installation of network shared printers for end-users via Microsoft Intune or manual deployment.

## Features

* **Dynamic Printer Listing:** Automatically fetches and displays all shared printers from a specified print server.
* **Visual Feedback:** Checks currently installed printers on the local machine and marks them **Green** (and disables the button) to prevent duplicate installations.
* **Reliable Installation:** Uses `printui.dll` via `Start-Process -Wait` to ensure the installation process completes before notifying the user.
* **Connectivity Guard:** Performs a pre-launch check for the primary server and a fallback IP; if neither is reachable, it alerts the user and exits.
* **Stealth Launch:** Automatically hides the PowerShell console window to provide a native app feel.

## Components

The package consists of three main PowerShell scripts:

1.  **`NetPrinterDeployer.ps1`**: The core application containing the GUI logic, connectivity checks, and printer installation commands.
2.  **`Installer.ps1`**: Handles the deployment by creating a local support directory (`C:\\support\\NetPritnerDeployer`), copying the main script, and creating a **Start Menu Shortcut** for easy user access.
3.  **`Uninstaller.ps1`**: Cleans up the environment by removing the script and its parent directory if empty.

## Configuration

Before deployment, update the following variables in `NetPrinterDeployer.ps1` to match your environment:

```powershell
$PrimaryServer = "YourPrintServerName"
$FallbackIP    = "10.x.x.x"
$PrintServerPath = "\\\\YourPrintServerName"
```
## Microsoft Intune Deployment Guide (Win32 App)

This section provides a step-by-step guide on how to package and deploy the **NetPrinter Deployer** as a Win32 application using Microsoft Intune.

### 1. Prepare the Installation Source
1. Create a dedicated folder (e.g., `C:\IntuneSource\NetPrinter`).
2. Place the following three files into this folder:
   * `NetPrinterDeployer.ps1`
   * `Installer.ps1`
   * `Uninstaller.ps1`

### 2. Create the .intunewin Package
Use the [Microsoft Win32 Content Prep Tool](https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool) to wrap the folder:
* **Source folder:** `C:\IntuneSource\NetPrinter`
* **Setup file:** `Installer.ps1`
* **Output folder:** Your desired destination for the `.intunewin` file.

### 3. Intune App Configuration
Log in to the [Microsoft Intune Admin Center](https://intune.microsoft.com/) and navigate to **Apps > Windows > Add**. Select **Windows app (Win32)**.

#### App Information
* **Name:** Network Printer Installer
* **Description:** GUI tool to install shared printers from the corporate print server.
* **Publisher:** Your Organization

#### Program Settings
* **Install command:** `powershell.exe -ExecutionPolicy Bypass -File "Installer.ps1"`
* **Uninstall command:** `powershell.exe -ExecutionPolicy Bypass -File "Uninstaller.ps1"`
* **Install behavior:** **User** > **Note:** This is critical. Network printers are mapped to the user profile. If set to 'System', the script will not map printers for the logged-in user.

#### Requirements
* **Operating system architecture:** x64
* **Minimum operating system:** Windows 10 1607

#### Detection Rules
Configure a manual detection rule to verify the existence of the Start Menu shortcut:
* **Rule type:** File
* **Path:** `%AppData%\Microsoft\Windows\Start Menu\Programs`
* **File or folder:** `NetPrinterDeployer.lnk`
* **Detection method:** File or folder exists
* **Associated with a 32-bit app on 64-bit clients:** No

### 4. Assignment
Assign the app to your target **User Groups**. 
* For the best experience, set the assignment to **Available**. This allows users to "Install" it from the Company Portal once, which places the permanent shortcut in their Start Menu for future use.

### 5. User Experience
1. The user opens the **Company Portal**.
2. They click **Install** on the "Network Printer Installer".
3. Once the status shows "Installed", they can launch the tool directly from their **Start Menu** at any time, even if the Company Portal button is greyed out.

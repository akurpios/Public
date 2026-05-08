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

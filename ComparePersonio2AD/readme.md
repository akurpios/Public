# Personio to AD Sync & Compare Tool

<img width="2172" height="1880" alt="image" src="https://github.com/user-attachments/assets/86c2f2e9-a1b6-42e7-bc02-02c275ee4889" />


## Overview
This tool is a professional PowerShell-based GUI application designed to synchronize employee data between **Personio (HRIS)** and **Active Directory (AD)**. It identifies discrepancies in user attributes and allows administrators to selectively update Active Directory to match the "source of truth" (Personio).

## Key Features
* **Two-Stage Analysis**: 
    * **Stage 1**: Fetches all employees from Personio API (with full pagination support).
    * **Stage 2**: Performs a 1:1 comparison for each user against Active Directory based on their UPN (Email).
* **Real-time Progress Tracking**: Enhanced progress bar and status labels showing exactly which user is being processed (e.g., "Comparing user 175 of 718").
* **Excel Reporting**: Automatically generates an `EmployeeComparison.xlsx` report with three sheets: Personio Data, AD Data, and Mismatches.
* **Selective Sync**: Integrated filtering and selection system to choose specific attributes or users for synchronization.
* **Safety First**: No data is changed in AD until the "Sync Selected to AD" button is manually pressed.

## Logging System (SyncLog.txt)
Auditability is a core feature of this tool. Every single modification made to the Active Directory is recorded in a plain-text log file named **`SyncLog.txt`**, located in your chosen Export Folder.

Each log entry includes:
* **Timestamp**: Date and time of the operation.
* **Admin**: The Windows username of the person who ran the script.
* **Target Account**: The UPN (Email) of the modified user.
* **Attribute**: The specific field that was changed (e.g., Job Title, Department, Manager).
* **Value Change**: A clear record of the `Old Value` (previous AD state) vs. the `New Value` (applied from Personio).

**Example Log Format:**
`[2024-05-20 14:30:05] Admin: DOMAIN\admin.user | Target: john.doe@company.com | Attr: Title | Old: 'Junior Dev' | New: 'Senior Dev'`

## Requirements
* **Permissions**: Must be run by a user with rights to modify objects in Active Directory.
* **Modules**: Requires `ActiveDirectory` and `ImportExcel` PowerShell modules (the script attempts to install `ImportExcel` if missing).
* **Connectivity**: Requires internet access to reach Personio API and local network access to the Domain Controller.

## How to Use
1.  **Authentication**: Enter your Personio `Client ID` and `Client Secret`.
2.  **Export Path**: Select a folder where the Excel reports and `SyncLog.txt` will be saved.
3.  **Compare**: Click **"1. Compare Systems"**. Monitor the status label for real-time progress of fetching and comparing users.
4.  **Review**: Use the "Filter" box or "Selection" buttons to review differences in the data grid.
5.  **Sync**: Click **"2. Sync Selected to AD"** to apply changes. After completion, refer to `SyncLog.txt` for a full audit trail of the session.

## Security Note
The `Client Secret` is masked in the UI. However, it is recommended to manage API credentials securely and never hardcode them into the script.

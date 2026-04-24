# Personio to AD Sync & Compare Tool

## Overview
This tool is a professional PowerShell-based GUI application designed to synchronize employee data between **Personio (HRIS)** and **Active Directory (AD)**. It identifies discrepancies in user attributes and allows administrators to selectively update Active Directory to match the "source of truth" (Personio).

<img width="2180" height="1894" alt="image" src="https://github.com/user-attachments/assets/a6c4c2b3-6a40-466e-a650-0094573b7198" />


## Key Features
* **Two-Stage Analysis**: 
    * **Stage 1**: Fetches all employees from Personio API with full pagination support.
    * **Stage 2**: Performs a 1:1 comparison for each user against Active Directory based on their UPN/Email.
* **Real-time Progress Tracking**: Enhanced progress bar and status labels showing exactly which user is being processed (e.g., "Comparing user 175 of 718").
* **Excel Reporting**: Automatically generates an `EmployeeComparison.xlsx` report with three sheets: Personio Data, AD Data, and Mismatches.
* **Selective Sync**: Integrated filtering and selection system to choose specific attributes or users for synchronization.
* **Offline Mode (Import/Export CSV)**: Capability to export comparison results to CSV for offline review and import them back to perform the sync.

## Safety & Validation Features
* **Path Validation**: The tool now mandates a valid **Export Folder**. It verifies the path exists before starting any operations, ensuring reports and logs are successfully saved.
* **Sync Confirmation Dialog**: To prevent accidental mass updates, clicking "Sync Selected to AD" triggers a confirmation window. It displays the total count of users to be modified and a list of their emails for final review.
* **Active Directory Guard**: Automatically detects users marked as "Missing in AD" and prevents them from being selected for synchronization to avoid runtime errors.
* **Fail-Safe Logging**: Improved directory checking ensures that the log file has a valid destination before the sync process begins.

## Logging System (SyncLog.txt)
Auditability is a core feature. Every modification made to Active Directory is recorded in a plain-text log file named **`SyncLog.txt`**.

Each log entry includes:
* **Timestamp**: Date and time of the operation.
* **Admin**: The Windows username of the person who ran the script.
* **Target Account**: The UPN/Email of the modified user.
* **Attribute**: The specific field changed (e.g., Title, Department, Manager).
* **Value Change**: A record of the `Old Value` vs. the `New Value` applied from Personio.

**Example Log Format:**
`[2024-05-22 14:30:05] Admin: DOMAIN\admin.user | Target: john.doe@company.com | Attr: Title | Old: 'Junior Dev' | New: 'Senior Dev'`

## Requirements
* **Permissions**: Must be run with rights to modify objects in Active Directory.
* **Modules**: Requires `ActiveDirectory` and `ImportExcel` PowerShell modules.
* **Connectivity**: Internet access for Personio API and local network access for the Domain Controller.

## How to Use
1.  **Authentication**: Enter your Personio `Client ID` and `Client Secret`.
2.  **Export Path**: Select a folder where Excel reports and `SyncLog.txt` will be saved.
3.  **Compare**: Click **"1. Compare Systems"** to monitor real-time progress.
4.  **Review**: Use the "Filter" box or "Selection" buttons to review data differences.
5.  **Sync**: Click **"Sync Selected to AD"**, review the confirmation list, and click **Yes** to apply changes.

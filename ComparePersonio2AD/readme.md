# ComparePersonio2AD.ps1

A professional PowerShell-based GUI tool designed to audit Human Resources data from **Personio** against **Active Directory (AD)**. This script identifies missing accounts and data discrepancies (e.g., mismatched job titles or departments) and exports the results to CSV and a multi-sheet Excel workbook.

## Features

* **Graphical User Interface (GUI):** No need to edit script variables; input credentials and paths directly into the window.
* **Silent Execution:** The PowerShell console is automatically hidden upon launch for a clean, application-like experience.
* **Personio Integration:** Uses the Personio REST API with automatic token rotation for large datasets.
* **AD Synchronization Audit:** Matches users via `UserPrincipalName` (UPN) and performs manager email resolution.
* **Difference Detection:** Compares 9 key attributes: GivenName, Surname, Title, Office, Company, Department, ManagerEmail, MobilePhone, and OfficePhone.
* **Multi-Format Export:** Generates two raw CSV files and one formatted `.xlsx` report with a dedicated "Mismatches" sheet.

## Prerequisites

1.  **Windows OS:** Requires Windows PowerShell 5.1 or PowerShell 7.
2.  **Active Directory Module:** Must be run on a machine with RSAT (Remote Server Administration Tools) installed.
3.  **ImportExcel Module:** The script will attempt to install this automatically if missing (requires internet access).
4.  **Personio API Credentials:** You need a **Client ID** and **Client Secret** with "Read" permissions for Employee data.

## How It Works

### Step 1: Authentication
The script connects to the Personio `/auth` endpoint. Because Personio rotates the Bearer token with every response, the script dynamically updates the authorization header during the session to prevent timeouts.

### Step 2: Data Extraction
The script fetches all active employees from Personio in batches of 200. It flattens the nested JSON structure into a clean object list.

### Step 3: Active Directory Audit
For every email address found in Personio:
1.  It queries AD for a matching `UserPrincipalName`.
2.  If the user exists, it resolves the AD Manager (translating the DistinguishedName into an Email address).
3.  It compares each field between Personio and AD.

### Step 4: Reporting
The script saves the data to the specified export folder:
* `PersonioEmployees.csv`: Raw data from the HR system.
* `ADEmployees.csv`: Raw data retrieved from Active Directory.
* `EmployeeComparison.xlsx`: A formatted workbook containing:
    * **Personio Sheet**: All HR records.
    * **AD Sheet**: All matching IT records.
    * **Mismatches Sheet**: A list of every discrepancy found (e.g., if a user's title in HR differs from their title in IT).

## Usage

1.  Right-click `ComparePersonio2AD.ps1` and select **Run with PowerShell**.
2.  The console will hide, and a GUI window will appear.
3.  Paste your **Client ID** and **Client Secret**.
4.  Type or Browse for an **Export Folder**.
5.  Click **Start Sync Process**.
6.  Once the "Success" message appears, check your folder for the reports.

## Security Note
The **Client Secret** field is masked with asterisks (`*`) for privacy. The script communicates with the Personio API over HTTPS.

## Troubleshooting
* **Invalid Path:** Ensure you have write permissions to the folder you selected.
* **Module Errors:** If the script fails to install `ImportExcel`, run PowerShell as Administrator once and manually run: `Install-Module ImportExcel -Scope CurrentUser`.
* **Zero Results:** Ensure the Personio API credentials have "Read" access to the employee attributes in the Personio settings.
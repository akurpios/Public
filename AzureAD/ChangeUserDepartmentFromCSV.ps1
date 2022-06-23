Connect-AzureAD
$NewDepartmentName = "New IT department"
Import-Csv 'C:\Users\akurpios\OneDrive - Euvic\Dokumenty\PSScripts\AzureAD\ChangeDepartment\ExcludeAllUsersfromAAD.csv' | ForEach-Object{
$id = $_.ObjectId
#Get-AzureADUser -ObjectId "$id" | select Name, ObjectId, Department
Set-AzureADUser -ObjectId "$id" -Department $NewDepartmentName
}
Get-AzureADUser -Filter "Department eq $NewDepartmentName" | select Name, ObjectId, Department

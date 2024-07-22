$CurrentDate = get-date -f dd-MM-yyyy_THH-mm-ss
$TranscriptPatch = "C:\Support\Scripts\Revoke Sessions\REPORT$CurrentDate.txt"
Start-Transcript -Path $TranscriptPatch
Import-Module Microsoft.Graph.Identity.SignIns
Connect-MgGraph -Scopes ('Policy.Read.All', 'Policy.ReadWrite.ConditionalAccess')
$csvPath = Read-Host -Prompt "Enter your CSV path without quotes"
$RuleName = Read-Host -Prompt "Enter name of the rule to create"


$params = @{
	"@odata.type" = "#microsoft.graph.ipNamedLocation"
	DisplayName = $RuleName
	IsTrusted = $false
    IpRanges=@()
}
Import-Csv $csvPath |
ForEach-Object {
$IP = $_.IP
$IpRanges=@{}
$IpRanges.add("@odata.type" , "#microsoft.graph.iPv4CidrRange")
$IpRanges.add("CidrAddress" , $IP)
$params.IpRanges+=$IpRanges

}
	
New-MgIdentityConditionalAccessNamedLocation -BodyParameter $params

Write-Host "Script Finished"
pause
Stop-Transcript
#notepad.exe $TranscriptPatch

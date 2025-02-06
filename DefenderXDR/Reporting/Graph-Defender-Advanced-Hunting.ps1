$ClientId = ""
$TenantId = ""
$Thumprint = "" #Certificate Thumbprint for Certificate to use for Client Authentication
Connect-MgGraph -ClientID $ClientId -TenantId $TenantId -CertificateThumbprint $Thumprint -NoWelcome
$KQLQuery = [IO.File]::ReadAllText("query.txt"); #Path to KQL Query
$uri = "https://graph.microsoft.com/v1.0/security/runHuntingQuery"
$query = @{query = $KQLQuery}|convertto-json -depth 100
$response = Invoke-MgGraphRequest -Uri $uri -Method POST -Body $query -ErrorAction Stop
$filename = "output.csv"
echo $filename
$table = $response.results | ForEach-Object {
    [PSCustomObject]@{
        DeviceName = $_.DeviceName #Map Defender Fileds to PS Custom Object
    }
}
$outpath = "output.csv"
$table | Export-Csv $outpath -Force
if(Test-Path $outpath){
(gc $outpath | select -Skip 1) | sc $outpath
}
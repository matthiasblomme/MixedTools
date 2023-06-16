function Read-IPAddressesFromCSV {
    param(
        [Parameter(Mandatory = $true)]
        [String]$FilePath
    )

    $IPAddresses = Import-Csv -Path $FilePath | Select-Object -ExpandProperty IPAddress

    return $IPAddresses
}

function PerformNslookup {
    param(
        [Parameter(Mandatory = $true)]
        [String]$IPAddress
    )

    $hostname = [System.Net.Dns]::GetHostEntry($IPAddress).HostName

    return $hostname
}

$csvFilePath = "C:\Matthias\mqvip\ip.txt"
$outputFilePath = "C:\Matthias\mqvip\ip-out.txt"

# Read IP addresses from the CSV file
$ipAddresses = Read-IPAddressesFromCSV -FilePath $csvFilePath

# Perform nslookup for each IP address and update the CSV file
$ipAddresses | ForEach-Object {
    $ipAddress = $_
    $hostname = PerformNslookup -IPAddress $ipAddress
    write-host $hostname

    # Update the CSV file with the hostname
    $csvData = Import-Csv -Path $csvFilePath
    $csvData | Where-Object { $_.IPAddress -eq $ipAddress } | ForEach-Object {
        $_.Hostname = $hostname
    }
    $csvData | Export-Csv -Path $outputFilePath -NoTypeInformation
}
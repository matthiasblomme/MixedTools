param(
    [parameter(Mandatory=$true)][String]$fixVersion,
    [parameter(Mandatory=$true)][String]$oldVersion,
    [parameter(Mandatory=$true)][String]$installBasePath,
    [parameter(Mandatory=$true)][String]$nodeName
)

function Update-Script {
    param (
        $scriptPath,
        $fixVersion,
        $oldVersion
    )

    $scriptContent = Get-Content -Path "$scriptPath" -Raw
    $scriptContent = $scriptContent -replace $oldVersion, $fixVersion
    Set-Content -Path "$scriptPath" -Value $scriptContent
    if($LASTEXITCODE -eq 0)
    {
        Write-Host "$scriptPath updated to $fixVersion"
    }
    else
    {
        Write-Host "Error while updating $scriptPath to $fixVersion"
        return
    }
}

function Update-EventViewer {
    param(
        $fixVersion,
        $viewName
    )

    #replace source in event viewer custom view
}

function Update-ODBC {
    param(
        $fixVersion,
        $driverName
    )

    #replace driver version
    & odbcconf CONFIGSYSDSN "IBM App Connect Enterprise $fixVersion - DataDirect Technologies 64-BIT Oracle Wire Protocol" "DSN=$driverName"
    if($LASTEXITCODE -eq 0)
    {
        Write-Host "ODBC entry $driverName updated to $fixVersion"
    }
    else
    {
        Write-Host "Error while updating ODBC entry $driverName to $fixVersion"
        return
    }
}

function Start-Ace{
    param(
        $fixVersion,
        $installBasePath,
        $nodeName
    )

    $installDir = "$installBasePath\$fixVersion"
    $pwd = [string](Get-Location)
    $checkScriptPath =  "$pwd\startAce.bat"
    Write-Host "Creating temporary file $checkScriptPath"
    New-Item -Path $checkScriptPath -Force
    Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
    Add-Content -Path $checkScriptPath -value "call `"ibmint`" start node $nodeName"
    Add-Content -Path $checkScriptPath -value "call `"mqsilist`" $nodeName"
    $output = & $checkScriptPath

    Remove-Item -Path $checkScriptPath -Force

    $selection = $output | Select-String "BIP8096I"
    if ($selection -like "*BIP8096I*") {
        Write-Host "$nodeName started."
    } else {
        Write-Host "Failed to verify $nodeName is started, please verify."
        exit 1
    }

}

function Stop-Ace {
    param(
        $oldVersion,
        $installBasePath,
        $nodeName
    )

    $installDir = "$installBasePath\$oldVersion"
    $pwd = [string](Get-Location)
    $checkScriptPath =  "$pwd\stopAce.bat"
    Write-Host "Creating temporary file $checkScriptPath"
    New-Item -Path $checkScriptPath -Force
    Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
    Add-Content -Path $checkScriptPath -value "call `"ibmint`" stop node $nodeName"
    Add-Content -Path $checkScriptPath -value "call `"mqsilist`" $nodeName"
    $output = & $checkScriptPath

    Remove-Item -Path $checkScriptPath -Force

    $selection = $output | Select-String "BIP8019E"
    if ($selection -like "*BIP8019E*") {
        Write-Host "$nodeName stopped."
    } else {
        Write-Host "Failed to verify $nodeName is stopped, please verify."
        exit 1
    }
}

Update-Script -scriptPath C:\temp\backup.cmd -fixVersion $fixVersion -oldVersion $oldVersion

Update-ODBC -fixVersion $fixVersion -driverName DRIVER1
Update-ODBC -fixVersion $fixVersion -driverName DRIVER2

Stop-Ace -oldVersion $oldVersion -installBasePath $installBasePath -nodeName $nodeName

Start-Sleep -Seconds 5

Start-Ace -fixVersion $fixVersion -installBasePath $installBasePath -nodeName $nodeName
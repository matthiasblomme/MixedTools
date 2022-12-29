#requires -version 5
<#
.SYNOPSIS
    Perform tasks after the installation of the latest ACE mod release

.DESCRIPTION
    After the installation of a new mod release there are some actions that need to run to set that
    release active and to allow for the cleanup of the older releases.
    These actions include
        1. Updating scripts that use commands/tools from the older release
        2. Update odbc data sources
        3. Stop ACE under the original version
        4. Start ACE under the newest installed version

.PARAMETER fixVersion
    The version of the latest mod release that has been installed before running this script

.PARAMETER oldVersion
    The original (current) running version of ACE

.PARAMETER installBasePath
    The base installation path where ACE is running, the default windows installation path is C:\Program Files\IBM\ACE\

.PARAMETER nodeName
    The name of the integration node that is running and needs to switch to the latest mod release

.OUTPUTS
    Logging is written to the console

.NOTES
    Version:        1.0
    Author:         Matthias Blomme
    Creation Date:  2022-12-29
    Purpose/Change: Initial script development

.EXAMPLE
    .\postInstallAceModRelease.ps1 -fixVersion 12.0.7.0 -oldVersion 12.0.5.0 -installBasePath "C:\Program Files\ibm\ACE" -nodeName TEST
#>

#-----------------------------------------------------------[Parameters]----------------------------------------------------------
param(
    [parameter(Mandatory=$true)][String]$fixVersion,
    [parameter(Mandatory=$true)][String]$oldVersion,
    [parameter(Mandatory=$true)][String]$installBasePath,
    [parameter(Mandatory=$true)][String]$nodeName
)

#---------------------------------------------------------[Initialisations]--------------------------------------------------------


#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Script Version
$sScriptVersion = "1.0"

#-----------------------------------------------------------[Functions]------------------------------------------------------------
function Write-Log {
    <#
    .SYNOPSIS
        Console log writer

    .DESCRIPTION
        Write-Log writes to the console and prepends the date and time in the "yyyy-MM-dd HH:mm:ss.fff" format
        to each loch line

    .PARAMETER entry
        The log line to write

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Update-Script -scriptPath "C:\temp\backup.cmd" -fixVersion 12.0.7.0 -oldVersion 12.0.6.0
    #>

    param (
        [Parameter(Mandatory=$True, Position=0)][String]$entry
    )

    Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') $entry"
}
function Update-Script {
    <#
    .SYNOPSIS
        Update scripts/files that hardcode the mod release

    .DESCRIPTION
        Update-Script is a function that reads a script/tool/file and replaces any occurence of the old mod release
        with the newest fix version

    .PARAMETER fixVersion
        The version of the latest mod release that has been installed before running this script

    .PARAMETER oldVersion
        The original (current) running version of ACE

    .PARAMETER scriptPath
        The full path to the script/file that needs to be updated

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Write-Log "Begin run ..."
    #>

    param (
        $scriptPath,
        $fixVersion,
        $oldVersion
    )

    Begin{
        Write-Log "Begin updating $scriptPath ..."
    }

    Process{
        Try{
            if (-Not (Test-Path -Path $scriptPath)) {
                Write-Log "$scriptPath doesn't exists, skipping."
                Break
            }

            $scriptContent = Get-Content -Path "$scriptPath" -Raw
            $scriptContent = $scriptContent -replace $oldVersion, $fixVersion
            Set-Content -Path "$scriptPath" -Value $scriptContent
        }

        Catch{
            Write-Log "An exception occured updating $scriptPath to $fixVersion $error"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Updating $scriptPath to $fixVersion succesfull."
        } else {
            Write-Log "Updating $scriptPath to $fixVersion failed."
        }
    }
}

function Update-EventViewer {
    param(
        $fixVersion,
        $viewName
    )

    #replace source in event viewer custom view
    #more difficult then expected, needs to be investigated further
}

function Update-ODBC {
    <#
    .SYNOPSIS
        Update ODBC entries with drivers from the new fixpack

    .DESCRIPTION
        Update-ODBC is a function that updates the driver for an existing ODCB connection to the driver from the
        latest fixpack

    .PARAMETER fixVersion
        The version of the latest mod release that has been installed before running this script

    .PARAMETER driverName
        The name of the ODBC driver to update

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Update-ODBC -fixVersion 12.0.7.0 -driverName DRIVER1
    #>

    param(
        $fixVersion,
        $driverName
    )

    Begin{
        Write-Log "Begin updating $driverName ..."
    }

    Process{
        Try{
            & odbcconf CONFIGSYSDSN "IBM App Connect Enterprise $fixVersion - DataDirect Technologies 64-BIT Oracle Wire Protocol" "DSN=$driverName"
        }

        Catch{
            Write-Log "An exception occured updating $driverName to $fixVersion"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Updating ODBC entry $driverName to $fixVersion succesfull."
        } else {
            Write-Log "Updating ODBC entry $driverName to $fixVersion failed."
        }
    }
}

function Start-Ace{
    <#
    .SYNOPSIS
        Start a node from the new mod release

    .DESCRIPTION
        Start-Ace is a function that starts the specified node from the new mod release environment

    .PARAMETER fixVersion
        The version of the latest mod release that has been installed before running this script

    .PARAMETER installBasePath
        The base installation path where ACE is running, the default windows installation path is C:\Program Files\IBM\ACE\

    .PARAMETER nodeName
        The name of the integration node to start

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Start-Ace -fixVersion 12.0.7.0 -installBasePath "C:\Program Files\IBM\ACE\" -nodeName TestNode
    #>

    param(
        $fixVersion,
        $installBasePath,
        $nodeName
    )

    Begin{
        Write-Log "Begin start $nodeName ..."
        $installDir = "$installBasePath\$fixVersion"
        $pwd = [string](Get-Location)
        $checkScriptPath =  "$pwd\startAce.bat"
    }

    Process{
        Try{
            Write-Log "Creating temporary file $checkScriptPath"
            $null = New-Item -Path $checkScriptPath -Force
            Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
            Add-Content -Path $checkScriptPath -value "call `"ibmint`" start node $nodeName"
            Add-Content -Path $checkScriptPath -value "call `"mqsilist`" $nodeName"
            $output = & $checkScriptPath

            Remove-Item -Path $checkScriptPath -Force

            $selection = $output | Select-String "BIP8096I"
            if ($selection -like "*BIP8096I*") {
                Write-Log "$nodeName started."
            } else {
                Write-Log "Failed to verify $nodeName started, please check."
                exit 1
            }
        }

        Catch{
            Write-Log "An exception occured trying to start $nodeName"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Starting $nodeName succesfull."
        } else {
            Write-Log "Starting $nodeName failed."
        }
    }
}

function Stop-Ace {
    <#
    .SYNOPSIS
        Stop a node from the old (current) release version

    .DESCRIPTION
        Stopt-Ace is a function that stops the specified node from the original environment

    .PARAMETER oldVersion
        The version of the current mod release where the node is running on

    .PARAMETER installBasePath
        The base installation path where ACE is running, the default windows installation path is C:\Program Files\IBM\ACE\

    .PARAMETER nodeName
        The name of the integration node to stop

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Stop-Ace -fixVersion 12.0.5.0 -installBasePath "C:\Program Files\IBM\ACE\" -nodeName TestNode
    #>

    param(
        $oldVersion,
        $installBasePath,
        $nodeName
    )

    Begin{
        Write-Log "Begin start $nodeName ..."
        $installDir = "$installBasePath\$oldVersion"
        $pwd = [string](Get-Location)
        $checkScriptPath =  "$pwd\stopAce.bat"
    }

    Process{
        Try{
            Write-Log "Creating temporary file $checkScriptPath"
            $null = New-Item -Path $checkScriptPath -Force
            Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
            Add-Content -Path $checkScriptPath -value "call `"ibmint`" stop node $nodeName"
            Add-Content -Path $checkScriptPath -value "call `"mqsilist`" $nodeName"
            $output = & $checkScriptPath

            Remove-Item -Path $checkScriptPath -Force

            $selection = $output | Select-String "BIP8019E"
            if ($selection -like "*BIP8019E*") {
                Write-Log "$nodeName stopped."
            } else {
                Write-Log "Failed to verify $nodeName is stopped, please check."
                exit 1
            }
        }

        Catch{
            Write-Log "An exception occured trying to stop $nodeName"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Stopping $nodeName succesfull."
        } else {
            Write-Log "Stopping $nodeName failed."
        }
    }
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------


Write-Log("Begin postInstallAceModRelease...")
Update-Script -scriptPath C:\temp\backup.cmd -fixVersion $fixVersion -oldVersion $oldVersion

Update-ODBC -fixVersion $fixVersion -driverName DRIVER1
Update-ODBC -fixVersion $fixVersion -driverName DRIVER2

Stop-Ace -oldVersion $oldVersion -installBasePath $installBasePath -nodeName $nodeName

Start-Sleep -Seconds 5

Start-Ace -fixVersion $fixVersion -installBasePath $installBasePath -nodeName $nodeName
Write-Log("End postInstallAceModRelease.")
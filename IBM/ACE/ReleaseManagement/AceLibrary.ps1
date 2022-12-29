#requires -version 5
<#
.SYNOPSIS
    Library with functions related to ACE installation and management

.DESCRIPTION
    AceLibray contains functions to handle and interface with ACE. There are functions that can be used manage ACE
        1. Start a node
        2. Stop a node

    And there are functions more related to installation task
        1. Updating scripts that use commands/tools from the older release
        2. Update odbc data sources
        3. Unzip mod release distributions
        4. Install mod releases
        5. Check if the install was succesfull
        6. Update mqsiprofile with user additions
        7. Install custom user defined nodes
        8. Install libraries in the shared-classes
        9. Update the java.security file

.OUTPUTS
    Logging is written to the console

.NOTES
    Version:        1.0
    Author:         Matthias Blomme
    Creation Date:  2022-12-29
    Purpose/Change: Initial script development
#>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
#Library Version
$LibraryVersion = "1.0"

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

function Unzip-ModRelease {
    param (
        $fixVersion,
        $aceModDir
    )

    $aceZip = "$aceModDir.zip"
    $dir = [string](Get-Location)
    Write-Host "Unzipping $aceZip to $dir\$aceModDir"
    Expand-Archive $aceZip -DestinationPath $aceModDir -Force
}

function Install-ModRelease {
    param (
        $fixVersion,
        $aceModDir,
        $installDir,
        $logBasePath
    )

    if($LASTEXITCODE -eq 0)
    {
        Write-Host "$fixVersion already installed, skipping installation step."
        return
    }
    else
    {
        Write-Host "Going to install $fixVersion"
    }

    Set-Location $aceModDir
    $aceExe = "ACESetup$fixVersion.exe"
    $logFile = "$logBasePath\Ace_intall_$fixVersion.log"
    $aceInstallCommand = $aceExe + " /install /quiet LICENSE_ACCEPTED=TRUE InstallFolder=`"" + $installDir + "`" /log " + $logFile
    Write-Host "Going to run $aceInstallCommand"
    Write-Host "(this may take some time) ..."
    $output = (& cmd /c $aceInstallCommand)
    Write-Host $output
    if($LASTEXITCODE -eq 0)
    {
        Write-Host "The installation succeeded, continuing ..."
    }
    else
    {
        Write-Host "The installation failed, please check $logFile"
        exit 1;
    }
    Set-Location ../
    Write-Host "Removing unzipped mod release"
    Remove-Item -Path $aceModDir -Recurse -Force
}

function Update-Mqsiprofile {
    param (
        $installDir,
        $mqsiprofileAddition
    )

    $mqsiprofilePath = "$installDir\server\bin\mqsiprofile.cmd"
    if (Test-Path -Path $mqsiprofilePath) {
        $fileContent = Get-Content $mqsiprofilePath -Raw
        $found = $fileContent | Select-String 'MQSI_FREE_MASTER_PARSERS=true' -AllMatches | Foreach {$_.Matches} | Foreach {$_.Value}
        if ($found -ne $null)
        {
            Write-Host "$mqsiprofileAddition already present, skipping"
        }
        else
        {
            Write-Host "Adding content to $mqsiprofilePath"
            $mqsiprofileWrite = "

rem  Custom profile addition  [
$mqsiprofileAddition
rem ]
"
            Add-Content -Path $mqsiprofilePath -value $mqsiprofileWrite
        }
    } else {
        Write-Host "Can't locate $mqsiprofilePath, stopping script"
        exit 1
    }

}

function Check-AceInstall {
    param(
        $fixVersion,
        $installDir
    )

    #check installed service
    $serviceName = "AppConnectEnterpriseMasterService$fixVersion"
    $service = Get-Service -Name $serviceName
    if($service.Length -gt 0)
    {
        Write-Host "$fixVersion appears to be properly installed, continuing ..."
    }
    else
    {
        Write-Host "Failed to verify $fixVersion installation, check the installation"
        exit 1
    }

    #check mqsiprofile
    $pwd = [string](Get-Location)
    $checkScriptPath =  "$pwd\checkAceVersion.bat"
    Write-Host "Creating temporary file $checkScriptPath"
    New-Item -Path ./checkAceVersion.bat -Force
    Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
    Add-Content -Path $checkScriptPath -value "call `"mqsiservice.exe`" -v"
    $output = & $checkScriptPath
    Remove-Item -Path $checkScriptPath
    $selection = $output | Select-String "Version:" | select-String "$fixVersion"
    if ($selection -like "*$fixVersion*") {
        Write-Host "$fixVersion mqsiprofile appears to be properly installed, continuing ..."
    } else {
        Write-Host "Failed to verify $fixVersion installation, check mqsiprofile.cmd"
        exit 1
    }
}

function Install-UDN {
    param(
        $installDir
    )

    $pwd = [string](Get-Location)

    if (Test-Path -Path "$pwd\udn\toolkit\") {
        $pluginDir = "$installDir\tools\plugins"
        Write-Host "Copying from $pwd\udn\toolkit\ to $pluginDir"
        Copy-Item -Path $pwd\udn\toolkit\* -Destination $pluginDir -PassThru -Force
    } else {
        Write-Host "$pwd\udn\toolkit\ does not exists, skipping UDN toolkit copy ..."
    }

    if (Test-Path -Path "$pwd\udn\runtime\") {
        $jpluginDir = "$installDir\server\jplugin"
        Write-Host "Copying from $pwd\udn\runtime\ to $jpluginDir"
        Copy-Item -Path $pwd\udn\runtime\* -Destination $jpluginDir -PassThru -Force
    } else {
        Write-Host "$pwd\udn\runtime\ does not exists, skipping UDN runtime copy ..."
    }

}

function Install-SharedClasses {
    param(
        $runtimeBasePath
    )

    $pwd = [string](Get-Location)

    if (Test-Path -Path "$pwd\shared-classes") {
        $sharedClassesDir = "$runtimeBasePath\shared-classes"
        Write-Host "Copying from $pwd\shared-classes\ to $sharedClassesDir"
        Copy-Item -Path $pwd\shared-classes\* -Destination $sharedClassesDir -PassThru -Force
    } else {
        Write-Host "$pwd\shared-classes does not exists, skipping shared-classes copy ..."
    }
}

function Install-JavaSecurity {
    param(
        $installDir
    )

    $pwd = [string](Get-Location)

    if (Test-Path -Path "$pwd\security") {
        $javaSecurityPath = "$installDir\common\jdk\jre\lib\security"
        Write-Host "Copying from $pwd\security to $javaSecurityPath"
        Copy-Item -Path $pwd\security\java.security -Destination $javaSecurityPath -PassThru -Force
    } else {
        Write-Host "$pwd\security does not exists, skipping java-security copy ..."
    }
}
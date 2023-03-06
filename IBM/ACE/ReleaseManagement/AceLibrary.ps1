#requires -version 5
<#
.SYNOPSIS
    Library with functions related to ACE installation and management

.DESCRIPTION
    AceLibray contains functions to handle and interface with ACE. There are functions that can be used to manage ACE
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

#------------------------------------------------[Declarations]------------------------------------------------
#Library Version
$LibraryVersion = "1.0"

#-------------------------------------------------[Functions]--------------------------------------------------
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
        Write-Log "Begin run ..."
    #>

    param (
        [Parameter(Mandatory=$True, Position=0)][String]$entry
    )
    Begin{}

    Process{
        Write-Host "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') $entry"
    }

    End{}

}

function Check-Service {
    <#
    .SYNOPSIS
        Check if a service exists and capture the error if it doesn't

    .DESCRIPTION
        Check-Service is a function that checks if a service exists and return the name of the service if it does.
        If the service doesn't exist an empty string is returned.

    .PARAMETER serviceName
        The name of the service to check

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Check-Service -serviceName "bthserv"

    #>

    param (
        [Parameter(Mandatory=$True, Position=0)][String]$serviceName
    )
    Begin{}

    Process{
        $service = Get-Service -Name $serviceName -Erroraction 'silentlycontinue'
        return $service
    }

    End{}
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
        Update-Script -scriptPath "C:\temp\backup.cmd" -fixVersion 12.0.7.0 -oldVersion 12.0.6.0

    #>

    param (
        [Parameter(Mandatory=$True)][String]$scriptPath,
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$oldVersion
    )

    Begin{
        Write-Log "Begin updating $scriptPath ..."
    }

    Process{
        Try{
            if (-Not (Test-Path -Path $scriptPath)) {
                Write-Log "$scriptPath doesn't exists, skipping."
            } else {
                $scriptContent = Get-Content -Path "$scriptPath" -Raw
                $scriptContent = $scriptContent -replace $oldVersion, $fixVersion
                Set-Content -Path "$scriptPath" -Value $scriptContent
            }
        }

        Catch{
            Write-Log "An exception occured updating $scriptPath to $fixVersion $error"
            return
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

function Create-EventViewer {
    <#
    .SYNOPSIS
        Create a new EventViewer custom view for the latest ACE mod release

    .DESCRIPTION
        Create-Eventviewer is a function that creates a new custom view in the system event viewer just for the
        latest mod release of ACE

    .PARAMETER fixVersion
        The version of the latest mod release that has been installed before running this script

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Create-EventViewer -fixVersion 12.0.7.0

    #>
    param(
        [Parameter(Mandatory=$True)][String]$fixVersion
    )

    Begin {
        $pwd = [string](Get-Location)
        $templateFile = "$pwd\eventviewer\ACE_custom_view_template.xml"
        $targetFile = "$pwd\eventviewer\ACE_custom_view_$fixVersion.xml"
    }

    Process {
        Try {
            $viewVersion = $fixVersion.replace('.','')
            if (-Not (Test-Path -Path $templateFile)) {
                Write-Log "$templateFile doesn't exists, skipping."
            } else {
                $scriptContent = Get-Content -Path "$templateFile" -Raw
                $scriptContent = $scriptContent -replace "##viewVersion##", $viewVersion
                New-Item -Path "$targetFile" -Force | Out-Null
                Set-Content -Path "$targetFile" -Value $scriptContent
                Write-Log "Created $targetFile"
                & eventvwr.exe /v:$targetFile
            }
        }

        Catch {
            Write-Log "An exception occured creating the event viewer for $fixVersion"
            return
        }
    }

    End {
        If($?){
            Write-Log "Creating EventViewer custom log succesfull, please delete any old views present."
        } else {
            Write-Log "Creating EventViewer custom logfailed."
        }
    }
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
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$driverName
    )

    Begin{
        Write-Log "Begin updating $driverName ..."
    }

    Process{
        Try{
            $output = & odbcconf CONFIGSYSDSN "IBM App Connect Enterprise $fixVersion - DataDirect Technologies 64-BIT Oracle Wire Protocol" "DSN=$driverName"
            Write-Log $output
        }

        Catch{
            Write-Log "An exception occured updating $driverName to $fixVersion"
            return
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
        The path to the ACE runtimes (without the version), the default windows installation path is C:\Program Files\IBM\ACE\

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
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$installBasePath,
        [Parameter(Mandatory=$True)][String]$nodeName
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
        Stop-Ace is a function that stops the specified node from the original environment

    .PARAMETER oldVersion
        The version of the current mod release where the node is running on

    .PARAMETER installBasePath
        The path to the ACE runtimes (without the version), the default windows installation path is C:\Program Files\IBM\ACE\

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
        [Parameter(Mandatory=$True)][String]$oldVersion,
        [Parameter(Mandatory=$True)][String]$installBasePath,
        [Parameter(Mandatory=$True)][String]$nodeName
    )

    Begin{
        Write-Log "Begin stop $nodeName ..."
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
    <#
    .SYNOPSIS
        Unzip a mod release deliverable to a local directory

    .DESCRIPTION
        Unzip-Modrelease is a function that extracts the contents of a mod release deliverable zip to a local directory

    .PARAMETER fixVersion
        The version of the mod release to install

    .PARAMETER aceModDir
        The name of the directoy to unzip the mod release to

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Unzip-ModRelease -fixVersion 12.0.7.0 -aceModDir 12.0-ACE-WINX64-12.0.7.0
    #>
    param (
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$aceModDir
    )

    Begin{
        $aceZip = "$aceModDir.zip"
        $dir = [string](Get-Location)
        Write-Log "Begin unzip $aceZip to $dir\$aceModDir ..."
    }

    Process{
        Try{
            Expand-Archive $aceZip -DestinationPath $aceModDir -Force
        }

        Catch
        {
            Write-Log "An exception occured unzip $aceZip to $dir\$aceModDir"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Unzip $aceZip to $dir\$aceModDir succesfull."
        } else {
            Write-Log "Unzip $aceZip to $dir\$aceModDir failed."
        }
    }
}

#TODO: test
function Unzip-InterimFix {
    <#
    .SYNOPSIS
        Unzip an interim fix deliverable to a local directory

    .DESCRIPTION
        Unzip-InterimFix is a function that extracts the contents of an interim fix deliverable zip to a local directory

    .PARAMETER fixName
        The name of the interim fix to install

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Unzip-InterimFix -fixName 12.0.7.0-ACE-WinX64-LAIT42906
    #>
    param (
        [Parameter(Mandatory=$True)][String]$fixName
    )

    Begin{
        $aceZip = "$fixName.zip"
        $dir = [string](Get-Location)
        Write-Log "Begin unzip $aceZip to $dir\$fixName ..."
    }

    Process{
        Try{
            Expand-Archive $aceZip -DestinationPath $dir\$fixName -Force
        }

        Catch
        {
            Write-Log "An exception occured unzip $aceZip to $dir\$fixName"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Unzip $aceZip to $dir\$fixName succesfull."
        } else {
            Write-Log "Unzip $aceZip to $dir\$fixName failed."
        }
    }
}

function Install-ModRelease {
    <#
    .SYNOPSIS
        Install an ACE mod release

    .DESCRIPTION
        Install-ModRelease installs an ACE mod release onto the system

    .PARAMETER fixVersion
        The version of the mod release to install

    .PARAMETER aceModDir
        The name of the directoy to install from

    .PARAMETER installDir
        The directory to install the binaries to, windows default is C:\Program Files\IBM\ACE\<version>

    .PARAMETER logBasePath
        The directory to write the installation log to (in the file Ace_intall_$fixVersion.log)

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-ModRelease -fixVersion 12.0.7.0 -aceModDir 12.0-ACE-WINX64-12.0.7.0 -installDir "C:\Program Files\IBM\ACE\12.0.7.0" -logBasePath "c:\temp\"
    #>
    param (
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$aceModDir,
        [Parameter(Mandatory=$True)][String]$installDir,
        [Parameter(Mandatory=$True)][String]$logBasePath
    )

    Begin{
        $aceExe = "ACESetup$fixVersion.exe"
        $logFile = "$logBasePath\Ace_intall_$fixVersion.log"
        $aceInstallCommand = $aceExe + " /install /quiet LICENSE_ACCEPTED=TRUE InstallFolder=`"" + $installDir + "`" /log " + $logFile
        Write-Log "Begin install of $fixVersion ..."
        Write-Log "(this may take some time) ..."
    }

    Process{
        Try{
            $serviceName = "AppConnectEnterpriseMasterService$fixVersion"
            $service = Check-Service -serviceName $serviceName
            if($service.Length -gt 0)
            {
                Write-Log "Service $serviceName already exists, skipping re-installation."
                return
            }

            Set-Location $aceModDir
            Write-Log "Going to run $aceInstallCommand"
            $output = (& cmd /c $aceInstallCommand)
            Write-Log $output
            if($LASTEXITCODE -eq 0)
            {
                Write-Log "The installation succeeded, continuing ..."
            }
            else
            {
                Write-Log "The installation failed, please check $logFile"
                exit 1;
            }
            Set-Location ../
            Write-Log "Removing unzipped mod release"
            Remove-Item -Path $aceModDir -Recurse -Force
        }

        Catch
        {
            Write-Log "An exception occured installing $fixVersion"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Installation of $fixVersion succesfull."
        } else {
            Write-Log "Installation of $fixVersion failed."
            exit 1
        }
    }
}

#TODO: test
function TestInstall-ModRelease {
    <#
    .SYNOPSIS
        TestInstall an ACE mod release

    .DESCRIPTION
        TestInstall-ModRelease installs an ACE mod release onto the system

    .PARAMETER fixVersion
        The version of the mod release to testinstall

    .PARAMETER aceModDir
        The name of the directoy to testinstall from

    .PARAMETER installDir
        The directory to testinstall the binaries to, windows default is C:\Program Files\IBM\ACE\<version>

    .PARAMETER logBasePath
        The directory to write the testinstallation log to (in the file Ace_intall_$fixVersion.log)

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-ModRelease -fixVersion 12.0.7.0 -aceModDir 12.0-ACE-WINX64-12.0.7.0 -installDir "C:\Program Files\IBM\ACE\12.0.7.0" -logBasePath "c:\temp\"
    #>
    param (
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$aceModDir,
        [Parameter(Mandatory=$True)][String]$installDir,
        [Parameter(Mandatory=$True)][String]$logBasePath
    )

    Begin{
        $aceExe = "ACESetup$fixVersion.exe"
        $logFile = "$logBasePath\Ace_intall_$fixVersion.log"
        $aceInstallCommand = $aceExe + " /testinstall /quiet LICENSE_ACCEPTED=TRUE InstallFolder=`"" + $installDir + "`" /log " + $logFile
        Write-Log "Begin install of $fixVersion ..."
        Write-Log "(this may take some time) ..."
    }

    Process{
        Try{
            $serviceName = "AppConnectEnterpriseMasterService$fixVersion"
            $service = Check-Service -serviceName $serviceName
            if($service.Length -gt 0)
            {
                Write-Log "Service $serviceName already exists, skipping re-installation."
                return
            }

            Set-Location $aceModDir
            Write-Log "Going to run $aceInstallCommand"
            $output = (& cmd /c $aceInstallCommand)
            Write-Log $output
            if($LASTEXITCODE -eq 0)
            {
                Write-Log "The installation succeeded, continuing ..."
            }
            else
            {
                Write-Log "The installation failed, please check $logFile"
                exit 1;
            }
            Set-Location ../
            Write-Log "Removing unzipped mod release"
            Remove-Item -Path $aceModDir -Recurse -Force
        }

        Catch
        {
            Write-Log "An exception occured installing $fixVersion"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Installation of $fixVersion succesfull."
        } else {
            Write-Log "Installation of $fixVersion failed."
            exit 1
        }
    }
}

#TODO: test
function Install-InterimFix {
    <#
    .SYNOPSIS
        Install an ACE intermin fix

    .DESCRIPTION
        Install-InterimFix installs an ACE interim fix onto the system

    .PARAMETER aceVersion
        The version of runtime to install to

    .PARAMETER fixName
        The name of the fix to install

    .PARAMETER installDir
        The directory to install the binaries to, windows default is C:\Program Files\IBM\ACE\<version>

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-ModRelease -aceVersion 12.0.7.0 -fixName 12.0.7.0-ACE-WinX64-LAIT42906 -installDir "C:\Program Files\IBM\ACE\12.0.7.0"
    #>
    param (
        [Parameter(Mandatory=$True)][String]$aceVersion,
        [Parameter(Mandatory=$True)][String]$fixName,
        [Parameter(Mandatory=$True)][String]$installDir
    )

    Begin{
        $aceExe = "mqsifixinst.cmd"
        $aceInstallCommand = $aceExe + " `"" + $installDir + "`" install " + $fixName
        Write-Log "Begin install of $fixName ..."
        Write-Log "(this may take some time) ..."
    }

    Process{
        Try{
            $dir = [string](Get-Location)
            $aceFixDir = $dir/$fixName
            Set-Location $aceFixDir
            Write-Log "Going to run $aceInstallCommand"
            $output = (& cmd /c $aceInstallCommand)
            Write-Log $output
            if($LASTEXITCODE -eq 0)
            {
                Write-Log "The installation succeeded, continuing ..."
            }
            else
            {
                Write-Log "The installation failed, please check $logFile"
                exit 1;
            }
            Set-Location ../
            Write-Log "Removing unzipped mod release"
            Remove-Item -Path $aceFixDir -Recurse -Force
        }

        Catch
        {
            Write-Log "An exception occured installing $fixName"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Installation of $fixName succesfull."
        } else {
            Write-Log "Installation of $fixName failed."
            exit 1
        }
    }
}

#TODO: test
function TestInstall-InterimFix {
    <#
    .SYNOPSIS
        TestInstall an ACE intermin fix

    .DESCRIPTION
        TestInstall-InterimFix testinstalls an ACE interim fix onto the system

    .PARAMETER aceVersion
        The version of runtime to testinstall to

    .PARAMETER fixName
        The name of the fix to testinstall

    .PARAMETER installDir
        The directory to testinstall the binaries to, windows default is C:\Program Files\IBM\ACE\<version>

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-ModRelease -aceVersion 12.0.7.0 -fixName 12.0.7.0-ACE-WinX64-LAIT42906 -installDir "C:\Program Files\IBM\ACE\12.0.7.0"
    #>
    param (
        [Parameter(Mandatory=$True)][String]$aceVersion,
        [Parameter(Mandatory=$True)][String]$fixName,
        [Parameter(Mandatory=$True)][String]$installDir,
        [Parameter(Mandatory=$True)][String]$logBasePath
    )

    Begin{
        $aceExe = "mqsifixinst.cmd"
        $aceInstallCommand = $aceExe + " `"" + $installDir + "`" testinstall " + $fixName
        Write-Log "Begin install of $fixName ..."
        Write-Log "(this may take some time) ..."
    }

    Process{
        Try{
            $dir = [string](Get-Location)
            $aceFixDir = $dir/$fixName
            Set-Location $aceFixDir
            Write-Log "Going to run $aceInstallCommand"
            $output = (& cmd /c $aceInstallCommand)
            Write-Log $output
            if($LASTEXITCODE -eq 0)
            {
                Write-Log "The installation succeeded, continuing ..."
            }
            else
            {
                Write-Log "The installation failed, please check $logFile"
                exit 1;
            }
            Set-Location ../
            Write-Log "Removing unzipped mod release"
            Remove-Item -Path $aceFixDir -Recurse -Force
        }

        Catch
        {
            Write-Log "An exception occured installing $fixName"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Installation of $fixName succesfull."
        } else {
            Write-Log "Installation of $fixName failed."
            exit 1
        }
    }
}

function Update-Mqsiprofile {
    <#
    .SYNOPSIS
        Update the mqsiprofile file with custom environment variables

    .DESCRIPTION
        Update-Mqsiprofile is a function that appends custom code to the mqsirprofile.cmd file of the ACE installation

    .PARAMETER installDir
        The directory where the binaries are installed, windows default is C:\Program Files\IBM\ACE\<version>

    .PARAMETER mqsiprofileAddition
        The custom code (usually environmentvariables) to append to the mqsiprofile.cmd file

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Update-Mqsiprofile -installDir "C:\Program Files\IBM\ACE\12.0.7.0" -mqsiprofileAddition "set MQSI_FREE_MASTER_PARSERS=true"
    #>
    param (
        [Parameter(Mandatory=$True)][String]$installDir,
        [Parameter(Mandatory=$True)][String]$mqsiprofileAddition
    )

    Begin{
        $mqsiprofilePath = "$installDir\server\bin\mqsiprofile.cmd"
        Write-Log "Begin update $mqsiprofilePath ..."
    }

    Process{
        Try{
            if (Test-Path -Path $mqsiprofilePath) {
                $fileContent = Get-Content $mqsiprofilePath -Raw
                $found = $fileContent | Select-String 'MQSI_FREE_MASTER_PARSERS=true' -AllMatches | Foreach {$_.Matches} | Foreach {$_.Value}
                if ($found -ne $null)
                {
                    Write-Log "$mqsiprofileAddition already present, skipping"
                }
                else
                {
                    Write-Log "Adding content to $mqsiprofilePath"
                    $mqsiprofileWrite = "

rem  Custom profile addition  [
$mqsiprofileAddition
rem ]
"
                    Add-Content -Path $mqsiprofilePath -value $mqsiprofileWrite
                }
            } else {
                Write-Log "Can't locate $mqsiprofilePath, skipping"
                return
            }
        }

        Catch
        {
            Write-Log "An exception occured updating $mqsiprofilePath"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Update $mqsiprofilePath succesfull."
        } else {
            Write-Log "Update $mqsiprofilePath failed."
        }
    }
}

function Check-AceInstall {
    <#
    .SYNOPSIS
        Check if ACE is properly installed

    .DESCRIPTION
        Check-AceInstall is a function that verifies if ACE is properly installed by checking the service is running
        and by verifying that the command environment works

    .PARAMETER fixVersion
        The version of ACE to verify

    .PARAMETER installDir
       The directory where the binaries are installed, windows default is C:\Program Files\IBM\ACE\<version>

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Stop-Ace -fixVersion 12.0.5.0 -installBasePath "C:\Program Files\IBM\ACE\" -nodeName TestNode
    #>
    param(
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$installDir
    )

    Begin{
        Write-Log "Begin installation check ..."
    }

    Process{
        Try{
            $serviceName = "AppConnectEnterpriseMasterService$fixVersion"
            $service = Check-Service -serviceName $serviceName
            if($service.Length -gt 0)
            {
                Write-Log "$fixVersion appears to be properly installed, continuing ..."
            }
            else
            {
                Write-Log "Failed to verify $fixVersion installation (service $serviceName not found), check the installation"
                exit 1
            }

            #check mqsiprofile
            $pwd = [string](Get-Location)
            $checkScriptPath =  "$pwd\checkAceVersion.bat"
            Write-Log "Creating temporary file $checkScriptPath"
            $null = New-Item -Path ./checkAceVersion.bat -Force
            Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
            Add-Content -Path $checkScriptPath -value "call `"mqsiservice.exe`" -v"
            $output = & $checkScriptPath
            Remove-Item -Path $checkScriptPath
            $selection = $output | Select-String "Version:" | select-String "$fixVersion"
            if ($selection -like "*$fixVersion*") {
                Write-Log "$fixVersion appears to be properly installed, continuing ..."
            } else {
                Write-Log "Failed to verify $fixVersion installation, please verify"
                exit 1
            }
        }

        Catch
        {
            Write-Log "An exception occured verifying $fixVersion installation"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Verify $fixVersion installation succesfull."
        } else {
            Write-Log "Verify $fixVersion installation failed."
        }
    }
}

#TODO: test
function Check-MqsiService {
    <#
    .SYNOPSIS
        Check if ACE is properly installed

    .DESCRIPTION
        Check-AceInstall is a function that verifies if ACE is properly installed by checking the service is running
        and by verifying that the command environment works

    .PARAMETER fixVersion
        The version of ACE to verify

    .PARAMETER installDir
       The directory where the binaries are installed, windows default is C:\Program Files\IBM\ACE\<version>

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Stop-Ace -fixVersion 12.0.5.0 -installBasePath "C:\Program Files\IBM\ACE\" -nodeName TestNode
    #>
    param(
        [Parameter(Mandatory=$True)][String]$fixVersion,
        [Parameter(Mandatory=$True)][String]$installDir,
        [Parameter(Mandatory=$True)][String]$searchString
    )

    Begin{
        Write-Log "Begin installation check ..."
    }

    Process{
        Try{
            $serviceName = "AppConnectEnterpriseMasterService$fixVersion"
            $service = Check-Service -serviceName $serviceName
            if($service.Length -gt 0)
            {
                Write-Log "$fixVersion appears to be properly installed, continuing ..."
            }
            else
            {
                Write-Log "Failed to verify $fixVersion installation (service $serviceName not found), check the installation"
                exit 1
            }

            #check mqsiprofile
            $pwd = [string](Get-Location)
            $checkScriptPath =  "$pwd\checkAceVersion.bat"
            Write-Log "Creating temporary file $checkScriptPath"
            $null = New-Item -Path ./checkAceVersion.bat -Force
            Add-Content -Path $checkScriptPath -value "call `"$installDir\server\bin\mqsiprofile.cmd`""
            Add-Content -Path $checkScriptPath -value "call `"mqsiservice.exe`" -v"
            $output = & $checkScriptPath
            Remove-Item -Path $checkScriptPath
            $selection = $output | Select-String $searchString
            if ($selection -like "*$searchString*") {
                Write-Log "$searchString appears to be properly installed, continuing ..."
            } else {
                Write-Log "Failed to verify $searchString installation, please verify"
                exit 1
            }
        }

        Catch
        {
            Write-Log "An exception occured verifying $searchString installation"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Verify $searchString installation succesfull."
        } else {
            Write-Log "Verify $searchString installation failed."
        }
    }
}

function Install-UDN {
    <#
    .SYNOPSIS
        Install ACE User Define Nodes

    .DESCRIPTION
        Install-UDN is a function that installs used UDNs onto the ace runtime and toolkit

    .PARAMETER installDir
        The directory where the binaries are installed, windows default is C:\Program Files\IBM\ACE\<version>

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-UDN -installDir "C:\Program Files\IBM\ACE\12.0.7.0"
    #>
    param(
        [Parameter(Mandatory=$True)][String]$installDir
    )

    Begin{
        Write-Log "Begin installation UDN ..."
    }

    Process{
        Try{
            $pwd = [string](Get-Location)

            if (Test-Path -Path "$pwd\udn\toolkit\") {
                $pluginDir = "$installDir\tools\plugins"
                Write-Log "Copying from $pwd\udn\toolkit\ to $pluginDir"
                Copy-Item -Path $pwd\udn\toolkit\* -Destination $pluginDir -PassThru -Force | Out-Null
            } else {
                Write-Log "$pwd\udn\toolkit\ does not exists, skipping UDN toolkit copy ..."
            }

            if (Test-Path -Path "$pwd\udn\runtime\") {
                $jpluginDir = "$installDir\server\jplugin"
                Write-Log "Copying from $pwd\udn\runtime\ to $jpluginDir"
                Copy-Item -Path $pwd\udn\runtime\* -Destination $jpluginDir -PassThru -Force | Out-Null
            } else {
                Write-Log "$pwd\udn\runtime\ does not exists, skipping UDN runtime copy ..."
            }
        }

        Catch
        {
            Write-Log "An exception occured installing UDN's"
            return
        }
    }

    End{
        If($?){
            Write-Log "Installation of UDN's succesfull."
        } else {
            Write-Log "Installation of UDN's failed."
        }
    }
}

function Install-SharedClasses {
    <#
    .SYNOPSIS
        Install libraries into the Shared-Classes directory of ACE

    .DESCRIPTION
        Install-SharedClasses is a function that copies used jar files into the shared-classes directory of the
        ACE runtime

    .PARAMETER runtimeBasePath
        The directory where the ACE runtime is located, windows default is C:\ProgramData\IBM\MQSI

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-SharedClasses -runtimeBasePath "C:\ProgramData\IBM\MQSI"
    #>
    param(
        [Parameter(Mandatory=$True)][String]$runtimeBasePath
    )

    Begin{
        Write-Log "Start install shared-classes ..."
    }

    Process{
        Try{
            $pwd = [string](Get-Location)
            if (Test-Path -Path "$pwd\shared-classes") {
                $sharedClassesDir = "$runtimeBasePath\shared-classes"
                Write-Log "Copying from $pwd\shared-classes\ to $sharedClassesDir"
                Copy-Item -Path $pwd\shared-classes\* -Destination $sharedClassesDir -PassThru -Force | Out-Null
            } else {
                Write-Log "$pwd\shared-classes does not exists, skipping shared-classes copy ..."
            }
        }

        Catch
        {
            Write-Log "An exception occured installing shared-classes"
            return
        }
    }

    End{
        If($?){
            Write-Log "Installing shared-classes succesfull."
        } else {
            Write-Log "Installing shared-classes failed."
        }
    }
}

function Install-JavaSecurity {
    <#
    .SYNOPSIS
        Install a custom java.security file

    .DESCRIPTION
        Install-JavaSecurity is a function that overwrites the existing java.sercurity with an updated one

    .PARAMETER installDir
        The directory where the binaries are installed, windows default is C:\Program Files\IBM\ACE\<version>

    .NOTES
        Version:        1.0
        Author:         Matthias Blomme
        Creation Date:  2022-12-29
        Purpose/Change: Initial script development

    .EXAMPLE
        Install-JavaSecurity -installDir "C:\Program Files\IBM\ACE\12.0.7.0"
    #>
    param(
        [Parameter(Mandatory=$True)][String]$installDir
    )

    Begin{
        $aceZip = "$aceModDir.zip"
        $dir = [string](Get-Location)
        Write-Log "Begin installing java.security ..."
    }

    Process{
        Try{
            $pwd = [string](Get-Location)

            if (Test-Path -Path "$pwd\security") {
                $javaSecurityPath = "$installDir\common\jdk\jre\lib\security"
                Write-Log "Copying from $pwd\security to $javaSecurityPath"
                Copy-Item -Path $pwd\security\java.security -Destination $javaSecurityPath -PassThru -Force | Out-Null
            } else {
                Write-Log "$pwd\security does not exists, skipping java-security copy ..."
            }
        }

        Catch
        {
            Write-Log "An exception occured installing java.security"
            Break
        }
    }

    End{
        If($?){
            Write-Log "Installation java.security succesfull."
        } else {
            Write-Log "Installation java.security failed."
        }
    }
}
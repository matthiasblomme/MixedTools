param(
    [parameter(Mandatory=$true)][String]$fixVersion,
    [parameter(Mandatory=$true)][String]$installBasePath,
    [parameter(Mandatory=$true)][String]$logBasePath,
    [parameter(Mandatory=$true)][String]$runtimeBasePath
)

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
    Add-Content -Path $checkScriptPath -value "call `"C:\Program Files\ibm\ACE\$fixVersion\server\bin\mqsiprofile.cmd`""
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



#run from C:\Users\ADM-BLMM_M\modrelease
$aceModDir = "12.0-ACE-WINX64-$fixVersion"
$installDir = "$installBasePath\$fixVersion"

Unzip-ModRelease -fixVersion $fixVersion -aceModDir $aceModDir

Install-ModRelease -fixVersion $fixVersion -aceModDir $aceModDir -installDir $installDir -logBasePath $logBasePath

Update-Mqsiprofile -installDir $installDir -mqsiprofileAddition "set MQSI_FREE_MASTER_PARSERS=true"

Check-AceInstall -fixVersion $fixVersion -installDir $installDir

Install-UDN -installDir $installDir

Install-SharedClasses -runtimeBasePath $runtimeBasePath

Install-JavaSecurity -installDir $installDir
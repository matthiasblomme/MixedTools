param(
    $fixVersion,
    $installBasePath,
    $logBasePath,
    $runtimeBasePath
)

function Unzip-ModRelease {
    param (
        $fixVersion,
        $aceModDir
    )

    $aceZip = $aceModDir + ".zip"
    $dir = [string](Get-Location)
    $logLine = "Unzipping " + $aceZip + " to " + $dir + "\" + $aceModDir
    Write-Host $logLine
    Expand-Archive $aceZip -DestinationPath $aceModDir -Force
}

function Install-ModRelease {
    param (
        $fixVersion,
        $aceModDir,
        $installDir,
        $logBasePath
    )

    #TODO: check if already installed
    Set-Location $aceModDir
    $aceExe = "ACESetup" + $fixVersion + ".exe"
    $logFile = $logBasePath + "\Ace_intall_" + $fixVersion + ".log"
    $aceInstallCommand = $aceExe + " /install /quiet LICENSE_ACCEPTED=TRUE InstallFolder=`"" + $installDir + "`" /log " + $logFile
    $logLine = "Going to run " + $aceInstallCommand
    Write-Host $logLine
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
}

function Update-Mqsiprofile {
    param (
        $installDir
    )
    #TODO: check if already present
    $mqsiprofilePath = $installDir + "\server\bin\mqsiprofile.cmd"
    Add-Content -Path $mqsiprofilePath -value "rem  Custom values  ["
    Add-Content -Path $mqsiprofilePath -value "set MQSI_FREE_MASTER_PARSERS=true"
    Add-Content -Path $mqsiprofilePath -value "rem ]"
}

function Install-UDN {
    param(
        $installDir
    )

    $pwd = [string](Get-Location)
    $pluginDir = $installDir + "\tools\plugins"
    Write-Host "Copying from $pwd\udn\toolkit\ to $pluginDir"
    Copy-Item -Path .\udn\toolkit\* -Destination $pluginDir -PassThru -Force
    $jpluginDir = $installDir + "\server\jplugin"
    Write-Host "Copying from $pwd\udn\runtime\ to $jpluginDir"
    Copy-Item -Path .\udn\runtime\* -Destination $jpluginDir -PassThru -Force

}

function Install-SharedClasses {
    param(
        $runtimeBasePath
    )
    $pwd = [string](Get-Location)
    $sharedClassesDir = $runtimeBasePath + "\shared-classes"

    Write-Host "Copying from $pwd\shared-classes\ to $sharedClassesDir"
    Copy-Item -Path .\shared-classes\* -Destination $sharedClassesDir -PassThru -Force
}

function Install-JavaSecurity {
    param(
        $installDir
    )

    $javaSecurityPath = $installDir + "\common\jdk\jre\lib\security"
    Write-Host "Copying from $pwd\security to $javaSecurityPath"
    Copy-Item -Path .\security\java.security -Destination $javaSecurityPath -PassThru -Force
}

#run from C:\Users\ADM-BLMM_M\modrelease
$aceModDir = "12.0-ACE-WINX64-" + $fixVersion
$installDir = $installBasePath + "\" + $fixVersion

Unzip-ModRelease -fixVersion $fixVersion -aceModDir $aceModDir

Install-ModRelease -fixVersion $fixVersion -aceModDir $aceModDir -installDir $installDir -logBasePath $logBasePath

Update-Mqsiprofile -installDir $installDir

Install-UDN -installDir $installDir

Install-SharedClasses -runtimeBasePath $runtimeBasePath

Install-JavaSecurity -installDir $installDir
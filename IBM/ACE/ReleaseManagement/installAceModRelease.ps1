param(
    [parameter(Mandatory=$true)][String]$fixVersion,
    [parameter(Mandatory=$true)][String]$installBasePath,
    [parameter(Mandatory=$true)][String]$logBasePath,
    [parameter(Mandatory=$true)][String]$runtimeBasePath
)





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
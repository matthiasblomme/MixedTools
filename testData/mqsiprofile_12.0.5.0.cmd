@echo off
rem Licensed Materials - Property of IBM
rem 5724-A82
rem (c) Copyright IBM Corp. 2022.
rem All Rights Reserved
rem US Government Users Restricted Rights - use,
rem duplication or disclosure restricted by GSA
rem ADP Schedule Contract with IBM Corp.
rem Level: S000-L220617.11599

if defined PROSPECTIVE_MQSI_FILEPATH (
  if {"%1"} == {"silent"} (
    rem we are called from mqsicommandconsole
    echo.
    echo MQSI %MQSI_VERSION%
    echo "%MQSI_FILEPATH%"
    echo.
  ) else (
    echo mqsiprofile repetition disallowed
  )
  exit /b 0
)
::Get the parent of the directory that contains this script and set up filepath
set TMP_BASE_FILEPATH=%~dp0
pushd %TMP_BASE_FILEPATH%
set TMP_BASE_FILEPATH=
cd ..\..
SET MQSI_BASE_FILEPATH=%cd%
set PROSPECTIVE_MQSI_FILEPATH=%MQSI_BASE_FILEPATH%\server
popd
set MQSI_FILEPATH=%PROSPECTIVE_MQSI_FILEPATH%
set MQSI_WORKPATH=%PROGRAMDATA%\IBM\MQSI

set MQSI_VERSION=12.0.5.0
set MQSI_VERSION_V=12
set MQSI_VERSION_R=0
set MQSI_VERSION_M=5
set MQSI_VERSION_F=0
set MQSI_FAD=10

set MQSI_EXTENSIONS_PATH=%MQSI_WORKPATH%\extensions\%MQSI_VERSION_V%.%MQSI_VERSION_R%.%MQSI_VERSION_M%

set MQSI_REGISTRY=%MQSI_WORKPATH%

if defined PATH (
  set "PATH=%MQSI_EXTENSIONS_PATH%\server\bin;%MQSI_EXTENSIONS_PATH%\bin;%MQSI_BASE_FILEPATH%\server\bin;%MQSI_BASE_FILEPATH%\common\node;%MQSI_BASE_FILEPATH%\tools;%PATH:"=%"
) else (
  set "PATH=%MQSI_EXTENSIONS_PATH%\server\bin;%MQSI_EXTENSIONS_PATH%\bin;%MQSI_BASE_FILEPATH%\server\bin;%MQSI_BASE_FILEPATH%\common\node;%MQSI_BASE_FILEPATH%\tools"
)

if defined INCLUDE (
  set "INCLUDE=%MQSI_BASE_FILEPATH%\server\include;%INCLUDE:"=%"
) else (
  set "INCLUDE=%MQSI_BASE_FILEPATH%\server\include"
)

if defined MQSI_LILPATH (
  set "MQSI_LILPATH=%MQSI_EXTENSIONS_PATH%\server\bin;%MQSI_BASE_FILEPATH%\server\bin;%MQSI_BASE_FILEPATH%\server\jplugin;%MQSI_LILPATH:"=%"
) else (
  set "MQSI_LILPATH=%MQSI_EXTENSIONS_PATH%\server\bin;%MQSI_BASE_FILEPATH%\server\bin;%MQSI_BASE_FILEPATH%\server\jplugin"
)

if defined MQSI_SECURITY_PROVIDER_PATH (
  set "MQSI_SECURITY_PROVIDER_PATH=%MQSI_BASE_FILEPATH%\server\bin;%MQSI_SECURITY_PROVIDER_PATH:"=%"
) else (
  set "MQSI_SECURITY_PROVIDER_PATH=%MQSI_BASE_FILEPATH%\server\bin"
)

set MQSI_EXMLTCONFIGPATH=%MQSI_BASE_FILEPATH%\server\exmltConfig

if defined MQSI_NODE_PATH (
  set "MQSI_NODE_PATH=%MQSI_BASE_FILEPATH%\common\node\node_modules;%MQSI_BASE_FILEPATH%\server\nodejs_all\node_modules;%MQSI_BASE_FILEPATH%\server\nodejs_partial\node_modules;%MQSI_WORKPATH%\node_modules;%MQSI_NODE_PATH:"=%"
) else (
  set "MQSI_NODE_PATH=%MQSI_BASE_FILEPATH%\common\node\node_modules;%MQSI_BASE_FILEPATH%\server\nodejs_all\node_modules;%MQSI_BASE_FILEPATH%\server\nodejs_partial\node_modules;%MQSI_WORKPATH%\node_modules"
)

if defined LIB (
  set "LIB=%MQSI_BASE_FILEPATH%\server\lib;%LIB:"=%"
) else (
  set "LIB=%MQSI_BASE_FILEPATH%\server\lib"
)

set MQSI_CONSOLE_NLSPATH=%MQSI_BASE_FILEPATH%\server\messages\

if defined MQSI_JARPATH (
  set "MQSI_JARPATH=%MQSI_BASE_FILEPATH%\common\classes;%MQSI_BASE_FILEPATH%\server\classes;%MQSI_BASE_FILEPATH%\server\messages;%MQSI_JARPATH:"=%"
) else (
  set "MQSI_JARPATH=%MQSI_BASE_FILEPATH%\common\classes;%MQSI_BASE_FILEPATH%\server\classes;%MQSI_BASE_FILEPATH%\server\messages"
)

set MQSI_CATALINA_HOME=%MQSI_BASE_FILEPATH%\server\catalina

set MQSI_WEBADMIN_HOME=%MQSI_BASE_FILEPATH%\server\webadmin

if defined CLASSPATH (
  set "CLASSPATH=%MQSI_BASE_FILEPATH%\server\messages;%MQSI_BASE_FILEPATH%\common\classes;%MQSI_BASE_FILEPATH%\server\classes;%MQSI_BASE_FILEPATH%\common\classes\IntegrationAPI.jar;%MQSI_BASE_FILEPATH%\server\classes\brokerutil.jar;%CLASSPATH:"=%;%MQSI_WORKPATH%\common\wsrr"
) else (
  set "CLASSPATH=%MQSI_BASE_FILEPATH%\server\messages;%MQSI_BASE_FILEPATH%\common\classes;%MQSI_BASE_FILEPATH%\server\classes;%MQSI_BASE_FILEPATH%\common\classes\IntegrationAPI.jar;%MQSI_BASE_FILEPATH%\server\classes\brokerutil.jar;%MQSI_WORKPATH%\common\wsrr"
)

if defined MIBDIRS (
  set "MIBDIRS=%MQSI_BASE_FILEPATH%\server\snmp-mib;%MIBDIRS:"=%"
) else (
  set "MIBDIRS=%MQSI_BASE_FILEPATH%\server\snmp-mib"
)

if defined _NT_SYMBOL_PATH (
  set "_NT_SYMBOL_PATH=%MQSI_EXTENSIONS_PATH%\server\bin;%MQSI_EXTENSIONS_PATH%\bin;%MQSI_BASE_FILEPATH%\server\sample\xatm;%MQSI_BASE_FILEPATH%\server\sample\DotNet\DotNetInput\VS2012;%MQSI_BASE_FILEPATH%\server\sample\DotNet\DotNetCompute\VS2010;%MQSI_BASE_FILEPATH%\server\migration;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\j9vm;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\default;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\compressedrefs;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\classic;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin;%MQSI_BASE_FILEPATH%\server\bin;%_NT_SYMBOL_PATH:"=%"
) else (
  set "_NT_SYMBOL_PATH=%MQSI_EXTENSIONS_PATH%\server\bin;%MQSI_EXTENSIONS_PATH%\bin;%MQSI_BASE_FILEPATH%\server\sample\xatm;%MQSI_BASE_FILEPATH%\server\sample\DotNet\DotNetInput\VS2012;%MQSI_BASE_FILEPATH%\server\sample\DotNet\DotNetCompute\VS2010;%MQSI_BASE_FILEPATH%\server\migration;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\j9vm;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\default;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\compressedrefs;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin\classic;%MQSI_BASE_FILEPATH%\common\jdk\jre\bin;%MQSI_BASE_FILEPATH%\server\bin"
)

set MQSI_PROCESSOR_ARCHITECTURE=64

@FOR %%I IN ("%MQSI_WORKPATH%\common\profiles\*.cmd") DO @(@(@CALL "%%I"))

rem JRE path overrides in custom profiles are not allowed from 7.0 onwards
set MQSI_JREPATH=%MQSI_BASE_FILEPATH%\common\jdk\jre

if defined PATH (
  set "PATH=%MQSI_JREPATH%\bin;%MQSI_JREPATH%\lib\icc;%PATH:"=%"
) else (
  set "PATH=%MQSI_JREPATH%\bin;%MQSI_JREPATH%\lib\icc"
)

echo.
echo MQSI %MQSI_VERSION%
echo %MQSI_FILEPATH%
echo.

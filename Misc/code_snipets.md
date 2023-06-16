# Some code snippets and command examples


## Windows

### Batch

#### Run as different user
    runas /user:{username} {command/script to run}

#### Check user status and groups
    net user /dom {username}

#### netstat active connections
    netstat -n

#### netstat check port in use
    netstat -ano -p tcp |find "9443"

#### netstat check open ports
    netstat -an | findstr "LISTEN"

### Powershell

#### Get port in use 
    Get-Process -Id (Get-NetTCPConnection -LocalPort 9997).OwningProcess

#### Get open connections for one pdi
    | Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,OwningProcess, @{n="ProzessName"; e={( Get-Process -Id $_.OwningProcess).ProcessName}} | Format-Table

#### Filter command output
    mqsilist NODE -r | select-string -Pattern '(running)|(stopped)'
    ... | select-string -Pattern '.*QUEUE\((.*?)\).*'

#### netstat check open ports
    netstat -an | select-string LISTEN

## Linux

### Shell

#### grep 
    ... | grep -oP "(?<=QUEUE\().*?(?=\))" 

#### awk
    ... | awk '{printf "ALTER QL(%s) MAXDEPTH(9999)\n",$1}'

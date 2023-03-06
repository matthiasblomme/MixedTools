# Some code examples


## Windows

### Batch

#### Run as different user
runas /user:{username} {command/script to run}

#### Check user status and groups
net user /dom {username}

### Powershell

#### Get port in use 
Get-Process -Id (Get-NetTCPConnection -LocalPort 9997).OwningProcess

#### Filter command output
mqsilist NODE -r | select-string -Pattern '(running)|(stopped)'
... | select-string -Pattern '.*QUEUE\((.*?)\).*'


## Linux

### Shell

#### grep 
... | grep -oP "(?<=QUEUE\().*?(?=\))" 

#### awk
... | awk '{printf "ALTER QL(%s) MAXDEPTH(9999)\n",$1}'

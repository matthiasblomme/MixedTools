# Some code examples


## Windows

### Powershell

#### Get port in use 
Get-Process -Id (Get-NetTCPConnection -LocalPort 9997).OwningProcess

#### Filter command output
mqsilist NODE -r | select-string -Pattern '(running)|(stopped)'
... | select-string -Pattern '.*QUEUE\((.*?)\).*'


## Linux


# service log to activate
$logName = 'Microsoft-Windows-DNS-Client/Operational'

#The command below will get the Formated Date 
$temps = Get-Date -Format "dd-MM-yyyy-HH.mm"

# check the state of log of a service
Get-WinEvent -ListLog $logName | Format-List is*

# Activate the loggin of the service
$log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
$log.IsEnabled=$true
$log.SaveChanges()

# check the state again
Get-WinEvent -ListLog $logName | Format-List LogName,is*

#List All Available EvenLog
Get-WinEvent -ListLog * | Select LogName, RecordCount, MaximumSizeInBytes, IsEnabled, OwningProviderName,LastWriteTime  | Sort-Object -property @{Expression="LogName"} >>$env:PUBLIC\Desktop\ListEventlogs$temps.txt

#List All Available EvenLog Names
Get-WinEvent -ListLog * | Select LogName  | Sort-Object -property @{Expression="LogName"} >>$env:PUBLIC\Desktop\ActiveEventlogsNames$temps.txt

#retrieve all Activated eventlogs 
Get-WinEvent -ListLog * | Where-Object {$_.IsEnabled -eq “True”} | Select LogName,IsEnabled,RecordCount,MaximumSizeInBytes,OwningProviderName,FileSize,LogFilePath,LastWriteTime,IsLogFull,LogType,LogIsolation,ProviderBufferSize,ProviderMinimumNumberOfBuffers,ProviderMaximumNumberOfBuffers,ProviderLatency | Sort-Object -property @{Expression="RecordCount";Descending=$true} >>$env:PUBLIC\Desktop\ActiveEventlogs$temps.txt

#All Windows Log Messages
Get-WinEvent >>$env:PUBLIC\Desktop\AllEventlogs$temps.txt

#All Windows Log Messages with warning
Get-WinEvent  | Where-Object {$_.LevelDisplayName-eq “Warnung”} | Sort-Object -property @{Expression="LevelDisplayName"} >>$env:PUBLIC\Desktop\AllEventlogsWarings$temps.txt

Invoke-Item $env:PUBLIC\Desktop\ActiveEventlogs$temps.txt
Invoke-Item $env:PUBLIC\Desktop\ListEventlogs$temps.txt
Invoke-Item $env:PUBLIC\Desktop\ActiveEventlogsNames$temps.txt
Invoke-Item $env:PUBLIC\Desktop\AllEventlogs$temps.txt
Invoke-Item $env:PUBLIC\Desktop\AllEventlogsWarings$temps.txt

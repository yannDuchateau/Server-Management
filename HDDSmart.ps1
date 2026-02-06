<# 
 .SYNOPSIS 
    List the main drives with size, free size and the percentage of free space. 
 .DESCRIPTION 
    An important duty of a sysadmin is to check frequently the free space of the c drives is using to avoid a system crash if a drive is full.     
    With this PowerShell script you can easily check the system drive. You can configure threshold value for Warning & Alarm level. 
    Requires permission to connect to and fetch WMI data from the machine(s). 
 .NOTES 
    Author  : Yann Duchateau
    Requires: PowerShell Version 1.0 
 .LINK 
    TechNet Get-PhysicalDisk 
        https://learn.microsoft.com/de-de/windows-server/storage/storage-spaces/troubleshooting-storage-spaces 
#>

#// Start of script
function global:Write-Verbose ( [string]$Message ) 
 
# check $VerbosePreference variable, and turns -Verbose on 
{ if ( $VerbosePreference -ne 'SilentlyContinue' ) 
{ Write-Host " $Message" -ForegroundColor 'Yellow' } } 
 
$VerbosePreference = "Continue" 
$DaysToDelete = 1 
$LogDate = get-date -format "dd-MM-yyyy-hh-mm" 
$objShell = New-Object -ComObject Shell.Application  
$objFolder = $objShell.Namespace(0xA) 
$ErrorActionPreference = "silentlycontinue"

#// Get year and month for csv export file
$DateTime = Get-Date -f "dd-MM-yyyy-hh.mm"

$diskA = Get-Disk | Format-Table -AutoSize Number,FriendlyName,@{Name="Size, Gb"; Expression={[int]($_.Size/1GB)}} | Out-String

$diskB = Get-Volume -DriveLetter C | Out-String

$diskC = Get-PhysicalDisk | ft -AutoSize DeviceId,Model,@{Name="Size, Gb"; Expression={[int]($_.Size/1GB)}} | Out-String

$diskD = Get-PhysicalDisk | Sort DevideID -Descending | Get-StorageReliabilityCounter | Select-Object -Property DeviceID, Model, Wear, PowerOnHours, ReadErrorsTotal, ReadErrorsCorrected, WriteErrorsTotal, WriteErrorsUncorrected, Temperature, TemperatureMax | ft -AutoSize | Out-String

$diskE = $(Get-PhysicalDisk | Select * OperationalStatus, HealthStatus, BusType, MediaType, FriendlyName, SerialNumber, LogicalSectorSize, PhysicalSectorSize, @{Name="Size, Gb"; Expression={[int]($_.Size/1GB)}})[0] | Out-String

#// $diskF = $(Get-PhysicalDisk | Select OperationalStatus, HealthStatus, BusType, MediaType, FriendlyName, SerialNumber, LogicalSectorSize, PhysicalSectorSize, @{Name="Size, Gb"; Expression={[int]($_.Size/1GB)}})[1] | Out-String

Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
Start-Transcript -Path C:\Temp\DiskResults_"$DateTime".txt
Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
Write-Verbose "Disk Size: $diskA"
Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
Write-Verbose "Disk Status: $diskB"
Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
Write-Verbose "Disk Present: $diskC"
Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
Write-Verbose "Disk Errors: $diskD"
Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
Write-Verbose "Disk C: Health :$diskE"
Write-Host -ForegroundColor green "-     -     -     -     -     -     -     -     -     -     -     -     -     -     -     "
#// Write-Verbose "Disk D: Health :$diskF"

#// End of script
Stop-Transcript
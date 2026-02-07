#// Start of script 
function global:Write-Verbose ( [string]$Message ) 
 
# check $VerbosePreference variable, and turns -Verbose on 
{ if ( $VerbosePreference -ne 'SilentlyContinue' ) 
{ Write-Host " $Message" -ForegroundColor 'Yellow' } } 
 
$VerbosePreference = "Continue"
$DaysToDelete = 1

#// Get year and month for csv export file
$LogDate = get-date -format "dd-MM-yyyy-hh-mm" 
$objShell = New-Object -ComObject Shell.Application  
$objFolder = $objShell.Namespace(0xA) 
$ErrorActionPreference = "silentlycontinue"

#// Set CSV file name 
$HDDTestCSVFile = "C:\Temp\DiskTESTdatei"+$LogDate+".txt"
$winsatCSVFile = "C:\Temp\WinsatFormal_"+$LogDate+".txt"

#calibrate
winsat formal >>$winsatCSVFile
#// Save disk Speeds
Get-CimInstance -ComputerName 'computer' -ClassName  Win32_WinSat -Property *>>$HDDTestCSVFile
winsat disk | FT >>$HDDTestCSVFile
#// Save Random Write disk Speed
winsat disk -ran -write -drive c >>$HDDTestCSVFile
#$(Get-PhysicalDisk | Select OperationalStatus, HealthStatus, BusType, MediaType, FriendlyName, SerialNumber, LogicalSectorSize, PhysicalSectorSize, @{Name="Size, Gb"; Expression={[int]($_.Size/1GB)}})[1]
#// Save Disk Specifications
Get-PhysicalDisk |ft -Wrap >>$HDDTestCSVFile
#// Save Disk State
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object -Property DeviceID,Wear, Temperature, TemperatureMax | FT >>$HDDTestCSVFile
#// Save SSDisk "Delete Notify for Free Space" actual State
fsutil behavior query DisableDeleteNotify >>$HDDTestCSVFile

#// Displays disk Speeds
winsat disk  | FT 
#// Displays Random Write disk Speed
winsat disk -ran -write -drive c 
#// Displays Disk Specifications
Get-PhysicalDisk |ft -Wrap
#// Displays Disk State
Get-PhysicalDisk | Get-StorageReliabilityCounter | Select-Object -Property DeviceID,Wear, Temperature, TemperatureMax | FT
#// Displays SSDisk "Delete Notify for Free Space" actual State
fsutil behavior query DisableDeleteNotify
#fsutil behavior set DisableDeleteNotify 1
#winsat disk -ran -read -drive c
#winsat disk -seq -read -drive C
#winsat disk -ran -write -drive c
#winsat disk -seq -write -drive C
#winsat disk -seq -read -drive D
#winsat disk -seq -write -drive D
#winsat formal # this command runs the full assessment.
#winsat dwmformal # runs only the Desktop Windows Manager assessment which generates the graphics score.
#winsat cpuformal # runs only the CPU assessment to generate the processor score.
#winsat memformal # runs only the memory assessment to generate the memory (RAM) score.
#winsat graphicsformal # runs the graphics assessment to generate the gaming graphics score.
#winsat diskformal # runs the disk assessment to generate the primary hard disk score.
#winsat cpu # tests the processor.
#winsat mem # tests the memory
#winsat disk # tests connected storage devices
#winsat d3d # assesses the Direct 3D application abilities.
#winsat media # tests media capabilities
#winsat mfmedia # Windows Media Foundation assessment
#winsat features # runs the features assessment
#winsat dwm # runs the Desktop Windows Manager assessment
#winsat prepop # pre-populate #winsat assessment results.
Invoke-Item $HDDTestCSVFile
Invoke-Item $winsatCSVFile
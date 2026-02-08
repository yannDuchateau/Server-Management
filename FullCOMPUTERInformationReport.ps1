<# 
.CREATED BY: 
    Yann C. Duchateau 
.CREATED ON: 
    02\08\2026 
.Synopsis 
   Provide a Detailled Computer Report for Monitoring and logging 
.DESCRIPTION 
   Retrieves and Stores in an HTML file all Information about the Computer,
   including Disk Status, Operatings System, Running Processes, Running services 
   Available Services, Networks settings, and available Powershell Aliases 
.EXAMPLE 
   PS C:\Users\User\Desktop\Powershell> .\FullCOMPUTERInformationReport.ps1 
   Save the file to your c:\temp Folder with a .html extention and run the file from an elavated PowerShell prompt. 
.NOTES 
   This script will Provide detaill Information and can be refined according to only needed Datas. 
.FUNCTIONALITY 
   PowerShell v3 
#> 
#CSS codes
$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    
    
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }
    


    #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }



    .StopStatus {

        color: #ff0000;
    }
    
  
    .RunningStatus {

        color: #008000;
    }




</style>
"@


#The command below will get the name of the computer
$ComputerName = "<h1>Computer name: $env:computername</h1>"

#The command below will get the Formated Date 
$temps = Get-Date -Format "dd-MM-yyyy-HH.mm"

#The command below will get the Operating System information, convert the result to HTML code as table and store it to a variable
$OSinfoAll = Get-CimInstance -Class Win32_OperatingSystem -Verbose | ConvertTo-Html -Fragment -PreContent "<h2>Operating System Information</h2>"

$OSinfoAll2 = Get-Volume -DriveLetter C -Verbose | ConvertTo-Html -As List -Fragment -PreContent "<h2>Os Volume Info</h2>"

$datadisks = Get-CimInstance -ClassName Win32_DiskDrive | Select-Object -First 24

$DiskArrays = @(
    $datadisks | %{
        "DeviceId: $($_.DeviceId)`nModel: $($_.Model)`nSize: $($_.Size)"
    }
)
$datadisks2 = $datadisks | ConvertTo-Html -Fragment -PreContent "<h2>All Disks</h2>"

$procs = get-process -computername $env:computername -Verbose
foreach($proc in $procs)
{
   $NonPagedMem = [int64]($proc.NonpagedSystemMemorySize64/1024)
   $WorkingSet = [int64]($proc.WorkingSet64/1024)
   $VirtualMem = [int64]($proc.VirtualMemorySize64/1024)
   $id= $proc.id
   $machine = $proc.MachineName
   $process = $proc.name
   $Company = $proc.Company
   $CPU =$proc.CPU
   $procdata = new-object psobject
   $procdata | add-member noteproperty VirtualMemorySize64 $VirtualMem
   $procdata | add-member noteproperty NonpagedSystemMemorySize64 $NonPagedMem
   $procdata | add-member noteproperty WorkingSet64 $WorkingSet 
   $procdata | add-member noteproperty MachineName $machine
   $procdata | add-member noteproperty Process $process
   $procdata | add-member noteproperty Company $Company
   $procdata | add-member noteproperty CPU $CPU
   $procdata | Select-Object MachineName,process,Company,CPU,WorkingSet64,NonpagedSystemMemorySize64,VirtualMemorySize64
} 
$procs2 = $procs | ConvertTo-Html -Fragment -PreContent "<h2>All Running Processes</h2>"

#The command below will get first 100 services Running, convert the result to HTML code as table and store it to a variable
$AllServices = Get-Service | Where-Object {$_.Status -eq “Running”} | ConvertTo-Html -Property Name,DisplayName -Fragment -PreContent "<h2>All Running Services</h2>"

$TestConnection = Test-Connection -ComputerName $env:computername  -Verbose -Count 1 -Delay 2 -TTL 255 -BufferSize 256 -ThrottleLimit 32 | ConvertTo-Html -Fragment -PreContent "<h2>Test Connection</h2>"

$ServicesInfo = Get-CimInstance -ClassName Win32_Service | ConvertTo-Html -Property Name,DisplayName,State -Fragment -PreContent "<h2>All Services</h2>"

$ACLinfo = Get-Acl -Path “HKLM:\System\CurrentControlSet\Control” | ConvertTo-Html -As List -Property Path,Owner,Group,Access,Audit,Sddl -Fragment -PreContent "<h2>Test ACL</h2>"

$Aliases = Get-Alias | ConvertTo-Html -Fragment -PreContent "<h2>PowerShell Aliases</h2>"

#The command below will combine all the information gathered into a single HTML report
$Report = ConvertTo-HTML -Body "$ComputerName $OSinfoAll $OSinfoAll2 $datadisks2 $procs2 $AllServices $ServicesInfo $TestConnection $Aliases" -Head $header -Title "Computer Information Report" -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date)</p>"

#The command below will generate the report to an HTM file
$Report | Out-File C:\Temp\FullInformationReport_"$env:computername"_$temps.html

#The command below will open the report to default browser
Get-ChildItem C:\Temp\FullInformationReport_"$env:computername"_$temps.html
Invoke-Item  C:\Temp\FullInformationReport_"$env:computername"_$temps.html
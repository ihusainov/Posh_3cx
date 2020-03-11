<#
.SYNOPSIS 

Чтение логов 3cx и поиск строк "many failed authentications"
Далее по строке находим с какого ip происходили подключения и сохраняем ip  в файле 3cx_bl.txt
 
.DESCRIPTION

Необходимо запускать скрипт из Powershell
 
.OUTPUTS 

.NOTES 
Written by:  ih
 
Change Log 
V0.2  08/10/2019 - Stable version
V0.3  14/10/2019 - Add SendFtp
V0.4  22/10/2019 - Add PostgreSQL search
#>


# Connect to the 3cx Postgre database and get ip from blacklicst table
function Get-postgreSQL-Data{
   param([string]$query=$(throw 'query is required.'))
   $conn = New-Object System.Data.Odbc.OdbcConnection
   $conn.ConnectionString = "Driver={PostgreSQL Unicode(x64)};Server=localhost;Port=5480;Database=database_single;Uid=phonesystem;Pwd=koyPq9RmM8;"
   $conn.open()
   $cmd = New-object System.Data.Odbc.OdbcCommand($query,$conn)
   $ds = New-Object system.Data.DataSet
   (New-Object system.Data.odbc.odbcDataAdapter($cmd)).fill($ds) | out-null
   $conn.close()
   $ds.Tables[0]
}


$query_ip = "select distinct ipaddr from public.blacklist where blocktype='0'"

$ip_sql_Data = Get-postgreSQL-Data -query $query_ip |  Out-File -FilePath "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_chbl.txt" -Append -Encoding ASCII -Force;


# Send file to FTP for MikroTik Firewall. MikroTik get this file from пез and add to Firewall to block ip on the way
Function SendFtp {

        $WebClient = New-Object System.Net.WebClient

        $File = "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_bl.txt"
        $Ftp = "ftp://ftpuser:FtpPassword@192.168.0.21/3cx/3cx_bl.txt"
        $Uri = New-Object System.Uri($Ftp)
Try{
        $WebClient.UploadFileAsync($Uri, $File)
}
        Catch  [Net.WebException]
{
        Write-Host $_.Exception.ToString() -Foregroundcolor red
}
        While ($WebClient.IsBusy) { Continue }
}


$ipData = Get-content -Path "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_chbl.txt" | ?{$_ -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"} | %{$Matches[0]} | ?{$_ -notmatch "192\.168\.\d{1,3}\.\d{1,3}" -and $_ -notmatch "255\.255\.\d{1,3}\.\d{1,3}" -and $_ -notmatch "127\.0\.\d{1,3}\.\d{1,3}"} | %{$Matches[0] -replace "'r*'"}


# Для каждого данного из массива производим проверку на существование в файле 3cx_fbl.txt
# и если данные уже есть в файле то не записываем, иначе записываем в файл 3cx_bl.txt.

ForEach ($ip in $ipData){


If (Get-content -Path "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_fbl.txt" |  ?{$_ -match $ip}) 

        {

        Write-Host $ip | Out-Null

        }
        
        Else

        {

         Write-Output $ip  | Out-File -FilePath "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_bl.txt" -Append -Encoding ASCII -Force;
         Write-Output $ip  | Out-File -FilePath "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_fbl.txt" -Append -Encoding ASCII -Force;
         
          

        }

}


sleep 2

SendFtp

Remove-Item "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_chbl.txt" -Force

sleep 5

New-Item -Path "C:\ProgramData\3CX\Instance1\Data\Logs\3cx_bl.txt" -ItemType "file" -Force
<#

.SYNOPSIS 

Чтение логов 3cx и поиск строк "too many failed authentications"
Далее по строке находим с какого ip происходили подключения и сохраняем ip  в файле ip_blacklist.txt
 
.DESCRIPTION  

Необходимо запускать скрипт из Powershell
 
.OUTPUTS 

.NOTES 
Written by:  ih
 
Change Log 
V0.1  02/10/2019 - Stable version 
#>


# Производим поиск строки "too many failed authentications" в лог файле с расширением *.blrec и записываем данные в массив
$ipData = Select-string -path "C:\ProgramData\3CX\Instance1\Data\Logs\*.blrec" -pattern "too many failed authentications" | ?{$_ -match "\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}"} | %{$Matches[0]}


# Для каждого данного из массива производим проверку на существование в файле ip_blacklist.txt
# и если данные уже есть в файле то не записываем, иначе дозаписываем в файл.

ForEach ($ip in $ipData){

If (Get-content -path "C:\ProgramData\3CX\Instance1\Data\Logs\ip_blacklist.txt" | ?{$_ -match $ip}) 

        {

        Write-Host " "

        }
        
        Else

        {

        Write-Output $ip >> "C:\ProgramData\3CX\Instance1\Data\Logs\ip_blacklist.txt"
        
        }

}


:: Этот скрипт удаляет файлы из папки загрузки, делает образ системы, копирует его на диск Е
:: удаляет старые файлы образа, проверяет количество файлов и отправляет log's на почту
:: с помощью программ mail.ps1 и mailFalse.ps1
@echo off
Echo System backup in progress. Do not turn off the computer!
del "d:\Downloads\*.*" /s /f /q >>e:\log.txt 2>&1
::удаляем файлы в папке "загрузки"
for /d %%i in ("d:\Downloads\*") do rmdir /s /q "%%i" >>e:\log.txt 2>&1
::команда удаляет подкаталоги в папке "загрузки"
E:
wbAdmin start backup -backupTarget:E: -include:C:,D: -allCritical -quiet >>e:\log.txt 2>&1
:: Делаем образ дисков "С" и "D" на диск "E"
set folder1=E:\WindowsImageBackup\computer_name
set folder2=E:\YandexDisk\WindowsImageBackup\computer_name
:: устанавливаем переменные на директории
if exist %folder1% (
goto backup
) else (
goto mail1
)
:: Данное условие проверяет наличие директории
:backup
xcopy "%folder1%" "%folder2%" /y /e >>e:\log.txt 2>&1
:: копируем все папки и их содержимое
forfiles /p "%folder2%" /s /c "cmd /c rd /s /q @file" /d -1 >>e:\log.txt 2>&1
:: удаляем все файлы измененные день назад и ранее
set /A "COUNT=0", "COUNT1=0"
:: создаем два выражения для сравнения количества файлов
for /F %%F in ('
	robocopy "%folder1%" "%folder1%" /L /E /IS /NP /NS /NC /NJH /NJS /MINAGE:0 /NDL /XD SPPMetadataCache Logs
') do set /A "COUNT+=1"
:: считаем количество файлов в только что созданном бэкапе возраст которых не превышет 0 дней (18 файлов)
for /F %%N in ('
	robocopy "%folder2%" "%folder2%" /L /E /IS /NP /NS /NC /NJH /NJS /MINAGE:0 /NDL /XD SPPMetadataCache Logs
') do set /A "COUNT1+=1"
:: считаем количество файлов в старом бэкапе на Яндекс диске возраст которых не меньше 30 дней (18 файлов)
if %COUNT%==%COUNT1% (
echo %COUNT% %COUNT1% Backup successfully created >>e:\log.txt 2>&1
goto mail
) else (
echo %COUNT% %COUNT1% Backup Falsed >>e:\log.txt 2>&1
goto mail1
)
:mail
d:
cd "d:\folder\WdAdminStartBackup\" 
::переходим в папку со скриптом отправки оповещения
powershell -ExecutionPolicy Bypass -File mail.ps1 
::запускаем скрипт оповещения
rmdir /s /q E:\WindowsImageBackup >>e:\log.txt 2>&1
:: удаляем каталог "WindowsImageBackup" и его подкаталоги в директории "E:\"
erase E:\*.txt
:: удаляем txt файл из каталога Е
exit
:mail1
d:
cd "d:\folder\WdAdminStartBackup\" 
::переходим в папку со скриптом отправки оповещения
powershell -ExecutionPolicy Bypass -File mailFalse.ps1 
::запускаем скрипт оповещения
rmdir /s /q E:\WindowsImageBackup >>e:\log.txt 2>&1
:: удаляем каталог "WindowsImageBackup" и его подкаталоги в директории "E:\"
erase E:\*.txt
:: удаляем txt файл из каталога Е
exit
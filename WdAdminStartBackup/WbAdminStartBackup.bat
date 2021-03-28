:: Этот скрипт удаляет файлы из папки загрузки, делает образ системы, копирует его на диск Е.
:: Затем файлы образа перемещаются в папку Яндекс диска и синхронизируются в облако.
:: Удаляет старые файлы образа,отправляет оповещение и файл логов на почту с помощью mail.ps1.
@echo off
Echo System backup in progress. Do not turn off the computer!
::удаляем файлы в папке "загрузки"
del "d:\Downloads\*.*" /s /f /q >>e:\log.txt 2>&1
::команда удаляет подкаталоги в папке "загрузки"
for /d %%i in ("d:\Downloads\*") do rmdir /s /q "%%i" >>e:\log.txt 2>&1
E:
:: Делаем образ дисков "С" и "D" на диск "E"
wbAdmin start backup -backupTarget:E: -include:C:,D: -allCritical -quiet >>e:\log.txt 2>&1
:: устанавливаем переменные на директории
set folder1=E:\WindowsImageBackup\computer_name
set folder2=E:\YandexDisk\WindowsImageBackup\computer_name
:: Данное условие проверяет наличие директории
if exist %folder1% (
goto backup
) else (
:: отправляем сообщение в лог файл что директория не найдена
echo "directory E:\WindowsImageBackup\computer_name is not found" >>e:\log.txt 2>&1
goto mail
)

:backup
:: удаляем все файлы измененные день назад и ранее, чтобы хватило места на диске Е
forfiles /p "%folder2%" /s /c "cmd /c rd /s /q @file" /d -1 >>e:\log.txt 2>&1
:: копируем все папки и их содержимое в папку Яндекс диска
xcopy "%folder1%" "%folder2%" /y /e >>e:\log.txt 2>&1
:: создаем два выражения для сравнения количества файлов
set /A "COUNT=0", "COUNT1=0"
:: считаем количество файлов в только что созданном бэкапе возраст которых не превышет 0 дней (18 файлов)
for /F %%F in ('
	robocopy "%folder1%" "%folder1%" /L /E /IS /NP /NS /NC /NJH /NJS /MINAGE:0 /NDL /XD SPPMetadataCache Logs
') do set /A "COUNT+=1"
:: считаем количество файлов на Яндекс диске возраст которых не превышает 0 дней (18 файлов)
for /F %%N in ('
	robocopy "%folder2%" "%folder2%" /L /E /IS /NP /NS /NC /NJH /NJS /MINAGE:0 /NDL /XD SPPMetadataCache Logs
') do set /A "COUNT1+=1"
:: отправляем результаты в лог и файл count.txt для их сравнения и формирование письма
echo %COUNT% %COUNT1% Backup successfully created >>E:\log.txt 2>&1 
echo %COUNT% >>E:\count.txt 2>&1
echo %COUNT1% >>E:\count.txt 2>&1
goto mail

:mail
d:
::переходим в папку со скриптом отправки оповещения
cd "d:\folder\WdAdminStartBackup\" 
::запускаем скрипт оповещения
powershell -ExecutionPolicy Bypass -File mail.ps1 
exit
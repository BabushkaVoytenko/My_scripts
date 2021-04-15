:: Данный скрипт скачивает антивирус drweb c сайта.
:: Для работы скрипта требуется программа wget (https://ru.wikipedia.org/wiki/Wget)
@echo off
del /f /q d:\folder\setup.exe 
wget -P "d:/folder" https://download.geo.drweb.com/pub/drweb/cureit/setup.exe --no-check-certificate 
start d:/folder\setup.exe 
exit

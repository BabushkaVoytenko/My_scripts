:: Данный скрипт удаляет предыдущую версию файла антивируса drweb и качает новую версию c сайта.
:: Для Работы скрипта требуется программа wget (https://ru.wikipedia.org/wiki/Wget)
@echo off
del /f /q d:\folder\setup.exe 
:: удаляем старую версию файла из папки куда он скачивается
wget -P "d:/folder" https://download.geo.drweb.com/pub/drweb/cureit/setup.exe --no-check-certificate 
:: качаем файл с сайта в папку указанную пользователем
start d:/folder\setup.exe 
:: запускаем файл 
exit

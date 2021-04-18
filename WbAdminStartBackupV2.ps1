#-----------------------------------------------------------------------------------------------
#Этот скрипт делает образ системы, копирует его на Яндекс диск.
#Отправляет оповещение в телеграм бот (который нужно создать).Удаляет предыдущий образ системы,
#логи с диска и старый образ из корзины Яндекс диска.
#-----------------------------------------------------------------------------------------------
#Всплывающее уведомление для пользователя
Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = 'Осуществляется бэкап системы! Не выключайте компьютер!'
$balmsg.BalloonTipTitle = "Внимание $Env:USERNAME"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(10000)
#----------------------------------------------------------------------------------------------
#Открыл папку для общего доступа, потому что у wbadmin.exe нет другого способа создать образ системы 
#в конкретном месте. Делаем образ дисков "С" и "D" на диск "E" в папку YandexDisk
wbAdmin.exe start backup -backupTarget:\\computer_name\YandexDisk\ -allCritical -quiet >>e:\log.txt 2>&1
#находим фразу в log.txt, которая свидетельствует об успешном создании бэкапа
$string = 'Архивация успешно завершена.'
$content = get-content e:\log.txt
$string2 = $content | select-string -Pattern $string -Quiet -encoding oem
# создаем условие. Если фраза существует отправляем сообщение об успешном бэкапе.
# Если фразы не существует отправляем log.txt для проверки.
if($string2 -eq $True){
curl.exe -s -X POST `
https://api.telegram.org/bot<TOKEN>/sendMessage `
-d chat_id=<ID_ЧАТА> -d text="Backup successfully created on YandexDisk)))" | Out-Null
Remove-Item e:\log.txt
# очищаем корзину яндекс диска
curl.exe -s -H "Authorization: OAuth ваштокен" -X "DELETE" `
https://cloud-api.yandex.net/v1/disk/trash/resources/?path=
# узнать свой токен: https://oauth.yandex.ru/authorize?response_type=token&display=popup&client_id=вашid
Exit	
}
else {
curl.exe -s -X POST `
https://api.telegram.org/bot<TOKEN>/sendMessage `
-d chat_id=<ID_ЧАТА> -d text="Backup was not created on YandexDisk(((. `
Check the log.txt" | Out-Null
curl.exe -F chat_id=<ID_ЧАТА> -F document=@E:\log.txt `
https://api.telegram.org/bot<TOKEN>/sendDocument | Out-Null
Exit
}
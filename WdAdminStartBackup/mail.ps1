$serverSmtp = "smtp.mail.ru" # адрес сервера SMTP для отправки
$From = "System notification <mail address1>" # от кого
$To = "mail address2" # кому
# Логин и пароль от ящика с которого отправляю
$user = "mail address"
$pass = "password"
#--------------------------------------------------------------
$file = "E:\log.txt" # путь до файла (закомментировать, если не нужен файл)
$subject = "BACKUP CREATED" # Тема письма
$subjectfalse = "BACKUP FALSED" # Тема письма если ошибка
# Создание экземпляров класса 
$att = New-object Net.Mail.Attachment($file) # закомментировать, если не нужен файл
$mes = New-Object System.Net.Mail.MailMessage
#--------------------------------------------------------------
# устанавливаем переменные на директории, которую нужно проверить
$path= Test-Path "E:\WindowsImageBackup\computer_name"
# Данное условие проверяет наличие директории
if ($path -eq $True) { 
	# сравниваем количество файлов выведеных в файл count.txt
	$count = Get-Content E:\count.txt | Select-Object -Index 0 # извлекаем первую строку из лога 
	$count = [int]$count # преобразуем первую строку в число
	$count1 = Get-Content E:\count.txt | Select-Object -Index 1 # извлекаем вторую строку из лога
	$count1 = [int]$count1 # преобразуем вторую строку в число
	# сравниваем числа, если они совпадают письмо об успешной отправке
	# если числа не совпадают, формируем письмо об ошибке
	#-------------------------------------------------------------
	If ($count -eq $count1) { 
		# Формирование данных для отправки
		$mes.From = $From
		$mes.To.Add($To)
		$mes.Subject = $subject
		$mes.IsBodyHTML = $true
		$mes.Body = "Backup successfully created on YandexDisk"
		$mes.Attachments.Add($att) # добавление файла (закомментировать, если не нужен файл)
		#---------------------------------------------------------
		$smtp = New-Object Net.Mail.SmtpClient($serverSmtp) # создаем экземпляр класса для подключения к SMTP серверу
		$smtp.EnableSSL = $true # сервер использует SSL
		$smtp.Credentials = New-Object System.Net.NetworkCredential($user, $pass); #Создаем экземпляр класса для авторизации на сервере
		# отправляем письмо, особождаем память
		$smtp.Send($mes)
		$att.Dispose()
	}
	else {
		$mes.From = $From
		$mes.To.Add($To)
		$mes.Subject = $subjectfalse
		$mes.IsBodyHTML = $true
		$mes.Body = "Backup was not created on YandexDisk. Check the log.txt and correct script"
		$mes.Attachments.Add($att) # добавление файла (закомментировать, если не нужен файл)
		#---------------------------------------------------------
		$smtp = New-Object Net.Mail.SmtpClient($serverSmtp) # создаем экземпляр класса для подключения к SMTP серверу
		$smtp.EnableSSL = $true # сервер использует SSL
		$smtp.Credentials = New-Object System.Net.NetworkCredential($user, $pass); #Создаем экземпляр класса для авторизации на сервере
		# отправляем письмо, особождаем память
		$smtp.Send($mes)
		$att.Dispose()
		Exit # обозначить выход из программы, чтобы не удалился каталог бэкапа
	}
	# удаляем каталог "WindowsImageBackup" и его подкаталоги в директории "E:\"
	Remove-Item -recurse E:\WindowsImageBackup
	# удаляем txt файл из каталога Е
	Remove-Item E:\*.txt
	# очищаем корзину яндекс диска
	curl.exe -s -H "Authorization: OAuth ваштокен" -X "DELETE" https://cloud-api.yandex.net/v1/disk/trash/resources/?path=
	# узнать свой токен: https://oauth.yandex.ru/authorize?response_type=token&display=popup&client_id=вашid
	Exit	
}
else {
	$mes.From = $From
	$mes.To.Add($To)
	$mes.Subject = $subjectfalse
	$mes.IsBodyHTML = $true
	$mes.Body = "Backup was not created on YandexDisk. Check the log.txt and correct script"
	$mes.Attachments.Add($att) # добавление файла (закомментировать, если не нужен файл)
	#---------------------------------------------------------
	$smtp = New-Object Net.Mail.SmtpClient($serverSmtp) # создаем экземпляр класса для подключения к SMTP серверу
	$smtp.EnableSSL = $true # сервер использует SSL
	$smtp.Credentials = New-Object System.Net.NetworkCredential($user, $pass); #Создаем экземпляр класса для авторизации на сервере
	# отправляем письмо, особождаем память
	$smtp.Send($mes)
	$att.Dispose()
}








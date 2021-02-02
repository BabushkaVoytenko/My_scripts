$serverSmtp = "smtp.mail.ru" # адрес сервера SMTP для отправки
$From = "mail address1" # от кого
$To = "mail address2" # кому
# Логин и пароль от ящика с которого отправляю
$user = "mail address1"
$pass = "password"

$file = "E:\log.txt" # путь до файла (закомментировать, если не нужен файл)
$subject = "BACKUP FALSED" # Тема письма
# Создание экземпляров класса 
$att = New-object Net.Mail.Attachment($file) # закомментировать, если не нужен файл
$mes = New-Object System.Net.Mail.MailMessage
# Формирование данных для отправки
$mes.From = $From
$mes.To.Add($To)
$mes.Subject = $subject
$mes.IsBodyHTML = $true
$mes.Body = "Backup was not created on YandexDisk. Check the log.txt and correct script"
$mes.Attachments.Add($att) # добавление файла (разкоменнтировать если требуется файл)

$smtp = New-Object Net.Mail.SmtpClient($serverSmtp) # создаем экземпляр класса для подключения к SMTP серверу
$smtp.EnableSSL = $true # сервер использует SSL
$smtp.Credentials = New-Object System.Net.NetworkCredential($user, $pass); #Создаем экземпляр класса для авторизации на сервере
# отправляем письмо, особождаем память
$smtp.Send($mes)
$att.Dispose() # закомментировать, если не нужен файл




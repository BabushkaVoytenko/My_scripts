#-----------------------------------------------------------------------------------------------
#���� ������ ������ ����� �������, �������� ��� �� ������ ����.
#���������� ���������� � �������� ��� (������� ����� �������).������� ���������� ����� �������,
#���� � ����� � ������ ����� �� ������� ������ �����.
#-----------------------------------------------------------------------------------------------
#����������� ����������� ��� ������������
Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon
$path = (Get-Process -id $pid).Path
$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = '�������������� ����� �������! �� ���������� ���������!'
$balmsg.BalloonTipTitle = "�������� $Env:USERNAME"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(10000)
#----------------------------------------------------------------------------------------------
#������ ����� ��� ������ �������, ������ ��� � wbadmin.exe ��� ������� ������� ������� ����� ������� 
#� ���������� �����. ������ ����� ������ "�" � "D" �� ���� "E" � ����� YandexDisk
wbAdmin.exe start backup -backupTarget:\\computer_name\YandexDisk\ -allCritical -quiet >>e:\log.txt 2>&1
#������� ����� � log.txt, ������� ��������������� �� �������� �������� ������
$string = '��������� ������� ���������.'
$content = get-content e:\log.txt
$string2 = $content | select-string -Pattern $string -Quiet -encoding oem
# ������� �������. ���� ����� ���������� ���������� ��������� �� �������� ������.
# ���� ����� �� ���������� ���������� log.txt ��� ��������.
if($string2 -eq $True){
curl.exe -s -X POST `
https://api.telegram.org/bot<TOKEN>/sendMessage `
-d chat_id=<ID_����> -d text="Backup successfully created on YandexDisk)))" | Out-Null
Remove-Item e:\log.txt
# ������� ������� ������ �����
curl.exe -s -H "Authorization: OAuth ��������" -X "DELETE" `
https://cloud-api.yandex.net/v1/disk/trash/resources/?path=
# ������ ���� �����: https://oauth.yandex.ru/authorize?response_type=token&display=popup&client_id=���id
Exit	
}
else {
curl.exe -s -X POST `
https://api.telegram.org/bot<TOKEN>/sendMessage `
-d chat_id=<ID_����> -d text="Backup was not created on YandexDisk(((. `
Check the log.txt" | Out-Null
curl.exe -F chat_id=<ID_����> -F document=@E:\log.txt `
https://api.telegram.org/bot<TOKEN>/sendDocument | Out-Null
Exit
}
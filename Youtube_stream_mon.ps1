#Created by https://github.com/VladimirKosyuk

# Foreach of youtube streams, defined by ID, get live and playability status, if not ok - send an email

# Build date: 14.12.2020

#vars:config and log
$confg = "$PSScriptRoot\Youtube_stream"+('.txt')
$globallog = "$PSScriptRoot\Youtube_stream"+('.log')
#vars:email
$From = ""
$Subject = ""
$msg_to = ""
$Smtp_srv = ""

try

{
$values = Get-Content $confg| ConvertFrom-StringData 
$IDs = ($values.IDs).Split(',')

}

catch

{   
    Write-Output $Error[0].Exception.Message
    Write-Output ("Config file is accessible check not passed  "+(Get-Date)) | Out-File "$globallog" -Append
    Break 
}



foreach ($id in $IDs){
$web =(Invoke-WebRequest -Method Get "https://www.youtube.com/get_video_info?el=detailpage&hl=en&ps=default&video_id=$id").RawContent 
[array]$Result = $web.tostring() -split "[%]" | select-string -pattern '(22True)|(22OK)'
if(($Result -like "*22True*") -and ($Result -like "*22OK*") ){}
else {
try{
$Body = (($id)+" "+"IsLiveNow or PlayabilityStatus is not ok"+" "+(Get-Date)) 
Send-MailMessage -To $msg_to -From $From -Subject $Subject -Body $Body -Port 25 -SmtpServer $Smtp_srv
}
catch{
    Write-Output $Error[0].Exception.Message
    Write-Output ("send email function not working  "+(Get-Date)) | Out-File "$globallog" -Append
    Break 
        }
    }
}

Remove-Variable -Name * -Force -ErrorAction SilentlyContinue
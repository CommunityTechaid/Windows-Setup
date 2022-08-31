:: CTA PowerShell Script
:: For prepping fresh install for imaging
Write-Output "Run Windows Update, remove User before running this script as Administrator!"
Write-Host -NoNewLine 'Press any key to continue...'
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')

:: Create function to unpin stuff from taskbar
function Unpin-App([string]$appname) {
    ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() |
        ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Unpin from taskbar'} | %{$_.DoIt()}
}

:: Call function to unpin app
Unpin-App("Microsoft Edge")
Unpin-App("Mail")


:: Remove Meet Now icon from taskbar
$registrypath = "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer"
$name = "HideSCAMeetNow"
$value = "1"
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

:: Disable Edge desktop shortcut creation
$registrypath = "HKLM\Software\Microsoft\Windows\CurrentVersion\Explorer"
$name = "DisableEdgeDesktopShortcutCreation"
$value = "1"
New-ItemProperty -Path $registryPath -Name $name -Value $value -PropertyType DWORD -Force | Out-Null

:: Remove Edge shortcut
:: del "%PUBLIC%\Desktop\Microsoft Edge.lnk"


:: Get WindowsServer creds
$cred = Get-Credential -Credential WindowsServer\Administrator
:: Mount network drive with them
New-PSDrive -Name "Shared" -PSProvider "FileSystem" -Root "\\WindowsServer\Shared" -Credential $cred

:: Run installer
& "\\WindowsServer\Shared\PrepStuff\Ninite.exe"

:: Remove VLC shortcut
Remove-Item "C:\Users\Public\Desktop\VLC media player.lnk"

:: Remove Generic LibreOffice Shortcut
Remove-Item "C:\Users\Public\Desktop\LibreOffice 7.4.lnk"

:: Create specific ones
Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\LibreOffice 7.4\LibreOffice Calc.lnk" "C:\Users\Public\Desktop"
Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\LibreOffice 7.4\LibreOffice Writer.lnk" "C:\Users\Public\Desktop"
Copy-Item "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\LibreOffice 7.4\LibreOffice Impress.lnk" "C:\Users\Public\Desktop"

:: Copy PDFs
Copy-Item "\\WindowsServer\Shared\PrepStuff\StayingSafeOnline.pdf" "env:userprofile\desktop\Staying Safe Online.pdf"
Copy-Item "\\WindowsServer\Shared\PrepStuff\GettingStarted-Windows.pdf" "env:userprofile\desktop\Getting Started.pdf"

:: Copy unattend.xml
Copy-Item "\\WindowsServer\Shared\unattend.xml" -Destination "C:\Windows\System32\Sysprep"

:: Give instructions
Write-Output "The system is now about to run Sysprep. After which it will shutdown. Please refer to README for the next steps"

:: Do the sysprep
C:\Windows\System32\Sysprep\Sysprep.exe /generalize /shutdown /oobe /quiet

exit
# Community Techaid Windows

This repo is for the various tools, files and instructions for sorting out a fresh install of Windows 10 on a donated laptop.

The current process:
- wipe machine
- install Windows
- install programmes & drivers
- install windows updates

The aim:
- have virtualised machine running in the CTA office to provide updates via the P2P update distribution built into Windows 10.
- have a customised image to avoid additional step of installing CTA programs
- PXE setup to deploy Windows within the office

## Repo layout

./README.md	: Top level overview
./VMs/		: Example configs for the VMs
./ISOs/ 	: Instructions for creation of customised install .ISOs
./Tools/	: Place for useful scripts

## Intro

We'll cover the process of:
- [Setting up Windows Server](#setting-up-windows-server)
- [Setting up Windows Deployment Service (WDS)](#setting-up-windows-deployment-service-wds)
- [Installing Windows from WDS](#installing-windows-from-wds)
- [Creating a custom Window Image and adding it to WDS](#creating-a-custom-image)

## Setting up Windows Server

- Boot from ISO and follow installation instructions (Standard Evaluation, desktop experience)
- Check for and install updates
- Install Assessment and Deployment Toolkit, need for Windows System Image Manager to compile / edit answer files. Download from https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install (Select latest Windows 10 option). Follow dialogue to install, Microsoft User Experience / Application Virtualisation components can be deselected to save space.

## Setting up Windows Deployment Service (WDS)
- Add the Windows Deployment Service to the server:
    Server Manager > Manage > Add Roles and Features > Next > Next > Next > Select Windows Deployment Services and follow remaining dialogues
- Download Windows 10 .iso (https://www.microsoft.com/en-gb/software-download/windows10ISO)
    - Mount .iso (will presume under E:)
    - `dism /Get-WimInfo /WimFile:E:\sources\install.esd` to get list of possible images. Note index of Windows 10 Home (will presume 1)
    - `dism /export-image /SourceImageFile:E:\sources\install.esd /SouceIndex:1 /DestinationImagefile:C:\Shared\install.wim /Compress:max /CheckIntegrity`
    - Copy boot.wim to same destination folder
- Open WDS, configure server following dialogue pointing to previous destination folder for .wims
- You now have added a base image to WDS
- Right click $ServerName > Properties:
    - Boot: Set to "Continue to PXE boot unless the user presses the ESC key"

## Installing Windows from WDS

### Prerequisites

- A machine that can boot over the network / PXE
- Connection to the same network as the Windows Server

### Process

- Config machine BIOS/UEFI settings to enable PXE booting / booting over the network. If there's an option between "legacy" and UEFI network booting, select UEFI.
- Ensure the network boot option is the first option
- Boot up the machine, keeping an eye out for "Press Enter for Network Boot Services"
- Press enter again to select "Microsoft Windows Setup", and you'll then load into it.
- Select you locale setting and click next
- When prompted, enter credentials to authenticate with the WDS Server. Username should be in the format `$ServerName\Administrator`.
- Select the version of Windows to install and proceed through the normal Windows install process.

## Creating a custom image

- Start with a VM with fresh install of Windows 10 (see [Installing Windows from WDS](#installing-windows-from-wds)

### Step 1 - On the Windows Server

- Open Windows System Image Manager
- Create a new answer file (an .xml file that tweaks a Windows install both on capture and installation)
    - If not already present, you'll have to create a Windows Catalogue (a list of all the possible settings that an answer file could possibly change)
	    - Open WDS
            - Expand Servers > WinServer > Install Images > Win10
            - Right click on the desired, corresponding base image (normally Windows 10 Home)
            - Export the WIM to somewhere memorable.
            - Return to Windows System Image Manager
            - Select Tools > Create Catalog and then import the WIM you just exported and let it do it's thing.
    - Under the Windows Image view, expand the Catalog > Components and add the following to the answer file:
        - amd64_Microsoft-Windows-Deployment > RunSynchronous > RunSynchronousCommand, right click and add to Pass 4.
        - amd64_Microsoft-Windows-Setup > UserData, right click and add to Pass 1.
        - amd64_Microsoft-Windows-Shell-Setup, right click and add to Pass 4.
        - amd64_Microsoft-Windows-Shell-Setup > OOBE, right click and add to Pass 7.
        - amd64_Microsoft-Windows-Shell-Setup > UserAccounts, right click and add to Pass 7.
        - amd64_Microsoft-Windows-Shell-Setup > WindowsDeploymentServices, right click and add to Pass 1.
        - amd64_Microsoft-Windows-International-Core, right click and add to Pass 7.
        - amd64_Microsoft-Windows-International-Core-WinPE, right click and add to Pass 1.

    - Under the Answer File view:
        - Select the 1 windows PE / amd64_Microsoft-Winodws-Internation-Core-WinPE and set:
            - InputLocale: en-GB
            - SystemLocale: en-GB
            - UILanguage: en-GB
            - UserLocale: en-GB
        
        - Expand amd64_Microsoft-Winodws-Internation-Core-WinPE and select the SetupUILanguage entry and then set:
            - UILanguage: en-GB
        
        - Select the 1 windows PE / amd64_Microsoft-Windows-Setup / UserData entry and set the AcceptEula property to True.\
          (Ref: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-setup-userdata)
        
        - Expand WindowsDeploymentServices / Login and select the Credentials entry and set:
            - Domain: WindowsServer
            - Password: $password
            - Username: $username
        
        - Select the 4 Specialise / amd64_Microsoft-Deployment / RunSynchronous / RunSynchronousCommand entry and set:
            - Description: Disable Cortana Voice during OOBE
            - Order: 1
            - Path: cmd.exe /c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE /v DisableVoice /t REG_DWORD /d 1 /f\
            (Ref: https://social.technet.microsoft.com/Forums/en-US/4eb2c26c-2f15-4a0d-ba4f-0955215994df/silence-cortana-during-windows-setup?forum=win10itprosetup)
        
        - Select the 4 Specialise / amd64_Microsoft-Windows-Shell-Setup entry and set CopyProfile to True.\
          (Ref: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-copyprofile)
        
        - Select the 7 oobeSystem / amd64_Microsoft-Windows-International-Core entry and set the following properties:
            - InputLocale: en-GB
            - SystemLocale: en-GB
            - UILanguage: en-GB
            - UILanguageFallback: en-US
            - UserLocale: en-GB\
              (Ref: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-international-core)
    	- Select the 7 oobeSystem / amd64_Microsoft-Windows-Shell-Setup / OOBE entry and set the following properties:
            - HideEULAPage: true
            - HideOEMRegistrationScreen: true
            - HideOnlineAccountScreen: true
            - HideWirelessSetupInOOBE: true
            - ProtectYourPC: 3
            - Expand OOBE entry, right click and delete VMModeOptimisations\
              (Ref: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-oobe)
        - Expand the 7 oobeSystem / amd64_Microsoft-Windows-Shell-Setup / UserAccounts entry:
            - Set AdministratorPassword
            - Delete DomainAccounts
            - Right click LocalAccounts and insert new LocalAccount
            - Set the new LocalAccount properties:
                - Description: User
                - DisplayName: User
                - Groups: Administrators
                - Name: User
            - Expand LocalAccount, select Password entity and set the value property to set the user's password.\
              (Ref: https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-useraccounts)

- Save file as unattend.xml

### Step 2 - On a fresh install of Windows 10:

- Go through the OOBE to get to the desktop  
...
- Open command prompt as admin and run `net user administrator /active:yes` to enable the Administrator account.
- Right click on the start menu and sign out
- Sign in as Administrator
- Open Control Panel > User Accounts > Manage Accounts
- Select User, then delete User and remove files.
- Make sure any pending Windows Updates have been installed.


- Install the CTA suite of programs via the installer.exe
- Copy unattend.xml from Server to C:\Windows\System32\Sysprep\unattend.xml
- Run (C:\Windows\System32\Sysprep\) Sysprep.exe with the following settings:
- System Cleanup Action: Enter System Out-Of-Box Experience
    - Generalize: checked
    - Shutdown options: shutdown

- Set VM to boot over the network to the Windows Setup 
- Once into Windows setup, press Shift+F10 to get a command prompt.
- Run `net use z: \\$WDS-Server-IP\REMINST /user:Administrator` to set the Setup Environment to use the WDS Server as network share.
- Change working directory to the z: drive (`z:`)
- Run `dism /Capture-Image /ImageFile:NameOfCustomImage.wim /CaptureDir:C:\ /Name:"Name of Custom Image for WDS" /ScratchDir:z:\ /CheckIntegrity /Verify`

### Step 3 - Back on the Windows Server:

- Verify new custom image exists in the C:\RemoteInstall\ folder.
- Open up Windows Deployment Services
- Expand Servers > WinServer > Install Images
- Right click on corresponding Image Group and Add Install Image selecting the newly created custom image.
- Right click on the custom image and edit properties:
    - Check "Allow image to install in unattended mode".
    - Select the unattend.xml file used and apply to image.

You'll now have a new entry in the list of Windows versions when [Installing Windows from WDS](#installing-windows-from-wds)

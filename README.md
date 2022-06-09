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
- Setting up Windows Server
- Setting up Windows Deployment Service (WDS)
- Installing Windows from WDS
- Creating a custom Window Image and adding it to WDS

## Setting up Windows Server

...
- Install Assessment and Deployment Toolkit

## Setting up Windows Deployment Service (WDS)

## Installing Windows from WDS

## Creating a custom image

- Start with a fresh install of Windows 10 (see ## Installing Windows from WDS)
- On Windows Server:
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
            - amd64_Microsoft-Windows-Setup > UserData, right click and add to Pass 1.
            - amd64_Microsoft-Windows-Shell-Setup > OOBE, right click and add to Pass 7.
            - amd64_Microsoft-Windows-Shell-Setup > UserAccounts, right clicj and add to Pass 7.
        - Under the Answer File view:
                - Select the UserData entry and set the AcceptEula property to True. (This skips having to accept the EULA on the first boot up.)
		- Select the OOBE entry and set the following properties:
                    - HideEULAPage: true                        (Skips EULA
                    - HideOEMRegistrationScreen: true           (Skips
                    - HideOnlineAccountScreen: true             (Skips 
                    - HideWirelessSetupInOOBE: true             (Skips
                    - NetworkLocation: home                     (Sets 
                    - SkipMachineOOBE: true                     (Skips
                    - SkipUserOOBE: true                        (Skips
                - Expand OOBE entry, right click and delete VMModeOptimisations
                - Expand UserAccounts entry:
                    - Set AdministratorPassword
                    - Delete DomainAccounts
                    - Right click LocalAccounts and insert new LocalAccount
                    - Set the new LocalAccount properties:
                        - Description: User
                        - DisplayName: User
                        - Name: User
                    - Expand LocalAccount, select Password entity and set the value property to set the user's password.
        - Save file as unattend.xml
- On fresh install of Windows 10:
   - Go through the OOBE to get to the desktop  
   ...
   - Open command prompt as admin and run `net user administrator /active:yes` to enable the Administrator account.
   - Right click on the start menu and sign out
   - Sign in as Administrator
   - Open Control Panel > User Accounts > Manage Accounts
   - Select User, then delete User and remove files.
   - Install the CTA suite of programs via the installer.exe
   - Copy unattend.xml from Server to C:\Windows\System32\Sysprep\unattend.xml
   - Make sure any pending Windows Updates have been installed.
   - Run (C:\Windows\System32\Sysprep\) Sysprep.exe and select:
      - System Cleanup Action: Enter System Out-Of-Box Experience
      - Generalize: checked
      - Shutdown options: shutdown


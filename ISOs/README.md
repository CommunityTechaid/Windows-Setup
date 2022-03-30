# CTA Installation ISO

These are the steps taken to create a USB installer that can be used to install Window 10 and the CTA suite of programs in one, as well as create the default user.

Instructions are based on using `virt-manager` on Arch Linux, although they should be reasonably universal. A source of useful information in regards this process is https://www.tenforums.com/tutorials/72031-create-windows-10-iso-image-existing-installation.html, with the process largely following the "Part Two" section to allow for the pre-created default user account.

## Steps

- Download latest Windows 10 ISO (https://www.microsoft.com/en-gb/software-download/windows10ISO), multi-edition, English International, 64-bit

- Create a VM:
    - Select Local install media
    - Set CDROM to Windows 10 ISO
    - Set specs for virtual machine (eg. 2 cores, 4GB RAM)
    - Enable storage for the virtual machine and create a virtual disk of at least 50GB.
    - Finalise setup and start VM.

- Install Win10 in VM by following the ISO's installer.

- Disable network. (Bypasses requirement for a Microsoft account, allowing creation of a local user)
    - View details > NIC > Link state > Apply

- Boot into Windows 10 and follow the OOBE setup:
    - Region: UK
    - Keyboard: UK
    - Username: user
    - Password & Reminder questions: as docs
    - Cortana: not now

- Reenable network

- Check for updates and restart as required

- Install CTA program. Latest version will be in CTA Tech shared Google Drive folder.

(A quick way to get the installer onto the VM is to run the following when the VM is off:

```zsh
sudo virt-copy-in -a /path/to/vm/image.qcow2 /path/to/CTA/installer.exe /
```
This will copy the .exe to the root of C:\.
)

- Delete the installer and empty the recycling bin.

- Run Disk Clean-up as admin and remove as much as possible.

- Open Disk Management:
    - Shrink C:\ as much as possible.
    - Create new partition with new space.
    - Label new partition as Image
    - Label C:\ as Windows
    - Create folder "Scratch" in the new partition.

- Shutdown VM.

- Set VM to boot from ISO
    - View > Details > Boot Options > Enable CDROM and move to top of the list
    - Apply

- Boot to ISO

- Press shift+F10 to open command prompt

- Run `diskpart`
    - `list vol`
    - Note letters associated with Image and Windows partitions from earlier

- Run `dism /capture-image /imagefile:D:\install.wim /capturedir:E:\ /ScratchDir:D:\Scratch /name:"CTA" /compress:maximum /checkintegrity /verify /bootable`
(where D and E are the letters associated with the Image and Windows partitions respectively)

- Wait. Patiently.

- Whilt waiting, remove the CDROM from the boot options.

- Reboot into Windows 10 proper.


[#Crack on from part five]
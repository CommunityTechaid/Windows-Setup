# Windows 11
## ISO


## VM
### TPM Emulation package
Make sure that `swtpm` is installed (to emulate TPM chips) and `ovmf` is up-to-date (to have the latest UEFI firmware for VMs)

```sudo apt update && sudo apt install swtpm ovmf```

### VM Creation
Create new VM following the "Create a new virtual machine" dialog in Virtual Machine Manager, selecting "Local install media" and then pointing to the Windows 11 .iso that you've downloaded. It should detect that you're trying to create a Window 11 machine and select sane default settings.

Before finishing, check the "Customise configuration before install" box. This will bring up the VM overview box.

In the left hand pane, select the "TPM vNone" entry. Change the advanced options to:
	Type: Emulated
	Model: TIS
	Version: 2.0

In the left hand pane, select the "NIC:..." entry. Toggle the link state so that is is inactive.

Click "Apply" in the bottom right to save the changes, and then click "Begin Installation" in the top left to create the VM and start the installation process.

## Installation

## Customisation

## Image creation
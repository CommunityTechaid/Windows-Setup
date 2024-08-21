# Windows Server
- Install Spice Guest Tools for better VM / Host integration (eg. auto-sizing of Windows screen to match VM window). [www.spice-space.org/download.html]
- Install Firefox.
	- and UBlock Origin extension
- Install ADK
	- Deselect User State Migration
	- Deselect MS User Experience
	- Deselect Windows Performance Toolkit
	- Deselect Supply chain trust tool
	(Only have Deployment tools and configuration designer selected)
- Install ADK PE add on
- Install Microsoft Deployment Toolkit (MDT)
- Change hostname
	Server Manager > Local Server > Computer Name > Change

# WDS Set up
 - Add role
 - Get .iso
 - Mount .iso and copy boot.wim somewhere safe.
 - Open WDS, expand server and configure choosing these options:
 	Standalone server
 	Respond to all client computers (known and unknown)
 	Uncheck add images to server now.
 - Right click Boot Images > Add Boot Image:
 	- Browse to the location of the boot.wim from the .iso and select it
 	- Next (Accept default name and description)
 	- Next (Accept summary)
 	- Finish
 - Right click on new boot image and disable. (Only needed to add a few files and as back up.)


# MDT Set up
 - Open Deployment Workbench
 - Right click on deployment shares > New Deployment share:
 	- Next (Accept default share path)
 	- Next (Accept default share name)
 	- Next (Accept default share description)
 	- Uncheck "Ask if a computer backup should be performed"
 	- Uncheck "Ask if an image should be captured"
 	- Next
 	- Next (Accept summary)
 	- Finish
 - Right click on MDT Deployment Share > Properties:
 	- Uncheck x86 support.
 - Copy C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\amd64 to ...\x86. (Prevents some lock ups and issues generating images.)
 - Open file explorer. Navigate to C:\ then right click on DeploymentShare and select properties > advanced sharing > permissions > add > Everyone then make sure Everyone has read access.
 - Right click on Deployment Share > Update Deployment Share:
 	- Completely regenerate image
 	- Next (Accept summary)
 	- Finish

## Add MDT boot image to WDS
 - Open WDS, expand Windows Sever, right click Boot Images > Add Boot Image:
 	- Browse to the deployment share boot folder (C:\DeploymentShare\Boot) and select the .wim
 	- Next (Accept default name and description)
 	- Next (Accept summary)
 	- Finish


## Add OS to MDT
 - Expand deployment share, right click on Operating Systems > Import OS:
 	- (Make sure .iso is mounted)
 	- Full set of source files
 	- Select .iso mount point
 	- Accept destination name
 	- Accept summary
 	- Finish
 - Right click on Task Sequences > New Task Sequence:
 	- Enter task details:
	 	- Task sequence ID: Deploy$OSVersion
	 	- Task sequence name: Deploy$OSVersion
	 	- Task sequence comments: DeployOSVersion
 	- Select "Standard Client Task Sequence"
 	- Select OS to install (Windows Home)
 	- Chose "Do not specify a product key at this time.
 	- Specify basic OS settings:
 		- Username: User
 		- Organisation: Community Techaid
 	- Specify password
 - Right click on Deployment Share > Update Deployment Share:
 	- Completely regenerate image
 	- Next (Accept summary)
 	- Finish

!!! ADD Bootstrap.ini info !!!
!!! Add customsettings.ini / rules !!!


## Use MDT to Install Windows
 - PXE boot
 - Blahhh


## OSDBuilder

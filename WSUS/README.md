# CTA WSUS Details

WSUS (Windows Server Update Service) is a service that runs on an instance of Windows Server that allows the administration and cacheing of Microsoft Updates within a local / corporate network.

The reason for CTA to se it is so that often used updates can be cached and accessible over the local network so devices to speed up download times.

Typically WSUS would be set up within a domain using group policy etc. To avoid this we change some registry settings to point at the server for set up and then remove the registy settings once completed.

## Server set up

- Install Windows Server

- Config local server
    - check for updates

- Manage local server
    - add roles & feature wizard
        - check Windows deployment
        - checkWindows server update services
        - create folder to store updates locally
        - follow dialogue and install

- Restart

- Follow complete WSUS installation dialogue
    - Select Windows 10 related options under products
    - Select just English under languages

- Verify WSUS settings
    - Tools > Windows Server Update Service
    - Expand Server in left hand pane > Options:
        - Update source: Mircosoft
        - Proxy server: none
        - Products: Windows 10...
        - Classifications: TBD (Crit, security, definitions)
        - Update files: Store locally, optionally select download express files
        - Update languages: English
        - Synchronization schedule: Manually (for the inital sync)

- Start inital sync with Microsoft. This will take a while. Several hours.
(started 1030)


## Usage

- run wsus-client.reg on machine to make registry changes
- run windows update as normal
- once complete, run remove-wsus-client.reg to remove changes
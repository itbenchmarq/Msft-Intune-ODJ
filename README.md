# Purpose
Provide an automated method to add machines via Offline Domain Join and Direct Access.

## Microsft's Offline Domain Join (ODJ) typically requires numerous steps.
**These include the following:**
1.  Running a DJoin script to adding the machine to the domain.
2.  This outputs a file (TXT or DAT) to be used when offline domain joining the endpoint.
3.  Copy-Paste the outputed file to the endpoint.
4.  Run script to ODJ with the ingestion of the script from Step 2.

With the inclusion of Step 3, this becomes a manual task.  

!! This script aims to Remove Step 3 by uploading a list of DJoin outputs to Github and having the script dynamically grab 
it's respective file to attempt Step 4.

## Tasks Required
1.  Generate a list of computers to add to the domain in a list TXT format. 
2.  Login to a Domain Controller and Open a Powershell Window as Admin
3.  Run 'New-DAComputerObject.ps1' in order to ingest the Function into the current environment.
    Note: You will have to run New-DAComputerObject once, then it will be created as a function and should be consumable.
4.  Run the 'New-DAComputerObject' function with the required parameters specified ('domain' and 'filename' for computer list)
5.  Note the output location of the resulting script should 'C:\temp\'.  
    A file will be generated with each computer name specified in the computer list.

6.  Login to an endpoint you'd like to add with a local administrator account.
7.  Open a Powershell Windows as Admin, Run 'Set-DAOfflineJoin.ps1'
8.  Run 'Set-DAOfflineJoin' function with the required domain parameter.
9.  The machine should now be ready for reboot and be offline joined to the domain as well as connected to Direct Access.


## Pre-Requisities
1.  Direct Access properly setup via https://learn.microsoft.com/en-us/windows-server/remote/remote-access/directaccess/single-server-wizard/da-basic-configure-s2-server
2.  Certificate for ODJ "Direct Access Client Settings"
3.  Github Repo and Access token setup


## Possible Issues
1.  Certificate for Direct Access not specified correctly.

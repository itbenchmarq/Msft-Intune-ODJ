<#####################################################
######## Purpose: Copy files to other VDIs############
######################################################>
<#
       .Synopsis
          Script meant to ingest list of computers and create respective Offline Domain Join for Direct Access
       .DESCRIPTION
          Script meant to ingest list of computers and create respective Offline Domain Join for Direct Access.
          Files will be output to C:\temp directory.
       .EXAMPLE
          New-DAComputerObject -domain local.acme.com -filename 'C:\temp\computerlist.csv'

       #>
       function New-DAComputerObject
       {
           [CmdletBinding()]
           [Alias()]
           [OutputType([int])]
           Param
           (
               # Param1 help description
               [Parameter(Mandatory=$true,
                          ValueFromPipelineByPropertyName=$true,
                          Position=0)]
               $domain,
       
               # Param2 help description
               [string]
               $filename


           )



           #Browse for CSV File
           If ($filename -eq $null) {
               $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
                InitialDirectory = [Environment]::GetFolderPath('Desktop') 
                Filter = 'CSV (*.csv)|*.csv|Text (*.txt)|*.txt'
                }
                $null = $FileBrowser.ShowDialog()

                $FileBrowser = $FileBrowser.FileName
                }
           Else {
                $filebrowser = $filename
                }
           
           $machinenames = @{}
           $machinenames = Get-Content -Path $FileBrowser

           Foreach ($machine in $machinenames) {
               Try
               {
               $machine = $machine.ToLower()
               $outputpath = ('C:\temp\' + $machine + '.txt')
               Write-Host "$machine : Step 1 - Attempting offline domain join."
               Djoin /provision /domain $domain /machine $machine /policynames "DirectAccess Client Settings" /rootcacerts /savefile $outputpath /reuse
               Write-Host "$machine : Step 2 - Successful creation of ODJ file in C:\temp."
               }
               Catch
               {
               Write-Host "$error"
               }
            }
           
       }

#New-DAComputerObject -domain local.acme.com -filename 'C:\temp\computerlist.txt'
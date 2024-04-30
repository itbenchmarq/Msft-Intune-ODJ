<#
.Synopsis
   Script designed to Offline Domain Join machine from an output TXT file from the local AD server.
   To be ran on the endpoint attempting domain join
.DESCRIPTION
   Checks Win10 Enterprise License is applied. Then downloads file from Github to ODJ.
.EXAMPLE
   Set-DAOfflineJoin -domain corp.acme.com -Win10EntKey NPPR9-FWDCX-D2C8J-H872K-2YT43
   The key used in this example is for KMS installs only.
.EXAMPLE
   Set-DAOfflineJoin -domain corp.acme.com
   Domain is the only required parameter
#>

<#Required Variables
$token - Github Token is $token.  Will need to be generated from Github account.
$username - Github user if using a Github user repo will be need to be identified.
$repo - Github repo name

#>

function Set-DAOfflineJoin
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)][string]
        $domain,

        # Param2 help description
        [string]
        $Win10Entkey
    )
    
    #Section for Windows 10 Enterprise check and insatll if not installed.
    $Win10Test = (Get-ComputerInfo).OsName
    If ($Win10Test -match 'Enterprise') 
        {
        Write-Host "Windows 10 Enterprise license already installed." -ForegroundColor Green
        }
    Else {
        Write-Host "Windows 10 Enterprise license needed."
        If ($Win10Entkey -ne $null) {
            
            Try {
                slmgr.vbs /ipk $Win10Entkey
                }
            Catch {
                "$Error"
                }
            }
        Else {Write-Host "No Windows 10 Enterprise key specified."}
        }


    #Verify if machine is domain joined.    
    If ((Get-ComputerInfo).CsDomain -ne $domain) {
        Write-Host "Machine not part of the specified domain: $domain"
        #Section to Check GitHub for Offline Domain Join file
        
        Try
            {
            $token = "github_pat_ENTER_ME"
            $username = "USERNAME_PLEASE"
            $repo = "REPO_NAME"
            #$filePath = "<PATH_TO_FILE>"
            $filePath = (Get-ComputerInfo).CsName.ToLower()
            $filePath = ($filePath + '.txt')
            $apiUrl = "https://api.github.com/repos/$username/$repo/contents/zipball/main"
            $gitzip = ("https://api.github.com/repos/" + $username + "/" + $repo + "/zipball/main")
            $ziplocation = ('C:\temp\' + $repo + '.zip')
            $unzip = ('C:\temp\' + $repo)
           
            #Invoke-RestMethod -Uri $gitzip -Headers $headers -OutFile c:\temp\DAFiles.zip

            # Create a basic authentication header using the personal access token
            $headers = @{
                Authorization = "Bearer $token"
                Accept = "application/vnd.github+json"
                #Accept = "application/vnd.github.v3.raw" used for downloading individual file
            }

            #Download repo

            Invoke-RestMethod -Uri $gitzip -Headers $headers -OutFile $ziplocation

            <#
            # Make a request to the GitHub API to get the file content
            $response = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
            
            
            # Specify the local path where you want to save the downloaded file
            $custompath = ('C:\temp\' + $filePath)
            $localPath = $custompath

            # Save the file content to the local path
            $response | Out-File -FilePath $localPath -Encoding unicode -NoNewline
            #>

            Write-Host "File downloaded successfully to: $localPath" -ForegroundColor Green

            #Expand Archive and search for file
            Write-Host "Expanding archive.............." -ForegroundColor White
            Expand-Archive -Path $ziplocation -DestinationPath $unzip
            
            #Renaming Directories
            Write-Host "Renaming directories..........." -ForegroundColor White
            $subitem = Get-ChildItem -Path $unzip
            #$subitem[0].Name
            Rename-Item -Path ($unzip + '\' + $subitem[0].name) -NewName Files
            
            #Removing zipped folder
            Write-Host "Removing zipped folder..........." -ForegroundColor Green
            Remove-Item -Path $ziplocation
                        
            }
        Catch {$Error}
        

        #Sectiont to Run Offline Domain Join
        Try 
            {
            #Attempting domain join
            Write-Host "Attempting domain join" -ForegroundColor Green
            $filePath = (Get-ComputerInfo).CsName.ToLower()
            $filePath = ($filePath + '.txt')
            $custompath = ($unzip + '\Files\' + $filePath)
            $localPath = $custompath
            $arguments = ('/requestodj ' + '/loadfile ' + $localpath + ' /windowspath %windir% /localos')
            $arguments = @()
            $arguments += '--%'
            $arguments += '/requestodj'
            $arguments += ('/loadfile ' + $localpath)
            $arguments += ('/windowspath ' + $env:windir)
            $arguments += '/localos'
            #start-process -FilePath C:\windows\system32\djoin.exe -ArgumentList $arguments -wait
            #start-process -FilePath C:\windows\system32\djoin.exe -ArgumentList "--%","/requestodj","/loadfile $localPath","/windowspath %windir%","/localos"
            Djoin /requestodj /loadfile $localpath /windowspath $env:windir /localos
            #djoin --% if getting 0xa9d error
            }
        Catch {$Error}
            
        }
    Else {Write-Host "Machine is already domain joined."}
    Remove-Item $unzip -Recurse
}

#Set-DAOfflineJoin -domain local.acme.com
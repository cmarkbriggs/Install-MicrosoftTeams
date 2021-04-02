﻿<#
.SYNOPSIS
Install-MicrosoftTeams.ps1 - Microsoft Teams Desktop Client Deployment Script

.DESCRIPTION 
This PowerShell script will silently install the Microsoft Teams desktop client.

The Teams client installer can be downloaded from Microsoft:
https://teams.microsoft.com/downloads

.PARAMETER SourcePath
Specifies the source path for the Microsoft Teams installer.

.EXAMPLE
.\Install-MicrosoftTeams.ps1 -Source \\mgmt\Installs\MicrosoftTeams

Installs the Microsoft Teams client from the Installs share on the server MGMT.

.NOTES
Written by: Paul Cunningham

Find me on:

* My Blog:	https://paulcunningham.me
* Twitter:	https://twitter.com/paulcunningham
* LinkedIn:	https://au.linkedin.com/in/cunninghamp/
* Github:	https://github.com/cunninghamp

Change Log
V1.00, 15/03/2017 - Initial version
V1.10, 02/04/2021 - Added commands to launch Teams after installation
#>

#requires -version 4


[CmdletBinding()]
param (

	[Parameter(Mandatory=$true)]
	[string]$SourcePath

)


function DoInstall {

    $Installer = "$($SourcePath)\Teams_windows_x64.exe"

    If (!(Test-Path $Installer)) {
        throw "Unable to locate Microsoft Teams client installer at $($installer)"
    }

    Write-Host "Attempting to install Microsoft Teams client"

    try {
        $process = Start-Process -FilePath "$Installer" -ArgumentList "-s" -Wait -PassThru -ErrorAction STOP

        if ($process.ExitCode -eq 0)
        {
            Write-Host -ForegroundColor Green "Microsoft Teams setup started without error."
        }
        else
        {
            Write-Warning "Installer exit code  $($process.ExitCode)."
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }

}

#Check if Office is already installed, as indicated by presence of registry key
$installpath = "$($env:LOCALAPPDATA)\Microsoft\Teams"

if (-not(Test-Path "$($installpath)\Update.exe")) {
    DoInstall
}
else {
    if (Test-Path "$($installpath)\.dead") {
        Write-Host "Teams was previously installed but has been uninstalled. Will reinstall."
        DoInstall
    }
}

$TeamsApp = "C:\Users\$env:USERNAME\AppData\Local\Microsoft\Teams\Update.exe"

Start-Process -FilePath $TeamsApp -ArgumentList "--processStart ""Teams.exe"" --process-start-args ""--user-initiated"""



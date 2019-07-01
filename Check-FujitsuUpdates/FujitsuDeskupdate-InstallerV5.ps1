<#

.SYNOPSIS
  Install Fujitsu Updates with Ducmd

.DESCRIPTION
  Runs DeskUpdate from command line and returns the amount of found updates.
  
.PARAMETER DeskUpdate
    Path to Ducmd.exe - UNC paths are allowed

.NOTES
  Version:        1.2
  Author:         Sebastian Selig
  Creation Date:  07.08.2018
  Change:         change to version ducmd.exe 5.x 
  
.EXAMPLE
  FujitsuDeskupdate-InstallerV5 -DeskUpdate "C:\Program Files (x86)\Fujitsu Deskupdate\ducmd.exe"

.EXAMPLE
  FujitsuDeskupdate-InstallerV5 -DeskUpdate "C:\Program Files (x86)\Fujitsu Deskupdate\ducmd.exe" -LoggingPath "C:\stdout.log"

  
#>

# ---------------------------------------------------------------------------
# config values
# ---------------------------------------------------------------------------
param( 
    [Parameter(Mandatory=$true,
            Position=0,
            ParameterSetName="DeskUpdate Path",
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Path to location of Ducmd.exe")]
    [Alias("PSPath")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $DeskUpdate,
    [Parameter(Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Logging Path for output from ducmd.exe, must be an local path")]
    [Alias("Logging")]
    [ValidateNotNullOrEmpty()]
    [string[]]
    $LoggingPath
)
# ---------------------------------------------------------------------------
# main program starts here
# ---------------------------------------------------------------------------

# check for Deskupdate
if (! (Test-Path $DeskUpdate) ) 
{
    Write-Error "Deskupdate not found"
    exit 9001
}
else
{
    if($LoggingPath) {
        # run Ducmd with parameters
        & $DeskUpdate /INSTALL /WEB /X  2>&1 > $LoggingPath
        $content = Get-Content $LoggingPath
    } else {
        $content = (cmd /c $DeskUpdate' /INSTALL /WEB /X')
    }
    
    exit $LASTEXITCODE
}
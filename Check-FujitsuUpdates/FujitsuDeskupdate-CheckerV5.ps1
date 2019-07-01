<#

.SYNOPSIS
  Check computer Fujitsu Updates

.DESCRIPTION
  Runs DeskUpdate from command line and returns the amount of found updates.
  
.PARAMETER DeskUpdate
    Path to Ducmd.exe - UNC paths are allowed

.NOTES
  Version:        1.2
  Author:         Sebastian Selig
  Creation Date:  06.08.2018
  Change:         change to version ducmd.exe 5.x 
  
.EXAMPLE
  FujitsuDeskupdate-CheckerV5 -DeskUpdate "C:\Program Files (x86)\Fujitsu Deskupdate\ducmd.exe"

.EXAMPLE
  FujitsuDeskupdate-CheckerV5 -DeskUpdate "C:\Program Files (x86)\Fujitsu Deskupdate\ducmd.exe" -LoggingPath "C:\stdout.log"

  

#>

# ---------------------------------------------------------------------------
# config values
# ---------------------------------------------------------------------------
param( 
    [Parameter(Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            HelpMessage="Path to location of Ducmd.exe")]
    [Alias("DeskUpdatePath")]
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

# check for powershell version
if ($PSVersionTable.PSVersion.Major -lt 4) {
    Write-Error "Powershell Version 4 required"
    exit 9000
}

# check for Deskupdate
if (! (Test-Path $DeskUpdate) ) 
{
    Write-Error "Deskupdate not found"
    exit 9001
}
else
{
    # write output if LoggingPath is set
    if($LoggingPath) {
        # run Ducmd with parameters
        & $DeskUpdate /WEB /LIST  2>&1 > $LoggingPath
        $content = Get-Content $LoggingPath
    } else {
        $content = (cmd /c $DeskUpdate' /WEB /LIST')
    }

    # if success, next step
    if ($LASTEXITCODE -eq 0) 
    {
        # extract only installable packages
        $content = ($content.Where({$_ -like "Installable packages:"}, 'SkipUntil').Trim()) | Select-Object -Skip 1
        
        if ($content.Count -gt 0) {
            # return update available
            Write-Host "Update required $($content)"
            exit 9002
            
        } else {
            # return no update available
            Write-Host "no Update required $($content)"
            exit 9003
        }
    } else {
        # return code deskupdate
        Write-Error "Program terminated with errorcode $($LASTEXITCODE) - check Ducmd.exe /E for more information"
        exit $LASTEXITCODE
    }
}
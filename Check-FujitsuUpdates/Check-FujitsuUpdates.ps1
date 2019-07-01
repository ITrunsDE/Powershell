#requires -version 2
<#

.SYNOPSIS
  Check computer Fujitsu Updates

.DESCRIPTION
  <Brief description of script>

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
  <Inputs if any, otherwise state None>

.OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
  Version:        1.0
  Author:         Sebastian Selig
  Creation Date:  16.05.2018
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>

#>

# ---------------------------------------------------------------------------
# config values
# ---------------------------------------------------------------------------

# Script path
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$ScriptName = ((Get-Variable MyInvocation).Value).MyCommand.Name

$UPDATE_REQUIRED = $false

# ---------------------------------------------------------------------------
# logging 
# ---------------------------------------------------------------------------
$logDir = $scriptPath + "\" + $ScriptName
$logging = $false

if($logging)
{ 
    Start-Transcript "$logDir\$ScriptName.log" 
}

# ---------------------------------------------------------------------------
# main program starts here
# ---------------------------------------------------------------------------

$DUCMD = "\\svinfra02\dip$\Tools\DeskUpdate\ducmd.exe"

# check for Deskupdate
if (! (Test-Path $DUCMD) ) 
{
    Write-Host "Deskupdate not found" -ForegroundColor Red
    exit 99 
}
else
{
    $return = (cmd /c $DUCMD' /WEB /LIST' | findstr "Driver Application Windows")
    
    # if success, next step
    if ($LASTEXITCODE -eq 0) 
    {
        # check for each part
        $return | % {
            if( $_ -match "Driver" )
            {
                if ($_[0] -ne "0")
                {
                    Write-Host "Update required"
                    $UPDATE_REQUIRED = $true
                }
            }
            elseif($_ -match "Application")
            {
                if ($_[0] -ne "0")
                {
                    $UPDATE_REQUIRED = $true
                }
            }
            elseif($_ -match "Windows")
            {
                if ($_[0] -ne "0")
                {
                    $UPDATE_REQUIRED = $true
                }
            }
        }
        if ($UPDATE_REQUIRED) 
        {
            exit 1
        }
        else
        {
            exit 0
        }
    } 
    else 
    {
        exit $LASTEXITCODE
    }
}

if($logging)
{ 
    Stop-Transcript
}
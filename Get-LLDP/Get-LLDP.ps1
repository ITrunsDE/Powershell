#requires -version 2
<#

.SYNOPSIS
  Read LLDP informations 

.DESCRIPTION
  Extract the information from the tcpdump packets

.NOTES
  Version:        1.0
  Author:         Sebastian Selig
  Creation Date:  13.06.2018
  Purpose/Change: Initial script development
  
#>

# ---------------------------------------------------------------------------
# config values
# ---------------------------------------------------------------------------

# Script path
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
$ScriptName = ((Get-Variable MyInvocation).Value).MyCommand.Name
$logDir     = $scriptPath
$TMP_File   = [System.IO.Path]::GetTempFileName()

# change me !!!!!!!!!!!!!!!!
$_tcpdump   = "{DIP}\Tools\tcpdump\tcpdump.exe"
$iniFile    = "{iniFile}"
$MACAddress = "{Client:MAC}"
# change me !!!!!!!!!!!!!!!!

# ---------------------------------------------------------------------------
# main program starts here
# ---------------------------------------------------------------------------
Start-Transcript "$logDir\$ScriptName.log"

# check if tcpdump.exe is there
if(! (Test-Path $_tcpdump) )
{
    Write-Error "tcpdump.exe not found in $_tcpdump"
    break
}

# get network adapter
$DeviceID = Get-WmiObject -Query "SELECT * FROM Win32_NetworkAdapterConfiguration" | ? {$_.MACAddress -eq "$MACAddress"} | Select -ExpandProperty SettingID

# run tcpdump
$_tcpdump = start-process -Filepath $_tcpdump -ArgumentList "-i \Device\$DeviceID -nn -v -s 1500 -c 1 (ether[12:2]==0x88cc or ether[20:2]==0x2000)" -PassThru -RedirectStandardOutput $TMP_File

# kill it after 60 seconds
if (!$_tcpdump.WaitForExit(60000))
{
    $_tcpdump.Kill()
}
#================================================================================
#
#     LLDP Switch Informations
#
#================================================================================
Select-String -Pattern "System Name TLV \(5\)" -Path $TMP_File | % {
    $SwitchName = $_.ToString().Split(":")
    $SwitchName = $SwitchName[-1].ToUpper().Trim()
    Write-Host "System Name found: $SwitchName"
}

# switch port
Select-String "Port ID TLV (2)" $TMP_File -Context 0, 1 -SimpleMatch | % {
    $Port1 = $_.Context.PostContext.split(":")
    $Port1 = $Port1[-1].ToString().Trim()
    Write-Host "Port: $port1"
}

# switch port
Select-String -Pattern "Port Description TLV \(4\)" -Path $TMP_File | % {
    $Port2 = $_.ToString().Split(":")
    $Port2 = $Port2[-1].ToUpper().Trim()
    Write-Host "Port: $Port2"
}

# vlan id
Select-String -Pattern "port vlan id \(PVID\)" -Path $TMP_File | % {
    $VLAN = $_.ToString().Split(":")
    $VLAN = $VLAN[-1].ToUpper().Trim()
    Write-Host "VLAN ID: $VLAN"
}

# switch description
Select-String -Pattern "System Description TLV \(6\)" -Context 0,1 -Path $TMP_File | % {
    $model = $_.ToString().Split(":")
    $model = $model[-1].ToUpper().Trim()
    Write-Host "Switch Model: $model"
}

# clean up
Remove-Item $TMP_File -Force -ErrorAction SilentlyContinue
if (Get-Process -Name "tcpdump.exe" -ErrorAction SilentlyContinue)
{
    Stop-Process -Name "tcpdump.exe" -Force -ErrorAction SilentlyContinue
}

# save to ini file
if ( Test-Path $iniFile) 
{
    "[switch]"            | Add-Content -Path $iniFile -Force
    "name=$($SwitchName)" | Add-Content -Path $iniFile -Force
    "model=$($model)"     | Add-Content -Path $iniFile -Force
    "vlan=$($VLAN)"       | Add-Content -Path $iniFile -Force
    "port1=$($port1)"     | Add-Content -Path $iniFile -Force
    "port2=$($port2)"     | Add-Content -Path $iniFile -Force
    ""                    | Add-Content -Path $iniFile -Force
    "[debug]"             | Add-Content -Path $iniFile -Force
    "logfile=$logDir\$ScriptName.log"     | Add-Content -Path $iniFile -Force
}

# stop logging
Stop-Transcript
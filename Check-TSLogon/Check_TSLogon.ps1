##########################################################
#
#     Program Informations:
#     ---------------------
#     Program: Check-TSLogon.ps1
#     Autor  : Sebastian Selig
#     Created: 30.06.2017
#     Version: 0.1
#
#     Program Description:
#     --------------------
#     Check the status if a user can connect to a terminalserver.
#
#     Version History:
#     ----------------
#
#     Version 0.1 (30.06.2017):
#       * Inital Version
#
##########################################################
param(
    [string]$ComputerName = "localhost"
)

$result = "<prtg>`r`n"
$result+= "  <result>`r`n"
$result+= "    <channel>Status</channel>`r`n"

# get the config
gwmi -Namespace “root\cimv2\TerminalServices” -Class Win32_TerminalServiceSetting -ComputerName $ComputerName| %{
   if ($_.logons -eq 1){
      $result+= "    <value>3</value>`r`n"
      $Message = "Disabled"
   } Else {
      $result+= "    <value>$($_.sessionbrokerdrainmode)</value>`r`n"
      switch ($_.sessionbrokerdrainmode)
      {
         0 {$Message = "Enabled"}
         1 {$Message = "DrainUntilRestart"}
         2 {$Message = "Drain"}
         default {$Message = "Error"}
      }
   }
}
# $result+= "    <mode>Absolute</mode>`r`n"
$result+= "  </result>`r`n"
$result+= "<Text>$($Message)</Text>"
$result+= "</prtg>`r`n"
# 
$result
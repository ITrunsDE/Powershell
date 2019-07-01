##########################################################
#
#     Program Informations:
#     ---------------------
#     Program: Check-Folder.ps1
#     Autor  : Sebastian Selig
#     Created: 22.08.2016
#     Version: 0.2
#
#     Program Description:
#     --------------------
#     Count files and check the oldest file.
#
#     $path = "\\orbis\public\RpDoc\Befunde|*.hl7|4;\\orbis\public\RpDoc\Patienten|*.pdf|15;"
#
# 
#     Version History:
#     ----------------
#
#     Version 0.2 (20.09.2016):
#       # Problem with $ in network Path, replaced # with $
#
#     Version 0.1 (22.08.2016):
#       * Inital Version
#
##########################################################
param(
    [string]$CheckPath = "N/A"
)
# Result
$result = "<prtg>`r`n"
$CheckPath = $CheckPath.Replace("#","$")

# Check path
$CheckPath.Split(";") | % {
    
    # Check if we got something to check
    if($_) {
        
        # split the entry
        $entry = $_.Split("|")
        
        #Write-Host "Check Path: $($entry[0])"
        if($entry[1]) {
            # if time is available, if not, just count the directory
            if(!($entry[2])) {
                $Value = Get-ChildItem -LiteralPath "$($entry[0])" -Filter $entry[1]
            } else {
                $Value = Get-ChildItem -LiteralPath "$($entry[0])" -Filter $entry[1] | ? {$_.CreationTime -lt (Get-Date).AddMinutes($entry[2])}
            }            
        } 
        # Measure the result
        $ValueC = $Value | Measure-Object
        $result+= "  <result>`r`n"
        $result+= "    <channel>$($entry[0])</channel>`r`n"
        $result+= "    <value>$($ValueC.Count)</value>`r`n"
        $result+= "    <mode>Absolute</mode>`r`n"
        $result+= "  </result>`r`n"

    }
    
}

$result+= "</prtg>`r`n"
# 
$result
##########################################################
#
#     Program Informations:
#     ---------------------
#     Program: CleanUp-WSUS.PS1
#     Autor  : Sebastian Selig
#     Created: 25.09.2016
#     Version: 0.1
#
#     Program Description:
#     --------------------
#     CleanUp WSUS Server
# 
#     Version History:
#     ----------------
#
#     Version 0.1 (25.09.2016):
#       * Inital Version
#
##########################################################
# Script path
$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition
##########################################################

Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles -DeclineExpiredUpdates -DeclineSupersededUpdates
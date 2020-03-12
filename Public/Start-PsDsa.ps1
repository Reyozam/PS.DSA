#===============================================================================================================
# Language     :  PowerShell 5.0
# Filename     :  PS-DSA.ps1
# Autor        :  Julien Mazoyer
# Description  :  Cli GUI for daily AD tasks
# Version      :  0.1
#===============================================================================================================
<#
    .SYNOPSIS
    
    .DESCRIPTION 
    Cli GUI for daily AD tasks
    
    .EXAMPLE
        
    .EXAMPLE
    
    .LINK
    
#>

function Start-PsDsa 
{

    [CmdletBinding()]
    param (
        [Parameter(Position = 1)][string]$User
    )
    
    # USER DEFINED VARIABLES ==========================================================================================
    # Edit these variables as needed

    # STATIC VARIABLES ================================================================================================
    $Global:PDC = Get-PDC

    # HELPERS FUNCTIONS ===============================================================================================


    # SCRIPT LOGIC ====================================================================================================
    #Start User Lookup
    if ([string]::IsNullOrEmpty($User))
    {
        Write-Color "Search AD User /> " -Color $Color -NoNewLine
        $User = Read-Host
        $Identity = SearchUserAccountName $User
    }
    else
    {
        $Identity = SearchUserAccountName $User
    }
    
    $Global:PSDSA_User = [PSDSAUser]::new($Identity)
    
    ShowUserScreen -ShowHeader -ShowScreen -ShowMenu

    

    # END  ============================================================================================================

}

New-Alias -Name ad -Value Start-PsDsa -Scope global -ErrorAction SilentlyContinue
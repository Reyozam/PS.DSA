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

function Start-PSDSA
{

    [CmdletBinding()]
    param (
        [Alias("u")]
        [Parameter(Position = 0)][string]$User,
        [Alias("d")]
        [Parameter(Position = 1)][string]$Domain = $env:USERDOMAIN
    )
    
    # USER DEFINED VARIABLES ==========================================================================================
    # Edit these variables as needed

    # STATIC VARIABLES ================================================================================================
    $Global:PDC = Get-PDC -Domain $Domain

    # HELPERS FUNCTIONS ===============================================================================================


    # SCRIPT LOGIC ====================================================================================================
    #Start User Lookup
    $Global:PSDSA_User = $null

    if (-not ($User))
    {
        Show-UI -ShowHeader
        
        Write-Color "[!] No user information provide" -Color DarkYellow -LinesBefore 1 -LinesAfter 1
        Write-Color -Text "command: ", "ad -u <search>" -Color green, White -LinesAfter 1
    }
    else
    {
        Show-UI -ShowHeader
        $SamAccountName = Search-User $User

        if ($SamAccountName) 
        {
            $Global:PSDSA_User = New-Object PSDSAUser($SamAccountName,$Global:PDC) -ErrorAction Stop
    
            Show-UI -ShowHeader -ShowScreen -ShowMenu
        }
        else
        {
            Write-Color "[!] No user found for `"$USer`"" -Color DarkYellow -LinesBefore 1 -LinesAfter 1
        }
        
    }
    
    # END  ============================================================================================================

}

New-Alias -Name ad -Value Start-PsDsa -Scope global -ErrorAction SilentlyContinue

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

function Invoke-PSDSA
{

    [CmdletBinding()]
    param (
        [Alias('u')]
        [Parameter(Position = 0)][string]$Identity,
        [Alias('d')]
        [Parameter(Position = 1)][string]$Domain = $env:USERDNSDOMAIN,
        [Parameter()]
        [ValidateNotNull()]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    # USER DEFINED VARIABLES ==========================================================================================
    # Edit these variables as needed

    # STATIC VARIABLES ================================================================================================
    $PDC = Get-ADDomain -Server $Domain | Select-Object -ExpandProperty PDCEmulator

    # USER ====================================================================================================
    #Start User Lookup
    $Global:PSDSA_User = $null

    if (-not ($Identity))
    {
        Show-UI -ShowHeader

        Write-Color '[!] No user specify' -Color DarkYellow -LinesBefore 1 -LinesAfter 1
        Write-Color -Text 'command: ', 'ad [-u] <search>' -Color green, White -LinesAfter 1
    }
    else
    {
        Show-UI -ShowHeader
        $SearchResult = Search-UserADAccount -Search $Identity -Server $PDC

        if ($SearchResult.count -eq 1)
        {
            $Global:PSDSA_User = New-Object PSDSA_User($SearchResult.SamAccountName, $Global:PDC) -ErrorAction Stop
            if ($null -ne $Credential.UserName) { $Global:PSDSA_User.CommandsParam.Add('Credential', $Credential) }
            Show-UI -ShowHeader -ShowScreen -ShowMenu
        }
        elseif ($SearchResult.count -gt 1)
        {
            Show-UI -ShowHeader
            $UserChoiceMenu = @{}

            $SearchResult | ForEach-Object {

                $UserChoiceMenu.Add("[$($_.SamAccountName)] $($_.Name)", $_.SamAccountName)
            }

            Write-Color 'Select a user:' -LinesBefore 1 -Color Green
            Write-Host ''
            $Index = Write-Menu @($UserChoiceMenu.Keys)


            $Global:PSDSA_User = New-Object PSDSA_User($UserChoiceMenu[$Index], $Global:PDC) -ErrorAction Stop
            if ($null -ne $Credential.UserName) { $Global:PSDSA_User.CommandsParam.Add('Credential', $Credential) }
            Show-UI -ShowHeader -ShowScreen -ShowMenu
        }
        else
        {
            Write-Color "[!] No user found for `"$Identity`"" -Color DarkYellow -LinesBefore 1 -LinesAfter 1
        }

    }

    # END  ============================================================================================================

}

New-Alias -Name ad -Value Invoke-PsDsa -Scope global -ErrorAction SilentlyContinue



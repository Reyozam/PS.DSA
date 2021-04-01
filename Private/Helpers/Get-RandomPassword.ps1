function Get-NewPassword
{
    <#
.SYNOPSIS
    Generate Password
.DESCRIPTION
    Generate Password
.PARAMETER Lenght
    Password Length
.PARAMETER Include
    Characted to include
.EXAMPLE
    New-Password -length 20 -include UpperCase,LowerCase, Numbers
#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, Position = 0)][ValidateRange(2, 100)][Int32]$Length = 12,
        [Parameter(Mandatory = $false, Position = 1)][ValidateSet('UpperCase', 'LowerCase', 'Numbers', 'SpecialCharacters')]
        [String[]]$Include = @('UpperCase', 'LowerCase', 'Numbers', 'SpecialCharacters')
    )

    Begin { }

    Process
    {
        Write-Verbose "Generate-Password: Input: Length  = $Length"
        Write-Verbose "Generate-Password: Input: Include = $($Include -join ', ')"

        Remove-Variable MyRange -ErrorAction SilentlyContinue | Out-Null
        $Include | % {
            if ($_ -eq 'UpperCase')
            {
                $MyRange += 65..90
                Write-Verbose 'Generate-Password: MyRange: +UpperCase'
            }
            if ($_ -eq 'LowerCase')
            {
                $MyRange += 97..122
                Write-Verbose 'Generate-Password: MyRange: +LowerCase'
            }
            if ($_ -eq 'Numbers')
            {
                $MyRange += 48..57
                Write-Verbose 'Generate-Password: MyRange: +Numbers'
            }
            if ($_ -eq 'SpecialCharacters')
            {
                $MyRange += (33..47) + (58..64) + (91..96) + (123..126)
                Write-Verbose 'Generate-Password: MyRange: +SpecialCharacters'
            }
        }
        ($MyRange | Get-Random -Count $Length | % { [char]$_ }) -join ''
    }

    End { }

}
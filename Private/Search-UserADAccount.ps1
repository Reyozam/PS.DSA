function Search-UserADAccount
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Alias("User", "UserName", "SamAccountName", "Name")]
        [string]$Search,
        [string]$Server = $env:USERDNSDOMAIN
    )

    try
    {
        $Found = Get-ADUser $Search -Server $Server
        return $Found
    }
    catch
    {
        $Lookup = "*" + $Search + "*" -replace " ", "*"
        $Found = Get-ADUser -Filter { (SamAccountName -like $Lookup) -or (Name -like  $Lookup) } -Server $Server

        return $Found

    }
}


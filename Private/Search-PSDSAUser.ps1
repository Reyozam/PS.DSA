function SearchUserAccountName
{
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true)]
        [Alias("User", "UserName", "SamAccountName", "Name")]
        [string]$Search
    )
    
    try 
    {
        $Found = Get-ADUser $Search -Properties *, msDS-UserPasswordExpiryTimeComputed -ErrorAction Stop -Server $Global:PDC
        return $Found.SamAccountName
    }
    catch
    {
        $Lookup = "*" + $Search + "*" -replace " ", "*"
        $Found = Get-ADUser -Filter { (SamAccountName -like $Lookup) -or (Name -like  $Lookup) } -Properties *, msDS-UserPasswordExpiryTimeComputed -Server $Global:PDC

        If (@($Found).Count -gt 1)
        {
            $List = $Found | Select-Object DisplayName,SamAccountName
            
        }

        $i=1
        $List | ForEach-Object {
            Write-Color "[$i] ",$_.SamAccountName, "`t$($_.DisplayName)" -Color Green,White,White
            $i++
        }

        $Choice = $null
        do {
            Write-Color "Select User/> " -NoNewLine
            $Choice = Read-Host 
        } until ($Choice -ge 1 -AND $Choice -le $i)

        return $List.SamAccountName[$Choice - 1]
    }
}


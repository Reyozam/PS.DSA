function Search-UserADAccount
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
        $Found = Get-ADUser -Filter { (SamAccountName -like $Lookup) -or (Name -like  $Lookup) } -Server $Global:PDC

        If (@($Found).Count -gt 1)
        {
            $UserChoiceMenu = @{}
            
            $Found | ForEach-Object {
                
                $UserChoiceMenu.Add("[$($_.SamAccountName)] $($_.Name)",$_.SamAccountName)
            }

            Write-Color "Select a user:" -LinesBefore 1 -Color Green
            Write-host ""
            $Index = Write-Menu @($UserChoiceMenu.Keys)

            return $UserChoiceMenu[$Index]
        }
    }
}


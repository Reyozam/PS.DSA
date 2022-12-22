#USER MENU STRUCTURE
$Menu = [ordered]@{

    "Show All Attributes" = { Show-UI -ShowHeader ; Write-TitleBar "All attributes" -Width $Config.Width ; $Global:PSDSA_User.ShowAllAttributes() ;  Wait }
    "Get User Groups"     = { Show-UI -ShowHeader ; Write-TitleBar "Groups Membership" -Width $Config.Width ; $Global:PSDSA_User.ShowGroups() ; Wait }
    "Reset Password"      = { Show-UI -ShowHeader ; Write-TitleBar "Reset Password" -Width $Config.Width ; $global:PSDSA_User.ResetPassword($Config.PasswordLength) ; Wait  }

}

if ($PSDSA_User.Properties.Enabled -eq $true)
{
    $Menu.Add("Disable Account",{$PSDSA_User.DisableAccount() ; Show-UI -ShowHeader -ShowScreen -ShowMenu})
}
else
{
    $Menu.Add("Enable Account",{$global:PSDSA_User.EnableAccount() ; Show-UI -ShowHeader -ShowScreen -ShowMenu})
}

if ($PSDSA_User.Properties.LockedOut -eq $true)
{
    $Menu.Add("Unlock Account",{$global:PSDSA_User.Unlock() ; Wait})
}

#$Menu.Add("[#] Search another account" , { Show-UI -ShowHeader ; Write-Host "Enter user to search: " -ForegroundColor Green -NoNewline ; $Search = Read-Host ; Invoke-PSDSA -Identity $Search -Domain $global:PSDSA_User.Domain  } )
$Menu.Add("[@] Refresh" , { $global:PSDSA_User.Reload() ; Show-UI -ShowHeader -ShowScreen -ShowMenu  } )
$Menu.Add("[x] QUIT",{ break })

return $Menu
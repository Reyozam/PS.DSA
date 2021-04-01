#USER MENU STRUCTURE
$Menu = [ordered]@{

    "Show All Attributes" = { Show-UI -ShowHeader ; Write-TitleBar "All attributes" -Width $Config.Width ; $Global:PSDSA_User.ShowAllAttributes() ; Wait }
    "Get User Groups"     = { Show-UI -ShowHeader ; Write-TitleBar "Groups Membership" -Width $Config.Width ; $Global:PSDSA_User.ShowGroups() ; Wait }
    "Reset Password"      = { Show-UI -ShowHeader ; Write-TitleBar "Reset Password" -Width $Config.Width ; $global:PSDSA_User.ResetPassword($Config.PasswordLength) ; Wait  }
}

if ($PSDSA_User.Enabled -eq $true)
{
    $Menu.Add("Disable Account",{$PSDSA_User.DisableAccount() ; Wait})
}
else
{
    $Menu.Add("Enable Account",{$global:PSDSA_User.EnableAccount() ; Wait})
}

if ($PSDSA_User.LockedOut -eq $true)
{
    $Menu.Add("Unlock Account",{$global:PSDSA_UserMainMenu.Unlock() ; Wait})
}

$Menu.Add("Quit",{ break })

return $Menu
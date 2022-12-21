function Show-UI
{
    param (
        [switch]$ShowHeader,
        [switch]$ShowScreen,
        [switch]$ShowMenu
    )

    Clear-Host

    if ($ShowHeader)
    {
        Write-Host " _____ _____   ____  _____ _____        "
        Write-Host "|  _  |   __| |    \|   __|  _  |       "
        Write-Host "|   __|__   |_|  |  |__   |     |       "
        Write-Host "|__|  |_____|_|____/|_____|__|__| v$((Get-Module PS.DSA).Version.ToString())  "
        Write-Host "Domain: " -ForegroundColor $Config.Color -NoNewline          ; Write-Host  $env:USERDNSDOMAIN -NoNewline
        Write-Host "`tConnected On: " -ForegroundColor $Config.Color -NoNewline  ; Write-Host $Global:PDC  -NoNewline
        Write-Host "`tLogon As: " -ForegroundColor $Config.Color -NoNewline      ; if ($null -ne $PSDSA_User.CommandsParam.Credential.UserName ) { Write-Host $PSDSA_User.CommandsParam.Credential.UserName -ForegroundColor DarkYellow } else {Write-Host $env:USERNAME}
    }

    if ($ShowScreen)
    {

        Write-TitleBar "INFO" -Width $Config.Width -Center

        Write-Host "SAMACCOUNTNAME   | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Properties.SamAccountName) "
        Write-Host "NAME             | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Properties.Name)"
        Write-Host "DESCRIPTION      | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Properties.description)"
        Write-Host "EMAIL            | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Properties.mail)"
        Write-Host "CREATED          | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Properties.whenCreated)"
        Write-Host "LAST CHANGE      | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$(Get-Date $PSDSA_User.Properties.WhenChanged -f "dd/MM/yy hh:mm")"
        Write-Host "OU               | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$(($PSDSA_User.Properties.DistinguishedName -split "," | Select-Object -Skip 1) -join ",")"

        Write-TitleBar "STATUS" -Width $Config.Width -Center

        #STATE ENABLED ---------------------------------------------------------------
        Write-Host "STATE            | " -ForegroundColor $Config.Color  -NoNewLine
        if ($PSDSA_User.Properties.Enabled -eq $true)
        {
            Write-Host " ENABLED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Green -NoNewLine
        }
        else
        {
            Write-Host " DISABLED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Red -NoNewLine
        }
        #STATE LOCKED OUT---------------------------------------------------------------
        Write-Host " - " -NoNewline
        if ($PSDSA_User.Properties.LockedOut -eq $true)
        {
            Write-Host " LOCKED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Red
        }
        else
        {
            Write-Host " UNLOCKED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Green
        }


        # LASTLOGONDATE ---------------------------------------------------------------

        Write-Host "LAST LOGON       | " -ForegroundColor $Config.Color -NoNewLine
        Write-TimeSpanLabel -Date $PSDSA_User.Properties.LastLogonDate

        #PASSWORD LAST SET
        Write-Host "LAST PASSWORDSET | " -ForegroundColor $Config.Color -NoNewLine
        Write-TimeSpanLabel -Date $PSDSA_User.Properties.PasswordLastSet

        #PASSWORD EXPIRATION
        Write-Host "PWD EXPIRATION   | " -ForegroundColor $Config.Color -NoNewLine
        if ($PSDSA_User.Properties.PasswordNeverExpires) { Write-Host "Never Expires" -ForegroundColor DarkYellow }
        else { Write-TimeSpanLabel -Date $PSDSA_User.PasswordExpireTime -DateInTheFuture }

        #LAST CHANGE
        Write-Host "LAST CHANGE      | " -ForegroundColor $Config.Color -NoNewline
        Write-Host $Global:PSDSA_User.Properties.WhenChanged

         if ($Config.UserAdditionalAttributes.count -gt 0)
         {
             Write-TitleBar "ADDITIONALS ATTRIBUTES" -Width $Config.Width -Center
             $MaxLength = $Config.UserAdditionalAttributes | % {$_.length} | Sort-Object -Descending | Select-Object -First 1
             foreach ($attributes in $Config.UserAdditionalAttributes)
             {
                 Write-Host ("{0,-$MaxLength} = " -f $attributes) -ForegroundColor $Config.Color -NoNewline
                 Write-Host "$($PSDSA_User.Properties.$attributes.ToString())"
             }

         }

    }

    if ($ShowMenu)
    {
        Write-TitleBar "Select an action - [UP / DOWN to navigate - ENTER to select]" -Width $Config.Width -center
        $global:PSDSA_UserMainMenu = . "$ModuleRoot\Menus\menu.user.ps1"
        $Choice = Write-Menu -menuItems $PSDSA_UserMainMenu.Keys -ReturnIndex -Color $Config.HightLight -Cursor ">"

        $PSDSA_UserMainMenu[$Choice].Invoke()
    }

}













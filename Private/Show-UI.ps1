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
        Write-Host "Domain: " -ForegroundColor $Config.Color -NoNewline        ; Write-Host  $env:USERDNSDOMAIN -NoNewline 
        Write-Host "`tConnected On: " -ForegroundColor $Config.Color -NoNewline  ; Write-Host $Global:PDC  -NoNewline
        Write-Host "`tLogon As: " -ForegroundColor $Config.Color -NoNewline      ; Write-Host $env:USERNAME
    }

    if ($ShowScreen)
    {
     
        Write-TitleBar "INFO" -Width $Config.Width -Center

        Write-Color "SAMACCOUNTNAME | ", "$($PSDSA_User.SamAccountName) " -Color $Config.Color , White
        Write-Color "NAME           | ", "$($PSDSA_User.Name)" -Color $Config.Color , White
        Write-Color "DESCRIPTION    | ", "$($PSDSA_User.description)" -Color $Config.Color , White  
        Write-Color "EMAIL          | ", "$($PSDSA_User.Email)" -Color $Config.Color , White  
        Write-Color "CREATED        | ", "$($PSDSA_User.whenCreated)" -Color $Config.Color , White 

        #OU
        [array]$OUs = ("$( $PSDSA_User.DistinguishedName -replace '^.*?,(..=.*)$', '$1')" -split "," | Where-Object { $_ -like "OU=*" }) -replace "OU="
        [array]::Reverse($OUs)
        $OUPath = $OUs -join " > "
        Write-Color "OU             | ", "$OUPath" -Color $Config.Color , White


        Write-TitleBar "STATUS" -Width $Config.Width -Center

        #STATE LOCKED OUT
        Write-Color "STATE            | " -Color $Config.Color  -NoNewLine
        if ($PSDSA_User.Enabled -eq $true) { Write-Color " ENABLED " -Color $host.ui.RawUI.BackgroundColor -BackGroundColor Green -NoNewLine }
        else { Write-Color " DISABLED " -Color $host.ui.RawUI.BackgroundColor -BackGroundColor Red -NoNewLine }
        Write-Host "  " -NoNewline
        if ($PSDSA_User.LockedOut -eq $true) { Write-Color " LOCKED " -Color $host.ui.RawUI.BackgroundColor -BackGroundColor Red }
        else { Write-Color " UNLOCKED " -Color $host.ui.RawUI.BackgroundColor -BackGroundColor Green }


        #LASTLOGONDATE
        Write-Color "LAST LOGON       | " -Color $Config.Color -NoNewLine
        if ((New-TimeSpan -Start $PSDSA_User.LastLogon -End (Get-Date)).Days -ge $Config.DaysBeforeAlert) { Write-Color "$(Get-Date $($PSDSA_User.LastLogon) -f "dd/MM/yy hh:mm")" -Color "DarkYellow" } 
        else { Write-Color "$(Get-Date $($PSDSA_User.LastLogon) -f "dd/MM/yy hh:mm")" -Color "White" }

        #PASSWORD LAST SET
        Write-Color "LAST PASSWORDSET | " -Color $Config.Color -NoNewLine
        if ((New-TimeSpan -Start $PSDSA_User.PasswordLastSet -End (Get-Date)).Days -ge $Config.DaysBeforeAlert) { Write-Color "$(Get-Date $PSDSA_User.PasswordLastSet -f "dd/MM/yy hh:mm")" -Color "DarkYellow" } 
        else { Write-Color "$(Get-Date $PSDSA_User.PasswordLastSet -f "dd/MM/yy hh:mm")" -Color "White" }

        #PASSWORD EXPIRATION
        Write-Color "PWD EXPIRATION   | " -Color $Config.Color -NoNewLine
        if ($PSDSA_User.PasswordNeverExpires) { Write-Color "Never Expires" -Color DarkYellow }
        else
        {
            if ($(Get-Date) -ge $PSDSA_User.UserPasswordExpiryTime) { Write-Color "$(Get-Date $PSDSA_User.UserPasswordExpiryTime -f "dd/MM/yy hh:mm")" -Color "Red" } 
            else { Write-Color "$(Get-Date $PSDSA_User.UserPasswordExpiryTime -f "dd/MM/yy hh:mm")" -Color "White" }
        }
        
        #LAST CHANGE
        Write-Color "LAST CHANGE      | ", "$(Get-Date $PSDSA_User.WhenChanged -f "dd/MM/yy hh:mm")" -Color $Config.Color , White
        
    }

    if ($ShowMenu)
    {
        Write-TitleBar "Select an action - [UP / DOWN to navigate - ENTER to select]" -Width $Config.Width
        $global:PSDSA_UserMainMenu = . "$ModuleRoot\Private\Menus\user.menu.ps1"
        $Choice = Write-Menu -menuItems $PSDSA_UserMainMenu.Keys -ReturnIndex

        $PSDSA_UserMainMenu[$Choice].Invoke()
    }

}

                                            
                                              
                                              

                  



                            
                                              
                                              

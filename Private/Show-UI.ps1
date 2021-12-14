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

        Write-Host "SAMACCOUNTNAME   | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.SamAccountName) "
        Write-Host "NAME             | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Name)"
        Write-Host "DESCRIPTION      | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.description)" 
        Write-Host "EMAIL            | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.Email)" 
        Write-Host "CREATED          | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$($PSDSA_User.whenCreated)"
        Write-Host "LAST CHANGE      | " -ForegroundColor $Config.Color -NoNewline  ; Write-Host "$(Get-Date $PSDSA_User.WhenChanged -f "dd/MM/yy hh:mm")" 
        Write-Host "OU               | " -ForegroundColor $Config.Color -NoNewline ; Write-Host "$(($PSDSA_User.DistinguishedName -split "," | Select-Object -Skip 1) -join ",")" 
        
        Write-TitleBar "STATUS" -Width $Config.Width -Center

        #STATE ENABLED ---------------------------------------------------------------
        Write-Host "STATE            | " -ForegroundColor $Config.Color  -NoNewLine
        if ($PSDSA_User.Enabled -eq $true) 
        { 
            Write-Host " ENABLED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Green -NoNewLine
        }
        else 
        { 
            Write-Host " DISABLED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Red -NoNewLine
        }
        #STATE LOCKED OUT---------------------------------------------------------------
        Write-Host " - " -NoNewline
        if ($PSDSA_User.LockedOut -eq $true) 
        { 
            Write-Host " LOCKED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Red 
        }
        else 
        { 
            Write-Host " UNLOCKED " -ForegroundColor $host.ui.RawUI.BackgroundColor -BackGroundColor Green 
        }


        # LASTLOGONDATE ---------------------------------------------------------------
        
        Write-Host "LAST LOGON       | " -ForegroundColor $Config.Color -NoNewLine
        Write-TimeSpanLabel -Date $PSDSA_User.LastLogon
   
        #PASSWORD LAST SET
        Write-Host "LAST PASSWORDSET | " -ForegroundColor $Config.Color -NoNewLine
        Write-TimeSpanLabel -Date $PSDSA_User.PasswordLastSet

        #PASSWORD EXPIRATION
        Write-Host "PWD EXPIRATION   | " -ForegroundColor $Config.Color -NoNewLine
        if ($PSDSA_User.PasswordNeverExpires) { Write-Host "Never Expires" -ForegroundColor DarkYellow }
        else { Write-TimeSpanLabel -Date $PSDSA_User.UserPasswordExpiryTime -DateInTheFuture }
        
        #LAST CHANGE
        Write-Host "LAST CHANGE      | " -ForegroundColor $Config.Color -NoNewline 
        Write-Host "$(Get-Date $PSDSA_User.WhenChanged -f "dd/MM/yy hh:mm")" 

         if ($Config.UserAdditionalAttributes.count -gt 0)
         {
             Write-TitleBar "ADDITIONALS ATTRIBUTES" -Width $Config.Width -Center
             $MaxLength = $Config.UserAdditionalAttributes | % {$_.length} | Sort-Object -Descending | Select-Object -First 1
             foreach ($attributes in $Config.UserAdditionalAttributes) 
             {
                 Write-Host ("{0,-$MaxLength} = " -f $attributes) -ForegroundColor $Config.Color -NoNewline
                 Write-Host "$($PSDSA_User.ADObject.$attributes.ToString())"
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

                                            
                                              
                                              

                  



                            
                                              
                                              

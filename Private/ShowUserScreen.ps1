function ShowUserScreen
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
        Write-Host "|  _  |   __| |    \|   __|  _  |       " -NoNewline ; Write-Host "Domain       : " -ForegroundColor $Color -NoNewline        ; Write-Host  $env:USERDNSDOMAIN
        Write-Host "|   __|__   |_|  |  |__   |     |       " -NoNewline ; Write-Host "Connected On : " -ForegroundColor $Color -NoNewline  ; Write-Host $env:LOGONSERVER 
        Write-Host "|__|  |_____|_|____/|_____|__|__| v1.0  " -NoNewline ; Write-Host "Logon As     : " -ForegroundColor $Color -NoNewline      ; Write-Host $env:USERNAME
        Write-Host    
    }

    if ($ShowScreen)
    {
     
        Write-Color (' ' * 38) -BackGroundColor $Color -Color Black -NoNewLine
        Write-Color "INFO" -BackGroundColor $Color -Color Black -NoNewLine
        Write-Color (' ' * 38) -BackGroundColor $color -Color Black 

        Write-Color "NAME           |", " $($PSDSA_User.Name)" -Color $Color , White -LinesBefore 1 -NoNewLine
        Write-Color "`tSAMACCOUNTNAME |", " $($PSDSA_User.SamAccountName)" -Color $Color , White -StartTab 1
        Write-Color "DESCRIPTION    |", " $($PSDSA_User.description)" -Color $Color , White  
        Write-Color "EMAIL          |", " $($PSDSA_User.Email)" -Color $Color , White  
        Write-Color "CREATED        |", " $($PSDSA_User.whenCreated)" -Color $Color , White 

        #OU
        [array]$OUs = ("$( $PSDSA_User.DistinguishedName -replace '^.*?,(..=.*)$', '$1')" -split "," | Where-Object { $_ -like "OU=*" }) -replace "OU="
        [array]::Reverse($OUs)
        $OUPath = $OUs -join " > "
        Write-Color "OU             |", " $OUPath" -Color $Color , White


        Write-Color (' ' * 37) -BackGroundColor $Color -Color Black -NoNewLine -LinesBefore 1
        Write-Color "STATUS" -BackGroundColor $Color -Color Black -NoNewLine
        Write-Color (' ' * 37) -BackGroundColor $Color -Color Black

        #DATES
        if ((New-TimeSpan -Start $PSDSA_User.LastLogon -End (Get-Date)).Days -ge 90) { $Color_LastLogon = "DarkYellow" } else { $Color_LastLogon = "White" }
        if ((New-TimeSpan -Start $PSDSA_User.PasswordLastSet -End (Get-Date)).Days -ge 90) { $PwdLSColor = "DarkYellow" } else { $PwdLSColor = "White" }

        Write-Color "LAST LOGON       |", " $(Get-Date $($PSDSA_User.LastLogon) -f "dd/MM/yy")" -Color $Color , $Color_LastLogon -NoNewLine -LinesBefore 1

        Write-Color "ENABLE      " -Color $Color  -NoNewLine -StartTab 1
        if ($PSDSA_User.Enabled -eq $false) { Write-Color $Badge -Color Red }
        else { Write-Color $Badge -Color Green }
        
        Write-Color "LAST PASSWORDSET |", " $(Get-Date $PSDSA_User.PasswordLastSet -f "dd/MM/yy")" -Color $Color , $PwdLSColor -NoNewLine

        Write-Color "LOCKEDOUT   " -Color $Color  -StartTab 1 -NoNewLine
        if ($PSDSA_User.LockedOut -eq $true) { Write-Color $Badge -Color Red }
        else { Write-Color $Badge -Color Green }
        
    
        Write-Color "LAST CHANGE      :", " $(Get-Date $PSDSA_User.WhenChanged -f "dd/MM/yy")" -Color $Color , White

        Write-Color $("_" * 80) -LinesBefore 1 -Color White   
    }

    if ($ShowMenu)
    {
        #MAIN MENU
        $global:PSDSA_UserMainMenu = @{

            "1" = @{
                Label  = "Get User Groups"
                Action = { $Global:PSDSA_User.ShowGroups() ; wait}
            }
        
            "2" = @{
                Label  = "Reset Password"
                Action = { $global:PSDSA_User.ResetPassword() ; Wait  }
            }

            "3" = @{
                Label  = "Disable Account"
                Action = { Write-Host "You choose Option 3" }
            }
        }

        if ($PSDSA_User.Enabled -eq $true)
        {
            $global:PSDSA_UserMainMenu["3"] = @{Label = "Disable Account" ; Action = {$PSDSA_User.DisableAccount() ; Wait}} 
        }
        else
        {
            $global:PSDSA_UserMainMenu["3"] = @{Label = "Enable Account" ; Action = {$PSDSA_User.EnableAccount() ; Wait}}
        }

        if ($PSDSA_User.LockedOut -eq $true)
        {
            $global:PSDSA_UserMainMenu["4"] = @{Label = "Unlock Account" ; Action = {$PSDSA_User.Unlock()}} 
        }

        Write-Menu -MenuHashtable $PSDSA_UserMainMenu -Color $Color
    }

    
    
   
}

                                            
                                              
                                              

                  



                            
                                              
                                              

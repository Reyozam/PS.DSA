Class PSDSAUser
{
    [string]   $Name
    [string]   $SamAccountName
    [string]   $Title
    [string]   $Description
    [string]   $GivenName
    [string]   $Surname
    [string]   $Email
    [boolean]  $PasswordNeverExpires
    [boolean]  $PasswordNotRequired
    [string]   $DistinguishedName
    [string]   $UserPrincipalName
    [guid]     $ObjectGUID
    [string]   $ObjectSID
    [string[]] $MemberOf
    [string]   $Manager
    [datetime] $LastLogon
    [boolean]  $LockedOut
    [boolean]  $Enabled
    [int]      $BadPasswordCount
    [boolean]  $PasswordExpired
    [datetime] $PasswordLastSet
    [datetime] $UserPasswordExpiryTime
    [datetime] $whenChanged
    [datetime] $whenCreated
    [string]   $Domain
    [string]   $Server
    <#[Microsoft.ActiveDirectory.Management.ADAccount]#> $ADObject

    PSDSAUser ()
    {
        Write-Error "You must provide a username" -ErrorAction Stop
    }

    PSDSAUser ([string]$Identity,[string]$Server)
    {
        $Found = Get-ADUser -Identity $Identity -Properties *, "msDS-UserPasswordExpiryTimeComputed" -ErrorAction Stop -Server $Server

        if ($null -eq $Found)
        {
            Write-Error "User Not Found" -ErrorAction Stop
        }
                
        # Fill in the object
        $this.SamAccountName = $Found.SamAccountName
        $this.Name = $Found.displayname 
        $this.SamAccountName = $Found.samaccountname 
        $this.Title = $Found.title 
        $this.Description = $Found.description 
        $this.GivenName = $Found.givenname 
        $this.Surname = $Found.sn 
        $this.Email = $Found.mail 
        $this.PasswordNeverExpires = $Found.PasswordNeverExpires
        $this.PasswordNotRequired = $Found.PasswordNotRequired
        $this.DistinguishedName = $Found.distinguishedname 
        $this.UserPrincipalName = $Found.userprincipalname 
        $this.ObjectGUID = $Found.ObjectGUID
        $this.ObjectSID = $Found.objectSid
        $this.MemberOf = $Found.memberof
        $this.Manager = $Found.manager 
        $this.LockedOut = $Found.LockedOut
        $this.BadPasswordCount = $Found.badpwdcount 
        $this.PasswordExpired = $Found.PasswordExpired
        $this.PasswordLastSet = $Found.PasswordLastSet
        $this.Enabled = $Found.Enabled
        $this.LastLogon = ([datetime]::FromFileTime($Found.lastLogon))
        $this.whenChanged = $Found.whenChanged
        $this.whenCreated = $Found.whenCreated
        $this.UserPasswordExpiryTime = if ($Found.PasswordNeverExpires) {Get-Date -Day 1 -Month 1 -Year 2099} else {[string]([datetime]::FromFileTime($Found."msDS-UserPasswordExpiryTimeComputed"))}
        $this.ADObject = $Found
        
        $this.Server = $Server
        $this.Domain = ($Found.CanonicalName -split "/")[0]
        
        $DefaultDisplayProperties = @(
            "Name"
            "SamAccountName"
            "Title"
            "Enabled"
            "LockedOut"
            "BadPasswordCount"
            "LastLogon"
        )

        $this | Add-Member -Force -MemberType MemberSet PSStandardMembers ([System.Management.Automation.PSMemberInfo[]]@(New-Object System.Management.Automation.PSPropertySet("DefaultDisplayPropertySet", [String[]]$DefaultDisplayProperties)))
    }


    [void] Reload ()
    {
        $Found = Get-ADUser -Identity $this.SamAccountName -Properties * -ErrorAction Stop -Server $this.Server

        if ($null -eq $Found)
        {
            Write-Error "User Not Found" -ErrorAction Stop
        }
                
            
        # Fill in the object
        $this.Name = $Found.displayname 
        $this.SamAccountName = $Found.samaccountname 
        $this.Title = $Found.title 
        $this.Description = $Found.description 
        $this.GivenName = $Found.givenname 
        $this.Surname = $Found.sn 
        $this.Email = $Found.mail 
        $this.PasswordNeverExpires = $Found.PasswordNeverExpires
        $this.PasswordNotRequired = $Found.PasswordNotRequired
        $this.DistinguishedName = $Found.distinguishedname 
        $this.UserPrincipalName = $Found.userprincipalname 
        $this.MemberOf = $Found.memberof
        $this.Manager = $Found.manager 
        $this.LockedOut = $Found.LockedOut
        $this.BadPasswordCount = $Found.badpwdcount 
        $this.PasswordExpired = $Found.PasswordExpired
        $this.PasswordLastSet = $Found.PasswordLastSet
        $this.Enabled = $Found.Enabled
        $this.LastLogon = [datetime]::FromFileTime($Found.lastLogon)
        $this.whenChanged = $Found.whenChanged

        $this.Domain = ($Found.CanonicalName -split "/")[0]
    }

    [void] ShowAllAttributes ()
    {
        Write-Host ($this.ADObject | Select-Object -ExcludeProperty memberof | Out-String)
    } 

    [void] ShowGroups ()
    {
         $Groups = ForEach ($Group in ($this.MemberOf)) ##
         {
             [PSCustomObject]@{
                 Domain = (($Group -split "," -replace "\w{2}=") | Select-Object -Last 3 ) -join "."
                 Name   = ($Group -split "," -replace "\w{2}=")[0]
             }
         } 
           
         Write-Host ($Groups | Sort-Object Name | Format-Wide -Property Name | Out-String)
    } 

    [void] AddUserToGroup ($GroupName)
    {           
    }

    [void] Unlock ()
    {
        try 
        {
            
            Unlock-ADAccount -Identity $this.SamAccountName -Server $this.Server -ErrorAction Stop
            Write-Color "[+]  $($this.SamAccountName) Unlocked !" -Color "Green", "White"
        }
        catch 
        {
            Write-Color "[x] ", $($_.Exception.Message) -Color Red
        }

        $this.Reload()
    }

    [void] ResetPassword ($Length)
    {
        Write-Color "Method: " -Color Green -LinesBefore 1
        $Choice = Write-Menu -menuItems "Ramdomly Generated", "Manually","Cancel"

        switch ($Choice) 
        {
            "Ramdomly Generated" 
            {
                $ClearPassword = $null
                $SecurePassword = Get-NewPassword -Length $Length -Include LowerCase, UpperCase, Numbers | Tee-Object -Variable ClearPassword | ConvertTo-SecureString -AsPlainText -Force

                try 
                {
                    Set-ADAccountPassword -Identity $this.SamAccountName -NewPassword $SecurePassword -Reset -ErrorAction Stop -Server $this.Server
                    Write-Color "[+] Password Generated: ", $ClearPassword -Color "Green", "White" -LinesBefore 1
                    $this.Reload()
                    
                }
                catch
                {
                    Write-Color "[x] ", $($_.Exception.Message) -Color Red
                }
                
            }
            "Manually" 
            {
                Write-Color "Enter New Password  > " -Color Green -NoNewLine ; $Password1 = Read-Host -AsSecureString
                Write-Color "Verify New Password > " -Color Green -NoNewLine ; $Password2 = Read-Host -AsSecureString
    
                $Temp1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password1))
                $Temp2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2))

                If ($Temp1 -ceq $Temp2)
                {
                    try 
                    {
                        Set-ADAccountPassword -Identity $this.SamAccountName -NewPassword $Password2 -Reset -ErrorAction Stop -Server $this.Server
                        Write-Color "[+] Password Changed: " -Color "Green" -LinesBefore 1
                        $this.Reload()
                    }
                    catch
                    {
                        Write-Color "[x] ", $($_.Exception.Message) -Color Red
                    }
                }
                Else
                {
                    Write-Color "[x] ", "Password did not match" -Color Red
                }
            }
            "Cancel" {}
        }
    }

    [void] EnableAccount ()
    {
        try 
        {
            Set-ADUser -Identity $this.SamAccountName -Enabled $true -ErrorAction Stop -Server $this.Server
            Write-Color "[+] Account Enabled" -Color Green -LinesBefore 1   
        }
        catch 
        {
            Write-Color "[x] ", $($_.Exception.Message) -Color Red -LinesBefore 1 
        }

        $this.Reload()
    }

    [void] DisableAccount ()
    {
        try 
        {
            Set-ADUser -Identity $this.SamAccountName -Enabled $false -ErrorAction Stop -Server $this.Server
            Write-Color "[+] Account Disabled" -Color Green -LinesBefore 1   
        }
        catch 
        {
            Write-Color "[x] ", $($_.Exception.Message) -Color Red -LinesBefore 1 
        }

        $this.Reload()
    }


}


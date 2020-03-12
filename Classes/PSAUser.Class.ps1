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
    [datetime] $whenChanged
    [datetime] $whenCreated
    [string]   $Domain

    PSDSAUser ()
    {
        Write-Error "You must provide a username" -ErrorAction Stop
    }

    PSDSAUser ([string]$Identity)
    {
        $Found = Get-ADUser -Identity $Identity -Properties * -ErrorAction Stop

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
        $Found = Get-ADUser -Identity $this.SamAccountName -Properties * -ErrorAction Stop

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
        $this.ObjectGUID = $Found.ObjectGUID
        $this.ObjectSID = $Found.objectSid
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

    [void] ShowGroups ()
    {
        ShowUserScreen -ShowHeader
        Write-Color (' ' * 34) -BackGroundColor $global:Color -Color Black -NoNewLine
        Write-Color "GROUP MEMBERSHIP" -BackGroundColor $global:Color -Color Black -NoNewLine
        Write-Color (' ' * 34) -BackGroundColor $global:Color -Color Black 

        $Groups = ForEach ($Group in ($this.MemberOf))
        {
            $Group = (Get-ADGroup $Group)

            [PSCustomObject]@{
                Group = $Group.Name
            }
        } 
            
        Write-Host ($Groups | Sort-Object | Format-Wide | Out-String)

       
        
    } 

    [void] AddUserToGroup ($GroupName)
    {
        try 
        {
            Write-Host "[>]" -ForegroundColor Green -NoNewline
            Write-Host " Add User to Group : $GroupName`t" -NoNewline
            $GroupObj = Get-ADGroup $GroupName -Server $this.Domain -ErrorAction Stop
            $GroupObj | Add-ADGroupMember -Members $this.SamAccountName -Server $this.Domain -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green
        }
        catch [Microsoft.ActiveDirectory.Management.ADException]
        {
            Write-Host " Failed [Access Denied. Enter Admin Credentials]" -ForegroundColor Red
        }
        catch 
        {
            Write-Host " Failed [Group Not Found]" -ForegroundColor Red
        }
                
    }

    [PSCustomObject]FindLockout ()
    {
        $Start = (Get-Date).AddDays(-2)
        $End = Get-Date
        $PDC = Get-PDC

        $FilterHash = @{
            LogName   = "Security"
            StartTime = $Start
            EndTime   = $End
            ID        = 4740
        }

        $Results = $null
        Write-Host "[>]" -ForegroundColor Green -NoNewline
        Write-Host "Searching ... (May take a while)"

        Try
        {
            $Results = Get-WinEvent -ComputerName $PDC -FilterHashtable $FilterHash -ErrorAction Stop | 
                Where-Object Message -Like "*$($this.SamAccountName)*" | 
                Select-Object TimeCreated,
                @{Name = "User"; Expression = { $Username } },
                @{Name = "LockedOn"; Expression = { $PSItem.Value[1] } }
            
        }
        Catch
        {
            Write-Error "Unable to retrieve event log for $PDC because ""$_""" -ErrorAction Stop
        }
        Return $Results

    }

    [void] Unlock ()
    {
        try 
        {
            Write-Host "[>]" -ForegroundColor Green -NoNewline
            Write-Host " Unlock USer : $($this.SamAccountName)`t" -NoNewline
            Unlock-ADAccount -Identity $this.SamAccountName -Server $this.Domain -ErrorAction Stop
            Write-Host "OK" -ForegroundColor Green
        }
        catch [Microsoft.ActiveDirectory.Management.ADException]
        {
            Write-Host " Failed [Access Denied. Enter Admin Credentials]" -ForegroundColor Red
        }
        catch 
        {
            Write-Host " Failed [$($Error[0].Exception.Message)]" -ForegroundColor Red
        }
    }

    [void] RemoveGroup ( [string]$GroupName )
    {
        $Searcher = [ADSISearcher]"(&(objectCategory=group)(samAccountName=$GroupName))"
        $Found = $Searcher.FindOne()

        If ($null -eq $Found.samaccountname)
        {
            Write-Error "Unable to locate group ""$GroupName""" -ErrorAction Stop
        }
        Else
        {
            If ($this.MemberOf -contains $Found.distinguishedname)
            {
                $GroupObj = [ADSI]"LDAP://$($Found.distinguishedname)"
                $GroupObj.Remove("LDAP://$($this.DistinguishedName)")
                Write-Verbose "Removed from group ""$($Found.name)""" -Verbose
            }
            Else
            {
                Write-Error "User is not currently a member of ""$GroupName""" -ErrorAction Stop
            }
        }
    }

    [void] ResetPassword ()
    {
        Write-Color "Enter New Password  > " -Color DarkYellow -NoNewLine ; $Password1 = Read-Host -AsSecureString
        Write-Color "Verify New Password > " -Color DarkYellow -NoNewLine ; $Password2 = Read-Host -AsSecureString

        $Temp1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password1))
        $Temp2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2))

        If ($Temp1 -ceq $Temp2)
        {
            $UserObj = [ADSI]"LDAP://$($this.distinguishedName)"

            $PsCred = New-Object System.Management.Automation.PSCredential ("username", $Password1)

            try 
            {
                $UserObj.SetPassword($PsCred.GetNetworkCredential().Password)
                Write-Color "[+] Password set !" -Color Green
            }
            catch 
            {
                Write-Color "[x] Password cannot be set !" -Color Red  
            }
            
        }
        Else
        {
            Write-Error "Passwords did not match" -ErrorAction Stop
        }

        $this.Reload()
    }

    [void] EnableAccount ()
    {
        try 
        {
            Set-ADUser -Identity $this.SamAccountName -Enabled $true -ErrorAction Stop 
            Write-Color "[+] Account Enabled" -Color Green    
        }
        catch 
        {
            Write-Host $_.Exception.Message -ForegroundColor Red
        }

        $this.Reload()
    }

    [void] DisableAccount ()
    {
        try 
        {
            Set-ADUser -Identity $this.SamAccountName -Enabled $false -ErrorAction Stop
            Write-Color "[+] Account Disabled" -Color Green   
        }
        catch 
        {
            Write-Host $_.Exception.Message -ForegroundColor Red
        }

        $this.Reload()
    }


}


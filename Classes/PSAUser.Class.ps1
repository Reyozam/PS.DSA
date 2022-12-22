Class PSDSA_User
{
    [PSObject]$Properties
    [string]$Domain
    [string]$Server
    [datetime]$LastActivityDate
    [datetime]$PasswordExpireTime
    [hashtable]$CommandsParam

    PSDSA_User ()
    {
        Write-Error 'You must provide a username' -ErrorAction Stop
    }

    PSDSA_User ([string]$Identity, [string]$Server)
    {
        $this.Properties = Get-ADUser -Identity $Identity -Properties *, 'msDS-UserPasswordExpiryTimeComputed' -ErrorAction Stop -Server $Server
        $this.Domain = ($this.Properties.CanonicalName -split '/')[0]
        $this.Server = $Server
        $this.LastActivityDate = $this.Properties.LastLogonDate, $this.Properties.PasswordLastSet, $this.Properties.Created | Sort-Object -Descending | Select-Object -First 1
        $this.PasswordExpireTime = if ($this.Properties.PasswordNeverExpires) { $null } else { [string]([datetime]::FromFileTime($this.Properties.'msDS-UserPasswordExpiryTimeComputed')) }
        $this.CommandsParam = @{"Server" = $this.Server}
    }


    [void] Reload ()
    {
        $this.Properties = Get-ADUser -Identity $this.Properties.SamAccountName -Properties *, 'msDS-UserPasswordExpiryTimeComputed' -ErrorAction Continue -Server $this.Server
        $this.LastActivityDate = $this.Properties.LastLogonDate, $this.Properties.PasswordLastSet, $this.Properties.Created | Sort-Object -Descending | Select-Object -First 1
        $this.PasswordExpireTime = if ($this.Properties.PasswordNeverExpires) { $null } else { [string]([datetime]::FromFileTime($this.Properties.'msDS-UserPasswordExpiryTimeComputed')) }

    }

    [void] ShowAllAttributes ()
    {
        Write-Host ($this.Properties | Out-String)
    }

    [void] ShowGroups ()
    {
        $Groups = $this.Properties.MemberOf | ForEach-Object {
            [PSCustomObject]@{
                Name = ($_ -split ',' -replace '\w{2}=')[0]
            }
        }

        Write-Host ($Groups | Sort-Object Name | Format-Wide -AutoSize | Out-String)
    }

    [void] AddUserToGroup ($GroupName)
    {
    }

    [void] Unlock ()
    {
        Unlock-ADAccount -Identity $this.properties.SamAccountName
    }

    [void] ResetPassword ($Length)
    {
        Write-Color 'Method: ' -Color Green -LinesBefore 1
        $Choice = Write-Menu -menuItems 'Ramdomly Generated', 'Manually', 'Cancel'
        $Params = $this.CommandsParam

        switch ($Choice)
        {
            'Ramdomly Generated'
            {
                $ClearPassword = $null
                $SecurePassword = Get-NewPassword -Length $Length -Include LowerCase, UpperCase, Numbers | Tee-Object -Variable ClearPassword | ConvertTo-SecureString -AsPlainText -Force
                try
                {
                    Set-ADAccountPassword -Identity $this.Properties.SamAccountName -NewPassword $SecurePassword -Reset -ErrorAction Stop @Params
                    Write-Color '[+] Password Generated: ', $ClearPassword -Color 'Green', 'White' -LinesBefore 1
                    $this.Reload()

                }
                catch
                {
                    Write-Color '[x] ', $($_.Exception.Message) -Color Red
                }

            }
            'Manually'
            {
                Write-Color 'Enter New Password  > ' -Color Green -NoNewLine ; $Password1 = Read-Host -AsSecureString
                Write-Color 'Verify New Password > ' -Color Green -NoNewLine ; $Password2 = Read-Host -AsSecureString

                $Temp1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password1))
                $Temp2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password2))

                If ($Temp1 -ceq $Temp2)
                {
                    try
                    {
                        Set-ADAccountPassword -Identity $this.Properties.SamAccountName -NewPassword $Password2 -Reset -ErrorAction Stop @Params
                        Write-Color '[+] Password Changed: ' -Color 'Green' -LinesBefore 1
                        $this.Reload()
                    }
                    catch
                    {
                        Write-Color '[x] ', $($_.Exception.Message) -Color Red
                    }
                }
                Else
                {
                    Write-Color '[x] ', 'Password did not match' -Color Red
                }
            }
            'Cancel' {}
        }
    }

    [void] EnableAccount ()
    {
        $Params = @{
            Identity    = $this.Properties.SamAccountName
            Enabled     = $true
            ErrorAction = 'Stop'
        } + $this.CommandsParam


        Set-ADUser @Params
        $this.Reload()
    }

    [void] DisableAccount ()
    {
        $Params = @{
            Identity    = $this.Properties.SamAccountName
            Enabled     = $false
            ErrorAction = 'Stop'
        } + $this.CommandsParam


        Set-ADUser @Params
        $this.Reload()
    }

}


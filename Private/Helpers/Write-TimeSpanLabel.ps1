function Write-TimeSpanLabel
{
    [CmdletBinding()]
    param (
        [datetime]$Date,
        [switch]$DateInTheFuture,
        [int]$DaysBeforeWarning = 45,
        [int]$DaysBeforeAlert = 90
    )

    $Now = Get-Date
    #$Now.ToString("dd/MM/yy hh:mm")
    $TimeSpan = New-TimeSpan -Start $Date -End $Now

    if ($DateInTheFuture)
    {
        if ($Now -gt $Date)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - Expired" -ForegroundColor Red
        }
        elseif ($TimeSpan.Days -ge -10 -and $TimeSpan.Days -ne 0)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - In $($TimeSpan.Days * -1) days" -ForegroundColor Yellow
        }
        elseif ($TimeSpan.Days -eq 0)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - Today" -ForegroundColor Yellow
        }
        else
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - In $($TimeSpan.Days * -1) days" -ForegroundColor Green
        }

    }
    else
    {
        $TimeSpanToText = switch ($TimeSpan)
        {
            { $_.Days -ne 0 } { "$($_.Days) days ago"         ; break }
            { $_.Hours -ne 0 } { "$($_.Hours) hours ago"       ; break }
            { $_.Minutes -ne 0 } { "$($_.Minutes) minutes ago"   ; break }
            default { "Just Now" }
        }

        if ($TimeSpan.Days -ge $DaysBeforeAlert)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - $TimeSpanToText" -ForegroundColor Red
        }
        elseif ($TimeSpan.Days -ge $DaysBeforeWarning -and $TimeSpan.Days -lt $DaysBeforeAlert)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - $TimeSpanToText" -ForegroundColor Yellow
        }
        else
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm") - $TimeSpanToText"
            #"$($PSStyle.Foreground.White)$(Get-Date $Date -f "dd/MM/yy hh:mm") - $TimeSpanToText$($PSStyle.Reset)"
        }
    }


}
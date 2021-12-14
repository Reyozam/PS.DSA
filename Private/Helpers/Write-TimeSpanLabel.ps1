function Write-TimeSpanLabel 
{
    [CmdletBinding()]
    param (
        [datetime]$Date,
        [switch]$DateInTheFuture
    )
    
    $Now = Get-Date
    #$Now.ToString("dd/MM/yy hh:mm") 
    $TimeSpan = New-TimeSpan -Start $Date -End (Get-Date)

    if ($DateInTheFuture)
    {
        if ($Now -gt $Date)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -ForegroundColor "Red" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host "Expired" -ForegroundColor Red
        }
        elseif ($TimeSpan.Days -ge -10 -and $TimeSpan.Days -ne 0)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -ForegroundColor "DarkYellow" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host "In $($TimeSpan.Days * -1) days " -ForegroundColor "DarkYellow"
        }
        elseif ($TimeSpan.Days -eq 0)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -ForegroundColor "DarkYellow" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host "Today" -ForegroundColor "DarkYellow"
        }
        else
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host "In $($TimeSpan.Days * -1) days " 
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
        
        if ($TimeSpan.Days -ge $Config.DaysBeforeAlert)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -ForegroundColor "Red" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host $TimeSpanToText -ForegroundColor Red
        }
        elseif ($TimeSpan.Days -ge $Config.DaysBeforeWarning -and $TimeSpan.Days -lt $Config.DaysBeforeAlert)
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -ForegroundColor "DarkYellow" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host $TimeSpanToText -ForegroundColor DarkYellow
        }
        else
        {
            Write-Host "$(Get-Date $Date -f "dd/MM/yy hh:mm")" -NoNewline
            Write-Host " - " -NoNewline
            Write-Host $TimeSpanToText 
        }
    }


}
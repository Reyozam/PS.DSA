Function Wait ()
{
    Write-Host
    Write-Host "[  Press a [ENTER] to continue  ]" -ForegroundColor Black -BackgroundColor $Color
    [Console]::ReadKey($true) | Out-Null
    ShowUserScreen -ShowHeader -ShowScreen -ShowMenu
} 
Function Wait ()
{
    Write-Color " Press a key to continue " -BackGroundColor White -Color Black -LinesBefore 1
    [Console]::ReadKey($true) | Out-Null
    Show-UI -ShowHeader -ShowScreen -ShowMenu
} 
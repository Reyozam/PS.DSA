function Get-PDC
{
    param ($Domain = $env:USERDOMAIN)

    return Get-ADDomain -Server $Domain | Select-Object -ExpandProperty PDCEmulator
}
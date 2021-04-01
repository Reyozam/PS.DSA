#Requires -Modules ActiveDirectory

$Global:ModuleRoot = $PSScriptRoot

#Load Config
& "$ModuleRoot\PS.DSA.Config.ps1"

$Public = @( Get-ChildItem -Path $ModuleRoot\Public\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $ModuleRoot\Private\*.ps1 -Recurse -ErrorAction SilentlyContinue )
$Classes = @( Get-ChildItem -Path $ModuleRoot\Classes\*.ps1 -Recurse -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private + $Classes))
{
    Try
    {
        Write-Verbose -Message "Importing $($import.fullname)"
        . $import.fullname
    }
    Catch
    {
        Write-Error -Message "Failed to import $($import.fullname): $_"
    }
}

Export-ModuleMember -Function ($Public | Select-Object -ExpandProperty Basename)

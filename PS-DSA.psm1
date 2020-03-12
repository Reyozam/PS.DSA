#Requires -Modules ActiveDirectory
$Global:Color = "Blue"
$Global:Badge = [char]9632
$script:Config = .$PSScriptRoot\PS-DSA.Config.ps1

$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
$Classes = @( Get-ChildItem -Path $PSScriptRoot\Classes\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files
Foreach ($import in @($Public + $Private + $Classes)) {
    Try {
        Write-Verbose -Message "Importing $($import.fullname)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import $($import.fullname): $_"
    }
}

Export-ModuleMember -Function ($Public | Select-Object -ExpandProperty Basename)

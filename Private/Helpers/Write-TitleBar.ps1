function Write-TitleBar
{
    param(
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][int]$Width,
        [Parameter()][string]$Color = $Global:Config.Color,
        [Parameter()][switch]$Center
    )
    
    if ($Center)
    {
        for ($i = 0; $i -lt (([Math]::Max(0, $Width / 2) - [Math]::Max(0, $Message.Length / 2))); $i++)
        {
            $string = $string + " "
        }
        $string = $string + $Message
        for ($i = 0; $i -lt ($Width - ((([Math]::Max(0, $Width / 2) - [Math]::Max(0, $Message.Length / 2))) + $Message.Length)) - 2; $i++)
        {
            $string = $string + " "
        }
    }
    else
    {
        $String = " $Message"
        $String += (" " *($Width - $string.Length))
    }
    
    $String = $string.toupper()
    Write-Host ""
    Write-Host $String -BackgroundColor $Color -ForegroundColor $host.ui.RawUI.BackgroundColor
    Write-Host ""
}


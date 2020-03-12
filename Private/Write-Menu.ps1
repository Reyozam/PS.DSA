﻿Function Write-Menu
{
    [CmdletBinding()]
    param
    (
        #Hashtable Menu
        [Parameter(Mandatory)]
        [hashtable]$MenuHashtable,

        [System.ConsoleColor]$Color = "Green"
    )

    begin
    {
        if ($MenuHashtable["Title"])
        {
            #TITLE
            $Lenght = ($MenuHashtable["Title"]).Length + 10
            Write-Host ($MenuHashtable["Title"]).ToUpper()  -ForegroundColor $Color
            Write-Host ("=" * $Lenght) -ForegroundColor $Color
            Write-Host ""
        }

        $MenuHashtable["Q"] = @{Label = "Exit" ; Action = { return } }

        [System.Collections.ArrayList]$Keys = $MenuHashtable.Keys | Where-Object { $_.Length -eq 1 } | Sort-Object

    }

    process
    {
        $Keys | Where-object { $_ -ne "Q" } | ForEach-Object {

            Write-Host "[${_}] " -ForegroundColor $Color -NoNewline
            Write-Host  $MenuHashtable[$_].Label

        }

        Write-Host "[Q] " -ForegroundColor Red -NoNewline
        Write-Host  "Exit"
        Write-Host ""
    }
    end
    {

        do
        {
            Write-Host "\ " -NoNewline
            Write-Host "Actions " -NoNewline -ForegroundColor $Color
            #Write-Host " [$($Keys -join ",") OR Q to quit] " -ForegroundColor DarkYellow -NoNewline
            Write-Host "> " -NoNewline

            $Selection = Read-Host
        } until ($Keys -contains $Selection)

        $MenuHashtable[$Selection].Action.Invoke()
    }
	
} 
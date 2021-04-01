function Show-Menu {
    param ($menuItems, $menuPosition, $Multiselect, $selection)
    $l = $menuItems.length
    for ($i = 0; $i -le $l;$i++) {
		if ($null -ne $menuItems[$i]){
			$item = $menuItems[$i]
			if ($Multiselect)
			{
				if ($selection -contains $i){
					$item = '[x] ' + $item
				}
				else {
					$item = '[ ] ' + $item
				}
			}
			if ($i -eq $menuPosition) {
				Write-Host "> $($item)" -ForegroundColor Green
			} else {
				Write-Host "  $($item)"
			}
		}
    }
}

function Format-Selection {
	param ($pos, [array]$selection)
	if ($selection -contains $pos){ 
		$result = $selection | Where-Object {$_ -ne $pos}
	}
	else {
		$selection += $pos
		$result = $selection
	}
	$result
}

function Write-Menu {
    param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect)
    $vkeycode = 0
    $pos = 0
    $selection = @()
    [console]::CursorVisible=$false #prevents cursor flickering
    if ($menuItems.Length -gt 0)
	 {
		Show-Menu $menuItems $pos $Multiselect $selection
		While ($vkeycode -ne 13 -and $vkeycode -ne 27) {
			$press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
			$vkeycode = $press.virtualkeycode
			If ($vkeycode -eq 38 -or $press.Character -eq 'k') {$pos--}
			If ($vkeycode -eq 40 -or $press.Character -eq 'j') {$pos++}
			If ($press.Character -eq ' ') { $selection = Format-Selection $pos $selection }
			if ($pos -lt 0) {$pos = 0}
			If ($vkeycode -eq 27) {$pos = $null }
			if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
			if ($vkeycode -ne 27)
			{
			   $startPos = [System.Console]::CursorTop - $menuItems.Length
				[System.Console]::SetCursorPosition(0, $startPos)
				Show-Menu $menuItems $pos $Multiselect $selection
			}
		}
	}
	else 
	{
		$pos = $null
	}
    [console]::CursorVisible=$true

    if ($ReturnIndex -eq $false -and $null -ne $pos)
	{
		if ($Multiselect){
			return $menuItems[$selection]
		}
		else {
			return $menuItems[$pos]
		}
	}
	else 
	{
		if ($Multiselect){
			return $selection
		}
		else {
			return $pos
		}
	}
}
#Author: psammut

function relativePathToHome{
	$currentPath = (Get-Location).Path
	$currentDrive = (Get-Location).Drive.Root
	$homeDrive = ($_home).Drive.Root
	if ($currentPath -eq $currentDrive -or $currentDrive -ne $homeDrive) {
		$trimmedRelativePath = $currentPath
	}
	else {
		Set-Location $_home
		$relativePath = Resolve-Path -relative $currentPath
		$trimmedRelativePath = $relativePath -replace '^..\\'
	}
	Set-Location $currentPath
	# Write-Host $relativePath
	# Write-Host $trimmedRelativePath
	return $trimmedRelativePath
}

function PowerlineStylePrompt {
	# Prompt Colors
	# Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
	# Gray DarkGray Blue Green Cyan Red Magenta Yellow White

	$prompt_time_text = "Black"
	$prompt_time_background = "Gray"
	$prompt_text = "White"
	$prompt_background = "Blue"
	$prompt_git_background = "Yellow"
	$prompt_git_text = "Black"

	# Grab Git Branch
	$git_string = "";
	git branch | foreach {
		if ($_ -match "^\* (.*)"){
			$git_string += $matches[1]
		}
	}

	# Grab Git Status
	$git_status = "";
	git status --porcelain | foreach {
		$git_status = $_ #just replace other wise it will be empty
	}

	if (!$git_string)	{
		$prompt_text = "White"
		$prompt_background = "Blue"
	}

	if ($git_status){
		$prompt_git_background = "DarkGreen"
	}

	$curtime = Get-Date
	# $drive = (PWD).Drive.Name
	$path = Split-Path (PWD) -Leaf

	$relativePath = relativePathToHome

	# Write-Host -NoNewLine (" PS$psVersion " -f (Get-Date)) -foregroundColor $prompt_time_text -backgroundColor $prompt_time_background
	Write-Host -NoNewLine (" {0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor $prompt_time_text -backgroundColor $prompt_time_background
	Write-Host -NoNewLine "$([char]57520)" -foregroundColor $prompt_time_background -backgroundColor $prompt_background
	# Write-Host " $path " -foregroundColor $prompt_text -backgroundColor $prompt_background -NoNewLine
	Write-Host " $relativePath " -foregroundColor $prompt_text -backgroundColor $prompt_background -NoNewLine
	if ($git_string){
		Write-Host  "$([char]57520)" -foregroundColor $prompt_background -NoNewLine -backgroundColor $prompt_git_background
		Write-Host  " $([char]57504) " -foregroundColor $prompt_git_text -backgroundColor $prompt_git_background -NoNewLine
		Write-Host "$git_string "  -NoNewLine -foregroundColor $prompt_git_text -backgroundColor $prompt_git_background
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor $prompt_git_background
	}
	else{
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor $prompt_background
	}

	Return " "

}
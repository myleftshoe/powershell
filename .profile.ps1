#Author: vhanla

# Set code page to Unicode UTF-8
chcp 65001 > $null

#Force coloring of git and npm commands
$env:TERM = 'cygwin'
$env:TERM = 'FRSX'


$global:foregroundColor = 'white'
$time = Get-Date
$psVersion= $host.Version.Major
$curUser= (Get-ChildItem Env:\USERNAME).Value
$curComp= (Get-ChildItem Env:\COMPUTERNAME).Value

# Change color of command line parameters
Set-PSReadLineOption -Colors @{Parameter = "Magenta"; Operator = "Magenta"; Type="Magenta"}

# Color directory listings
# You must install the PSColor module (https://github.com/Davlind/PSColor) first:
# Install-Module PSColor
Import-Module PSColor

# clear
# Write-Host "- PowerShell V$psVersion -"
# Write-Host
# screenfetch

# Write-Host "Hello, $curUser! " -foregroundColor $foregroundColor -NoNewLine; Write-Host "$([char]9829) " -foregroundColor Red
# Write-Host "Today is: $($time.ToLongDateString())"
# Write-Host "Welcome to PowerShell version: $psVersion" -foregroundColor Green
# Write-Host "I am: $curComp" -foregroundColor Green
# Write-Host "¡Let's program!" `n

# Create home alias to folder in which shell was started
function goHome {Set-Location $_home}
Set-Alias ~~ goHome
Set-Alias * goHome
Set-Alias : goHome
Set-Alias proj goHome

function goUserHome {Set-Location ~}
Set-Alias ~ goUserHome
Set-Alias home goUserHome

function Set-StartDirectory {
	$global:_home = PWD
	Write-Host
	Write-Host "Start folder set to $_home"
	Write-Host
}
Set-Alias ssd Set-StartDirectory

ssd
$DEV = "X:\"
$SCRIPTS = "$DEV\powershell"
$env:path += ";$SCRIPTS"

function dev {cd $DEV}
function scripts {cd $SCRIPTS}
function react {cd $DEV\react}
function sysinfo {clear; screenfetch}

function relativePathToHome{
		$currentPath = (Get-Location).Path
		$currentDrive = (Get-Location).Drive
		$currentDriveLabel = (Get-Volume $currentDrive.Name).FileSystemLabel
		$homeDrive = ($_home).Drive.Root
		if ($currentPath -eq $HOME) {
			if ($HOME -eq $_home) { $trimmedRelativePath = "≋" }
			else { $trimmedRelativePath = "~" }
		}
		elseif ($currentPath -eq $_home) {
			$trimmedRelativePath = "≈"
		}
		elseif ($currentPath -eq $currentDrive.Root) {
			$trimmedRelativePath = $currentDriveLabel
			# if ($trimmedRelativePath -eq "DEV") {$trimmedRelativePath=$([char]0xf121)}
			# $trimmedRelativePath = "$currentDriveLabel ($currentDrive)"
			# $trimmedRelativePath = $currentDrive.Root
		}
		elseif ($currentDrive.Root -ne $homeDrive) {
			$trimmedRelativePath = $currentPath
		}
		else {
			Set-Location $_home
			$relativePath = Resolve-Path -relative $currentPath
			$trimmedRelativePath = $relativePath -replace '^..\\'
			if (($trimmedRelativePath).StartsWith('..')) {
				$trimmedRelativePath = Split-Path $trimmedRelativePath
			}
			$trimmedRelativePath = $trimmedRelativePath -replace '^.\\'
		}
		Set-Location $currentPath
		# Write-Host $relativePath
		# Write-Host $trimmedRelativePath
		return $trimmedRelativePath
}

# function local:write-Time {
# 	$message = "This text is right aligned"
# 	$message=(" {0:HH}:{0:mm}:{0:ss} " -f (Get-Date))
# 	$currentColor=$Host.UI.RawUI.BackgroundColor
# 	$startposx = $Host.UI.RawUI.windowsize.width - $message.length - 2
# 	$host.UI.RawUI.ForegroundColor = "Blue"
# 	$Host.UI.Write("{0,$startposx}" -f "")
# 	$host.UI.RawUI.ForegroundColor = "White"
# 	$host.UI.RawUI.BackgroundColor = "Blue"
# 	$Host.UI.Write($message)
# 	$host.UI.RawUI.ForegroundColor = "Blue"
# 	$host.UI.RawUI.BackgroundColor = $currentColor
# 	$Host.UI.WriteLine("")
# }

function Prompt {
	# Prompt Colors
	# Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
	# Gray DarkGray Blue Green Cyan Red Magenta Yellow White

	$prompt_time_text = "Black"
	$prompt_time_background = "Gray"
	$prompt_text = "White"
	$prompt_background = "Blue"
	$prompt_git_background = "DarkMagenta"
	$prompt_git_text = "Black"

	$currentDrive = (Get-Location).Drive
	$currentDriveLabel = (Get-Volume $currentDrive.Name).FileSystemLabel

	$is_git = git rev-parse --is-inside-work-tree

	$git_branch = "";
	git branch | foreach {
		if ($_ -match "^\* (.*)"){
			$git_branch += $matches[1]
		}
	}
	if (!$git_branch) {
		$git_branch = "(none)"
	}

	# Grab Git Status
	$git_status = ""
	$git_stagedCount = 0
	$git_unstagedCount = 0
	git status --porcelain | foreach {
		$git_status = $_ #just replace other wise it will be empty
		if ($_.substring(0,1) -ne " ") {
			$git_stagedCount += 1
		}
		if ($_.substring(1,1) -ne " ") {
			$git_unstagedCount += 1
		}
	}

    $git_remoteDiffers = $(git rev-list HEAD...origin/master --count)
	if (!$git_remoteDiffers) {
		$git_remoteDiffers = "-"
	}


	$curtime = Get-Date
	# $drive = (PWD).Drive.Name
	$path = Split-Path (PWD) -Leaf

	$relativePath = relativePathToHome

	# Write-Host -NoNewLine (" PS$psVersion " -f (Get-Date)) -foregroundColor $prompt_time_text -backgroundColor $prompt_time_background
	# Write-Host -NoNewLine "⎪" -backgroundColor "Blue" -foregroundColor "Black"
	# write-Host "`r`n"
	$host.UI.RawUI.BufferSize.width=1000
	# write-Time
	Write-Host ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "Gray"
	# Write-Host "($PWD)" -foregroundColor "DarkGray"
	$host.UI.RawUI.ForegroundColor = "White"
	$host.UI.RawUI.BackgroundColor = "Blue"
	$host.UI.Write(" $([char]0xFAB2)")
	$host.UI.RawUI.BackgroundColor = "Black"
	# Write-Host -NoNewLine "`r`n $([char]0xFAB2)" -foregroundColor "White" -backgroundColor "Blue"
	Write-Host -NoNewLine "⎪" -backgroundColor "Blue" -foregroundColor "Black"
	Write-Host -NoNewLine " $currentDriveLabel " -foregroundColor "White" -backgroundColor "Blue"
	Write-Host -NoNewLine "$([char]57528)" -foregroundColor "Blue" -backgroundColor "Gray"
	# Write-Host -NoNewLine " $relativePath " -foregroundColor "Black" -backgroundColor "Gray"
	# Write-Host -NoNewLine (" {0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "White" -backgroundColor "Blue"
	Write-Host -NoNewLine " $path " -foregroundColor "Black" -backgroundColor "Gray"
	# Write-Host " $path " -foregroundColor $prompt_text -backgroundColor $prompt_background -NoNewLine
	# Write-Host " $relativePath " -foregroundColor $prompt_text -backgroundColor $prompt_background -NoNewLine
	# if ($git_unstagedCount) {
	# 	Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Gray" -backgroundColor "Red"
	# 	Write-Host  " $([char]0xE725) "  -NoNewLine -foregroundColor "Black" -backgroundColor "Red"
	# 	Write-Host "$git_branch " -NoNewLine -foregroundColor "Black" -backgroundColor "Red"
	# 	Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Red"
	# }
	# elseif ($git_stagedCount){
	# 	Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Gray" -backgroundColor "Green"
	# 	Write-Host  " $([char]0xE725) " -NoNewLine -foregroundColor "Black" -backgroundColor "Green"
	# 	Write-Host "$git_branch " -NoNewLine -foregroundColor "Black" -backgroundColor "Green"
	# 	Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Green"
	# }
	# elseif ($git_remoteDiffers -gt 0){
	# 	Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Gray" -backgroundColor "Yellow"
	# 	Write-Host  " $([char]0xE725) " -NoNewLine -foregroundColor "Black" -backgroundColor "Yellow"
	# 	Write-Host "$git_branch " -NoNewLine -foregroundColor "Black" -backgroundColor "Yellow"
	# 	Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Yellow"
	# }
	# else {
		Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Gray" -backgroundColor "DarkGray"
		Write-Host  " $([char]0xE725) "  -NoNewLine -foregroundColor "Black" -backgroundColor "DarkGray"
		Write-Host "$git_branch " -NoNewLine -foregroundColor "Black" -backgroundColor "DarkGray"
		Write-Host "$git_stagedCount " -NoNewLine -foregroundColor "Green" -backgroundColor "DarkGray"
		Write-Host "$git_unstagedCount " -NoNewLine -foregroundColor "Red" -backgroundColor "DarkGray"
		Write-Host "$git_remoteDiffers " -NoNewLine -foregroundColor "Yellow" -backgroundColor "DarkGray"
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "DarkGray"
		# Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Gray"
	# }
	# Write-Host -NoNewLine "[" -foregroundColor Yellow
	# Write-Host -NoNewLine "]$" -foregroundColor Yellow
	# Write-Host -NoNewLine "$" -foregroundColor Yellow
	# Write-Host -NoNewLine "$([char]955)" -foregroundColor Green

	# $host.UI.RawUI.WindowTitle = "PS >> User: $curUser >> Current DIR: $((Get-Location).Path)"
	$host.UI.RawUI.WindowTitle = "$((Get-Location).Path)"

	Return " "

}
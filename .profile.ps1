#Author: vhanla

# Set code page to Unicode UTF-8
chcp 65001

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

function Prompt {
	# Prompt Colors
	# Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
	# Gray DarkGray Blue Green Cyan Red Magenta Yellow White

	$prompt_time_text = "Black"
	$prompt_time_background = "Gray"
	$prompt_text = "White"
	$prompt_background = "Blue"
	$prompt_git_background = "DarkGreen"
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
    $git_remoteDiffers = $(git rev-list HEAD...origin/master --count)
	Write-Host $git_remoteDiffers
	if ($(git rev-list HEAD...origin/master --count) -ne 0) {
		$prompt_git_background = "Yellow"
	}

	if ($git_status){
		$prompt_git_background = "DarkMagenta"
	}

	$curtime = Get-Date
	# $drive = (PWD).Drive.Name
	$path = Split-Path (PWD) -Leaf

	$relativePath = relativePathToHome

	# Write-Host -NoNewLine (" PS$psVersion " -f (Get-Date)) -foregroundColor $prompt_time_text -backgroundColor $prompt_time_background
	Write-Host -NoNewLine " $([char]0xFAB2)" -foregroundColor "Blue" -backgroundColor $prompt_time_background
	Write-Host -NoNewLine ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor $prompt_time_text -backgroundColor $prompt_time_background
	Write-Host -NoNewLine "$([char]57520)" -foregroundColor $prompt_time_background -backgroundColor $prompt_background
	# Write-Host " $path " -foregroundColor $prompt_text -backgroundColor $prompt_background -NoNewLine
	Write-Host " $relativePath " -foregroundColor $prompt_text -backgroundColor $prompt_background -NoNewLine
	if ($git_string -and $($git_remoteDiffers -ne $false)){
		Write-Host  "$([char]57520)" -foregroundColor $prompt_background -NoNewLine -backgroundColor $prompt_git_background
		Write-Host  " $([char]0xE725) " -foregroundColor $prompt_git_text -backgroundColor $prompt_git_background -NoNewLine
		Write-Host "$git_string " -NoNewLine -foregroundColor $prompt_git_text -backgroundColor $prompt_git_background
		# Write-Host "$git_differsFromRemote " -NoNewLine -foregroundColor $prompt_git_text -backgroundColor $prompt_git_background
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor $prompt_git_background
	}
	else{
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor $prompt_background
	}
	# Write-Host -NoNewLine "[" -foregroundColor Yellow
	# Write-Host -NoNewLine "]$" -foregroundColor Yellow
	# Write-Host -NoNewLine "$" -foregroundColor Yellow
	# Write-Host -NoNewLine "$([char]955)" -foregroundColor Green

	# $host.UI.RawUI.WindowTitle = "PS >> User: $curUser >> Current DIR: $((Get-Location).Path)"
	$host.UI.RawUI.WindowTitle = "$((Get-Location).Path)"

	Return " "

}
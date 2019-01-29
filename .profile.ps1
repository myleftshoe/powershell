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

function gitStatus { git status $args}
Set-Alias gs gitStatus

ssd
$DOCS = "D:\"
$DEV = "X:\"
$SCRIPTS = "$DEV\powershell"
$env:path += ";$SCRIPTS"

function docs {cd $DOCS}
function dev {cd $DEV}
function scripts {cd $SCRIPTS}
function react {cd $DEV\react}
function sysinfo {clear; screenfetch}

function Show-Colors( ) {
	$colors = [Enum]::GetValues( [ConsoleColor] )
	$max = ($colors | foreach { "$_ ".Length } | Measure-Object -Maximum).Maximum
	foreach( $color in $colors ) {
		Write-Host (" {0,2} {1,$max} " -f [int]$color,$color) -NoNewline
		Write-Host "$color" -Foreground $color
	}
}



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
	$git_stagedCount = 0
	$git_unstagedCount = 0
	git status --porcelain | foreach {
		if ($_.substring(0,1) -ne " ") {
			$git_stagedCount += 1
		}
		if ($_.substring(1,1) -ne " ") {
			$git_unstagedCount += 1
		}
	}

    $git_remoteCommitDiffCount = $(git rev-list HEAD...origin/master --count)


	$curtime = Get-Date
	# $drive = (PWD).Drive.Name
	$path = Split-Path (PWD) -Leaf

	$host.UI.RawUI.BufferSize.width=1000
	Write-Host ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "Gray"
	$host.UI.RawUI.ForegroundColor = "White"
	$host.UI.RawUI.BackgroundColor = "Blue"
	$host.UI.Write(" $([char]0xFAB2)")
	$host.UI.RawUI.BackgroundColor = "Black"
	Write-Host -NoNewLine "⎪" -backgroundColor "Blue" -foregroundColor "Black"
	Write-Host -NoNewLine " $currentDriveLabel " -foregroundColor "White" -backgroundColor "Blue"
	Write-Host -NoNewLine "$([char]57528)" -foregroundColor "Blue" -backgroundColor "Gray"
	Write-Host -NoNewLine " $path " -foregroundColor "White" -backgroundColor "Gray"
	if ($is_git) {
		Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Gray" -backgroundColor "DarkGray"
		Write-Host  " $([char]0xE725) "  -NoNewLine -foregroundColor "Black" -backgroundColor "DarkGray"
		Write-Host "$git_branch " -NoNewLine -foregroundColor "Black" -backgroundColor "DarkGray"
		Write-Host "$git_stagedCount " -NoNewLine -foregroundColor "Green" -backgroundColor "DarkGray"
		Write-Host "$git_unstagedCount " -NoNewLine -foregroundColor "Red" -backgroundColor "DarkGray"
		Write-Host "$git_remoteCommitDiffCount " -NoNewLine -foregroundColor "Yellow" -backgroundColor "DarkGray"
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "DarkGray"
	}
	else {
		Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Gray"
	}

	$windowTitle="$((Get-Location).Path)"
	if ($windowTitle -eq $HOME) {$windowTitle="~"}
	$host.UI.RawUI.WindowTitle = "$windowTitle"

	Return " "

}
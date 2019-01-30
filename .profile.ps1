#Author: psammut

# Set code page to Unicode UTF-8
chcp 65001 > $null

#Force coloring of git and npm commands
$env:TERM = 'cygwin'
$env:TERM = 'FRSX'


$global:foregroundColor = 'white'

# Change color of command line parameters
Set-PSReadLineOption -Colors @{Parameter = "Magenta"; Operator = "Magenta"; Type = "Magenta"}

# Color directory listings
# You must install the PSColor module (https://github.com/Davlind/PSColor) first:
# Install-Module PSColor
Import-Module PSColor

function toSuperscript($text) {
    $hash = @{}
    $hash.0 = "$([char]0x2070)"
    $hash.1 = "$([char]0x00B9)"
    $hash.2 = "$([char]0x00B2)"
    $hash.3 = "$([char]0x00B3)"
    $hash.4 = "$([char]0x2074)"
    $hash.5 = "$([char]0x2075)"
    $hash.6 = "$([char]0x2076)"
    $hash.7 = "$([char]0x2077)"
    $hash.8 = "$([char]0x2078)"
    $hash.9 = "$([char]0x2079)"

    Foreach ($key in $hash.Keys) {
        $text = $text.Replace($key, $hash.$key)
    }
    return $text
}

# Create home alias to folder in which shell was started
function goHome {Set-Location $_home}
Set-Alias ~~ goHome
Set-Alias go~~ goHome

function goUserHome {Set-Location ~}
Set-Alias ~ goUserHome
Set-Alias home goUserHome

function Set-StartDirectory {
    $global:_home = Get-Location
    Write-Host
    Write-Host "Start folder set to $_home"
    Write-Host
}
Set-Alias set~~ Set-StartDirectory

set~~

function Get-StartDirectory {
    Write-Host
    Write-Host $_home
}
Set-Alias get~~ Get-StartDirectory

function gitStatus { git status $args}
Set-Alias gs gitStatus

$DOCS = "D:\"
$DEV = "X:\"
$SCRIPTS = "$DEV\powershell"
$env:path += ";$SCRIPTS"

function docs {Set-Location $DOCS}
function dev {Set-Location $DEV}
function scripts {Set-Location $SCRIPTS}
function react {Set-Location $DEV\react}
function sysinfo {Clear-Host; screenfetch}

function Show-Colors( ) {
    $colors = [Enum]::GetValues( [ConsoleColor] )
    $max = ($colors | ForEach-Object { "$_ ".Length } | Measure-Object -Maximum).Maximum
    foreach ( $color in $colors ) {
        Write-Host (" {0,2} {1,$max} " -f [int]$color, $color) -NoNewline
        Write-Host "$color" -Foreground $color
    }
}



function Prompt {
    # Prompt Colors
    # Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
    # Gray DarkGray Blue Green Cyan Red Magenta Yellow White

    $previousCommand = Get-History -Count 1
    $previousCommandDuration = $previousCommand.Duration.Milliseconds

    $currentDrive = (Get-Location).Drive
    $currentDriveLabel = (Get-Volume $currentDrive.Name).FileSystemLabel

    $is_git = git rev-parse --is-inside-work-tree

    $git_branch = "";
    git branch | ForEach-Object {
        if ($_ -match "^\* (.*)") {
            $git_branch += $matches[1]
        }
    }
    if (!$git_branch) {
        $git_branch = "(none)"
    }

    # Grab Git Status
    $git_stagedCount = 0
    $git_unstagedCount = 0
    git status --porcelain | ForEach-Object {
        if ($_.substring(0, 1) -ne " ") {
            $git_stagedCount += 1
        }
        if ($_.substring(1, 1) -ne " ") {
            $git_unstagedCount += 1
        }
    }
    # $git_stagedColor = git config color.status.added
    # $git_unstagedColor = git config color.status.changed

    $git_remoteCommitDiffCount = $(git rev-list HEAD...origin/master --count)


    # $drive = (PWD).Drive.Name
    $pwdPath = Get-Location
    $pwdLeaf = Split-Path ($pwdPath) -Leaf

    # Write-Host

    Write-Host -NoNewline ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "DarkGray"
    if ($previousCommandDuration) {
        Write-Host -NoNewLine "($previousCommandDuration ms)" -foregroundColor "Gray"
        # Write-Host "('$previousCommand' took $previousCommandDuration ms)"  -foregroundColor "Gray"
    }
    Write-Host
    Write-Host
    # Write-Host "-" -foregroundColor "DarkGray"
    if ("$pwdPath" -eq "$home") {
        if ("$pwdPath" -eq "$_home") {
            Write-Host -NoNewLine " ≋ " -foregroundColor "DarkCyan"
        }
        else {
            Write-Host -NoNewLine " ~ " -foregroundColor "DarkCyan"
        }
    }
    elseif ("$pwdPath" -eq "$_home") {
        Write-Host -NoNewLine " ≈ " -foregroundColor "DarkCyan"
    }

    if ($is_git) {
        $gitRepoPath = $(git rev-parse --show-toplevel).replace("/", "\")
        $gitRepoLeaf = Split-Path (git rev-parse --show-toplevel) -Leaf
        if ("$pwdPath" -ne "$gitRepoPath") {
            $childPath="$pwdPath".replace("$gitRepoPath", "")
            Write-Host -NoNewLine "$childPath in $gitRepoLeaf"
        }
        else {
            Write-Host -NoNewLine "$gitRepoLeaf"
        }

        # Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Blue" -backgroundColor "Gray"
        Write-Host  " $([char]0xE725) "  -NoNewLine -foregroundColor "DarkCyan"
        Write-Host "$git_branch " -NoNewLine -foregroundColor "Gray"
        Write-Host $("$git_stagedCount ") -NoNewLine -foregroundColor "DarkGreen"
        Write-Host $("$git_unstagedCount ") -NoNewLine -foregroundColor "DarkRed"
        Write-Host $("$git_remoteCommitDiffCount") -NoNewLine -foregroundColor "DarkYellow"
        # Write-Host "$git_branch " -NoNewLine -foregroundColor "Gray"
        # Write-Host "$git_stagedCount " -NoNewLine -foregroundColor "DarkGreen"
        # Write-Host "$git_unstagedCount " -NoNewLine -foregroundColor "DarkRed"
        # Write-Host "$git_remoteCommitDiffCount " -NoNewLine -foregroundColor "Gray"
    }
    else {
        # Write-Host -NoNewLine "$([char]0xe5fe)    " -foregroundColor "Yellow"
        Write-Host -NoNewLine "$pwdPath"
    }

    Write-Host

    Write-Host -NoNewLine "$([char]0xf054)$([char]0xf054)$([char]0xf054)" -foregroundColor "yellow"
    # Write-Host -NoNewLine "$([char]0xf054)$([char]0xf054)$([char]0xf054)" -foregroundColor "yellow"

    # $host.UI.RawUI.BufferSize.width = 1000
    # Write-Host -NoNewline ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "Blue"
    # if ($previousCommandDuration) {
    #     Write-Host -NoNewLine "($previousCommandDuration ms)"  -foregroundColor "Gray"
    #     # Write-Host "('$previousCommand' took $previousCommandDuration ms)"  -foregroundColor "Gray"
    # }
    # Write-Host
    # $host.UI.RawUI.ForegroundColor = "White"
    # $host.UI.RawUI.BackgroundColor = "DarkBlue"
    # $host.UI.Write(" $([char]0xFAB2)")
    # $host.UI.RawUI.BackgroundColor = "Black"
    # Write-Host -NoNewLine "⎪" -backgroundColor "DarkBlue" -foregroundColor "Black"
    # Write-Host -NoNewLine " $currentDriveLabel " -foregroundColor "White" -backgroundColor "DarkBlue"
    # Write-Host -NoNewLine "$([char]57528)" -foregroundColor "DarkBlue" -backgroundColor "Blue"
    # Write-Host -NoNewLine " $path " -foregroundColor "White" -backgroundColor "Blue"
    # if ($is_git) {
    #     Write-Host  "$([char]57528)" -NoNewLine -foregroundColor "Blue" -backgroundColor "Gray"
    #     Write-Host  " $([char]0xE725) "  -NoNewLine -foregroundColor "Black" -backgroundColor "Gray"
    #     Write-Host "$git_branch " -NoNewLine -foregroundColor "Black" -backgroundColor "Gray"
    #     Write-Host "$git_stagedCount " -NoNewLine -foregroundColor "DarkGreen" -backgroundColor "Gray"
    #     Write-Host "$git_unstagedCount " -NoNewLine -foregroundColor "DarkRed" -backgroundColor "Gray"
    #     Write-Host "$git_remoteCommitDiffCount " -NoNewLine -foregroundColor "DarkYellow" -backgroundColor "Gray"
    #     Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Gray"
    # }
    # else {
    #     Write-Host  -NoNewLine "$([char]57520)$([char]57521)$([char]57521)$([char]57521)" -foregroundColor "Blue"
    # }

    $windowTitle = "$((Get-Location).Path)"
    if ($windowTitle -eq $HOME) {$windowTitle = "~"}
    $host.UI.RawUI.WindowTitle = "$windowTitle"

    Return " "

}
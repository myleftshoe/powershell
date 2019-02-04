# Multi-line arrowed
#Author: psammut

# Set code page to Unicode UTF-8
chcp 65001 > $null

#Force coloring of git and npm commands
$env:TERM = 'cygwin'
$env:TERM = 'FRSX'


# $global:foregroundColor = 'White'
$global:promptColor = 'Yellow'
$global:dynamicPromptColor="on"
$global:colorIndex=0;

function get-NextColor( ) {
    $colors = [Enum]::GetValues( [ConsoleColor] )
    $max = $colors.length - 1

    $global:colorIndex++
    if ($global:colorIndex -gt $max) {
        $global:colorIndex = 0
    }
    $color= $colors[$colorIndex]
    if ("$color" -eq "$((get-host).ui.rawui.BackgroundColor)") {
        $color = get-NextColor
    }
    return $color
}

function Show-Colors( ) {
    $colors = [Enum]::GetValues( [ConsoleColor] )
    $max = ($colors | ForEach-Object { "$_ ".Length } | Measure-Object -Maximum).Maximum
    foreach ( $color in $colors ) {
        Write-Host (" {0,2} {1,$max} " -f [int]$color, $color) -NoNewline
        Write-Host "  " -Background $color
    }
}


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

$global:timer = "on"
function Set-Timer($state) {
    if ($state -eq "on") {
        $global:timer="on"
    }
    if  ($state -eq "off") {
        $global:timer="off"
    }
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

$global:savedCommandId

function Prompt {
    # Prompt Colors
    # Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
    # Gray DarkGray Blue Green Cyan Red Magenta Yellow White

    $is_git = git rev-parse --is-inside-work-tree

    if ("$dynamicPromptColor" -eq "on") {
        $global:promptColor = Get-NextColor
    }
    $previousCommand = Get-History -Count 1
    if ("$($previousCommand.Id)" -ne "$savedCommandId") {
        $previousCommandDuration = [int]$previousCommand.Duration.TotalMilliseconds
        $global:savedCommandId = $previousCommand.Id
    }
    $currentDrive = (Get-Location).Drive
    $currentDriveLabel = (Get-Volume $currentDrive.Name).FileSystemLabel

    # Write-Host

    if ("$timer" -eq "on") {
        # Write-Host -NoNewLine "    " -foregroundColor "Yellow"
        Write-Host -NoNewline ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "DarkGray"
        if ($previousCommandDuration) {
            Write-Host -NoNewLine "($previousCommandDuration ms)"
        }
        Write-Host
        # Write-Host
    }

    # Write-Host "—" -foregroundColor "DarkGray"
    # $drive = (PWD).Drive.Name
    $pwdItem = (Get-Item (Get-Location))
    $pwdPath = $pwdItem.fullname
    $pwdParentPath = $pwdItem.parent.fullname
    $pwdLeaf = $pwdItem.name

    # Write-Host

    $folderIcon = ""
    if ("$pwdPath" -eq "$home") {
        if ("$pwdPath" -eq "$_home") {
            $folderIcon = "≋"
        }
        else {
            $folderIcon = "~"
        }
    }
    elseif ("$pwdPath" -eq "$_home") {
        $folderIcon = "≈"
    }

    Write-Host "┏━" -foregroundColor "$promptColor" -NoNewLine
    Write-Host " $folderIcon" -NoNewLine -foregroundColor "$promptColor"
    Write-Host " $pwdLeaf" -NoNewLine
    if ("$pwdLeaf" -ne "$pwdPath") {
        Write-Host " ($pwdParentPath)" -NoNewLine -foregroundColor "DarkGray"
    }
    Write-Host
    if ($is_git) {
        Write-Host "┃ " -foregroundColor "$promptColor"
    }
    Write-Host "┗" -foregroundColor "$promptColor" -NoNewLine

    Write-Host "$([char]0x1b)[s" -NoNewLine
    # Write-Host "$([char]0x1b)[2A" -NoNewLine

    # Line 1

    Write-Host "$([char]0x1b)[u" -NoNewLine


    # Line 2
    if ($is_git) {

        $gitLogo = ""
        $gitBranchIcon = ""

        $git_branch = "(none)";
        $git_branch = $(git symbolic-ref --short HEAD)

        $git_commitCount = 0;
        $git_commitCount=$(git rev-list --all --count)

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

        $git_remoteCommitDiffCount = $(git rev-list HEAD...origin/master --count)

        $gitRepoPath = $(git rev-parse --show-toplevel).replace("/", "\")
        $gitRepoLeaf = Split-Path (git rev-parse --show-toplevel) -Leaf

        # $gitRemoteName = $(basename (git remote get-url origin)).replace(".git", "")
        $gitRemoteName = ""
        Try {
            $gitRemoteName = $(Split-Path -Leaf (git remote get-url origin)).replace(".git", "")
        }
        Catch {}

        Write-Host "$([char]0x1b)[1A" -NoNewLine

        if ("$pwdPath" -ne "$gitRepoPath") {
            # $childPath="$pwdPath".replace("$gitRepoPath", "")
            Write-Host " $gitLogo " -NoNewLine -foregroundColor "Yellow"
            Write-Host "$gitRepoLeaf" -NoNewLine
        }

        Write-Host " $gitBranchIcon "  -NoNewLine -foregroundColor "Yellow"
        Write-Host "$git_branch " -NoNewLine
        if ($git_commitCount -eq 0) {
            Write-Host "(no commits) " -NoNewLine -foregroundColor "DarkGray"
        }
        Write-Host $("$git_stagedCount ") -NoNewLine -foregroundColor "Green"
        Write-Host $("$git_unstagedCount ") -NoNewLine -foregroundColor "Red"
        Write-Host $("$git_remoteCommitDiffCount") -NoNewLine -foregroundColor "Yellow"
        # warn if remote name != local folder name
        if ("$gitRemoteName" -and ("$gitRemoteName" -ne "$gitRepoLeaf")) {
            Write-Host " 肋" -NoNewLine -foregroundColor "Yellow"
            Write-Host "$gitRemoteName" -NoNewLine -foregroundColor "Yellow"
        }

        Write-Host "$([char]0x1b)[u" -NoNewLine
        # Write-Host
    }

    $windowTitle = "$((Get-Location).Path)"
    if ($windowTitle -eq $HOME) {$windowTitle = "~"}
    $host.UI.RawUI.WindowTitle = "$windowTitle"

    Return " "

}
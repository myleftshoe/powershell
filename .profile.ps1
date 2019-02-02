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

$promptState = @{}
$promptState.pwd = ""
$promptState.gitStagedCount = ""
$promptState.gitUnstagedCount = ""
$promptState.gitRemoteCommitDiffCount = ""

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


$folderIcon = ""
$gitLogo = ""
$gitBranchIcon = ""
$gitRemoteIcon = "肋"

function Prompt {

    # Prompt Colors
    # Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
    # Gray DarkGray Blue Green Cyan Red Magenta Yellow White

    function stateChanged {
        return (($promptState.pwd -ne $pwdPath) -or `
            ($gitRepoPath -ne $promptState.gitRepoPath) -or `
            ($gitStagedCount -ne $promptState.gitStagedCount) -or `
            ($gitUnstagedCount -ne $promptState.gitUnstagedCount) -or `
            ($gitRemoteCommitDiffCount -ne $promptState.gitRemoteCommitDiffCount)
        )
    }

    $is_git = git rev-parse --is-inside-work-tree
    if ($is_git) {

        $gitBranch = "(none)";
        $gitBranch = $(git symbolic-ref --short HEAD)

        $gitCommitCount = 0;
        $gitCommitCount=$(git rev-list --all --count)

        $gitStagedCount = 0
        $gitUnstagedCount = 0
        git status --porcelain | ForEach-Object {
            if ($_.substring(0, 1) -ne " ") {
                $gitStagedCount += 1
            }
            if ($_.substring(1, 1) -ne " ") {
                $gitUnstagedCount += 1
            }
        }

        $gitRemoteCommitDiffCount = $(git rev-list HEAD...origin/master --count)

        $gitRepoPath = $(git rev-parse --show-toplevel).replace("/", "\")
        $gitRepoLeaf = Split-Path (git rev-parse --show-toplevel) -Leaf

        # $gitRemoteName = $(basename (git remote get-url origin)).replace(".git", "")
        $gitRemoteName = ""
        Try {
            $gitRemoteName = $(Split-Path -Leaf (git remote get-url origin)).replace(".git", "")
        }
        Catch {}
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
        Write-Host
        # Write-Host -NoNewLine "    " -foregroundColor "Yellow"
        Write-Host -NoNewline ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "DarkGray"
        if ($previousCommandDuration) {
            Write-Host -NoNewLine "($previousCommandDuration ms)"
        }
        Write-Host
        Write-Host
    }

    # Write-Host "—" -foregroundColor "DarkGray"
    # $drive = (PWD).Drive.Name
    $pwdItem = (Get-Item (Get-Location))
    $pwdPath = $pwdItem.fullname
    $pwdParentPath = $pwdItem.parent.fullname
    $pwdLeaf = $pwdItem.name


    if (stateChanged) {

        if ("$dynamicPromptColor" -eq "on") {
            $global:promptColor = Get-NextColor
        }

        if ($promptState.pwd -ne $pwdPath) {
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
            Write-Host "▃" -foregroundColor "$promptColor"
            Write-Host "█" -foregroundColor "$promptColor" -NoNewLine
            Write-Host " $folderIcon" -NoNewLine -foregroundColor "$promptColor"
            Write-Host " $pwdLeaf" -NoNewLine
            if ("$pwdLeaf" -ne "$pwdPath") {
                Write-Host " ($pwdParentPath)" -NoNewLine -foregroundColor "DarkGray"
            }
        }

        if ($is_git) {
            Write-Host
            Write-Host "█" -foregroundColor "$promptColor" -NoNewLine
            if ("$pwdPath" -ne "$gitRepoPath") {
                # $childPath="$pwdPath".replace("$gitRepoPath", "")
                Write-Host " $gitLogo " -NoNewLine -foregroundColor "Yellow"
                Write-Host "$gitRepoLeaf" -NoNewLine
            }

            Write-Host " $gitBranchIcon "  -NoNewLine -foregroundColor "Yellow"
            Write-Host "$gitBranch " -NoNewLine
            if ($gitCommitCount -eq 0) {
                Write-Host "(no commits) " -NoNewLine -foregroundColor "DarkGray"
            }
            Write-Host $("$gitStagedCount ") -NoNewLine -foregroundColor "Green"
            Write-Host $("$gitUnstagedCount ") -NoNewLine -foregroundColor "Red"
            Write-Host $("$gitRemoteCommitDiffCount") -NoNewLine -foregroundColor "Yellow"
            # warn if remote name != local folder name
            if ("$gitRemoteName" -and ("$gitRemoteName" -ne "$gitRepoLeaf")) {
                Write-Host " $gitRemoteIcon" -NoNewLine -foregroundColor "Yellow"
                Write-Host "$gitRemoteName" -NoNewLine -foregroundColor "Yellow"
            }
        }
        Write-Host
        Write-Host "▀" -foregroundColor "$promptColor" -NoNewLine
    }


    # Write-Host "$([char]0x1b)[u" -NoNewLine
    # Write-Host

    $promptState.pwd = "$pwdPath"
    $promptState.gitRepoPath = $gitRepoPath
    $promptState.gitStagedCount = $gitStagedCount
    $promptState.gitUnstagedCount = $gitUnstagedCount
    $promptState.gitRemoteCommitDiffCount = $gitRemoteCommitDiffCount

    Write-Host
    Write-Host "" -NoNewLine -foregroundColor "$promptColor"

    $windowTitle = "$((Get-Location).Path)"
    if ($windowTitle -eq $HOME) {$windowTitle = "~"}
    $host.UI.RawUI.WindowTitle = "$windowTitle"

    Return " "

}
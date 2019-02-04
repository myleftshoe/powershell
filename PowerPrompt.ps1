#Author: psammut

$global:_showprompt=""
# $global:foregroundColor = 'White'
$global:primary = "Blue"
$global:tint = "DarkBlue"
$global:dynamicPromptColor="on"
$global:colorIndex=0;

function showprompt() {
    $global:_showprompt="on"
}

function get-NextColor( ) {

    $global:colorIndex++
    if ($global:colorIndex -gt ($palette.length - 1)) {
        $global:colorIndex = 0
    }
    $color= $palette[$colorIndex]
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
$global:savedCommandId

$folderIcon = ""
$gitLogo = ""
$gitBranchIcon = ""
$gitRemoteIcon = "肋"

# Prompt Colors
# Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
# Gray DarkGray Blue Green Cyan Red Magenta Yellow White

$esc="$([char]0x1b)"
# Control character sequences
$fg = [ordered]@{
    "Black"         = "$esc[30m";
    "DarkBlue"      = "$esc[34m";
    "DarkGreen"     = "$esc[32m";
    "DarkCyan"      = "$esc[36m";
    "DarkRed"       = "$esc[31m";
    "DarkMagenta"   = "$esc[35m";
    "DarkYellow"    = "$esc[33m";
    "Gray"          = "$esc[37m";
    # "Extended"      = "$esc[38m";
    # "Default"       = "$esc[39m";
    "DarkGray"      = "$esc[90m";
    "Blue"          = "$esc[94m";
    "Green"         = "$esc[92m";
    "Cyan"          = "$esc[96m";
    "Red"           = "$esc[91m";
    "Magenta"       = "$esc[95m";
    "Yellow"        = "$esc[93m";
    "White"         = "$esc[97m";
}
$bg = [ordered]@{
    "Black"         = "$esc[40m";
    "DarkBlue"      = "$esc[44m";
    "DarkGreen"     = "$esc[42m";
    "DarkCyan"      = "$esc[46m";
    "DarkRed"       = "$esc[41m";
    "DarkMagenta"   = "$esc[45m";
    "DarkYellow"    = "$esc[43m";
    "Gray"          = "$esc[47m";
    # "Extended"      = "$esc[38m";
    # "Default"       = "$esc[39m";
    "DarkGray"      = "$esc[100m";
    "Blue"          = "$esc[104m";
    "Green"         = "$esc[102m";
    "Cyan"          = "$esc[106m";
    "Red"           = "$esc[101m";
    "Magenta"       = "$esc[105m";
    "Yellow"        = "$esc[103m";
    "White"         = "$esc[107m";
}

# $palette = @("Blue", "Green",  "Cyan", "Red", "Magenta", "Yellow", "Gray")
$palette = @("DarkBlue", "DarkGreen",  "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "DarkGray")

function WriteLinePadded ($text) {
    [Console]::Write($text)
    [Console]::Write(" $([char]0x1b)[400@")
    [Console]::WriteLine("$([char]0x1b)[0m")
}


function Prompt {

    function stateChanged {
        return ($_showprompt) -or
            (($promptState.pwd -ne $pwdPath) -or `
            ($gitRepoPath -ne $promptState.gitRepoPath) -or `
            ($gitStagedCount -ne $promptState.gitStagedCount) -or `
            ($gitUnstagedCount -ne $promptState.gitUnstagedCount) -or `
            ($gitRemoteCommitDiffCount -ne $promptState.gitRemoteCommitDiffCount)
        )
    }

    function saveState {
        $promptState.pwd = "$pwdPath"
        $promptState.gitRepoPath = $gitRepoPath
        $promptState.gitStagedCount = $gitStagedCount
        $promptState.gitUnstagedCount = $gitUnstagedCount
        $promptState.gitRemoteCommitDiffCount = $gitRemoteCommitDiffCount
    }

    function setWindowTitle {
        $windowTitle = "$((Get-Location).Path)"
        if ($windowTitle -eq $HOME) {$windowTitle = "~"}
        $host.UI.RawUI.WindowTitle = "$windowTitle"
    }

    $previousCommand = Get-History -Count 1
    if ("$($previousCommand.Id)" -ne "$savedCommandId") {
        $previousCommandDuration = [int]$previousCommand.Duration.TotalMilliseconds
        $global:savedCommandId = $previousCommand.Id
    }

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
    else {
        Write-Host
    }


    # $currentDrive = (Get-Location).Drive
    # $currentDriveLabel = (Get-Volume $currentDrive.Name).FileSystemLabel


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

    # Write-Host "—" -foregroundColor "DarkGray"
    # $drive = (PWD).Drive.Name
    $pwdItem = (Get-Item (Get-Location))
    $pwdPath = $pwdItem.fullname
    $pwdParentPath = $pwdItem.parent.fullname
    $pwdLeaf = $pwdItem.name


    if (stateChanged) {

        if ("$dynamicPromptColor" -eq "on") {
            $global:primary = Get-NextColor
            $global:tintTextColor=$primary
            if ($primary.startsWith("Dark")) {
                $global:primaryTextColor="White"
                $global:secondaryTextColor="Black"
                $global:tint = $primary.replace("Dark", "")
            }
            else {
                $global:primaryTextColor="Black"
                $global:secondaryTextColor="White"
                $global:tint = "Dark$($primary)"
            }
        }

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
        # [Console]::Write("$([char]0x1b)[44m")
        # Write-Host -NoNewLine "    ▕" -foregroundColor "Black" -backgroundColor "$primary"

        # [Console]::Write($bg.Red)
        $Icon = $bg.$primary +  "     "
        $Text = $bg.$tint
        WriteLinePadded ($Icon + $Text)

        $Icon = $bg.$primary + $fg.$primaryTextColor + "  $folderIcon  "
        $Text = $bg.$tint  + $fg.$secondaryTextColor + "  $pwdLeaf"
        if ("$pwdLeaf" -ne "$pwdPath") {
            $Text = $Text + $fg.$tintTextColor + " in $pwdParentPath"
        }
        WriteLinePadded ($Icon + $Text)

        if ($is_git) {
            # Write-Host
            # Write-Host "█" -foregroundColor "$primary" -NoNewLine
            if ("$pwdPath" -ne "$gitRepoPath") {
                $Icon = $bg.$primary + $fg.$primaryTextColor +  "  $gitLogo  "
                $Text = $bg.$tint + $fg.$secondaryTextColor + "  $gitRepoLeaf"
                WriteLinePadded ($Icon + $Text)
            }
            $Icon = $bg.$primary + $fg.$primaryTextColor +  "  $gitBranchIcon  "
            $Text = $bg.$tint + $fg.$secondaryTextColor + "  $gitBranch"
            if ($gitCommitCount -eq 0) {
                $Text = $Text + $fg.$tintTextColor + " (no commits)"
            }
            $green=$fg.Green
            $red=$fg.Red
            $yellow=$fg.Yellow

            switch ($tint)
            {
                "Green" {$green=$fg.DarkGreen}
                "Red" {$red=$fg.DarkRed}
                "Yellow" {$yellow=$fg.DarkYellow}
            }

            $Text = $Text + $green + " $gitStagedCount"
            $Text = $Text + $red + " $gitUnstagedCount"
            $Text = $Text + $yellow + " $gitRemoteCommitDiffCount"
            WriteLinePadded ($Icon + $Text)
            # warn if remote name != local folder name
            if ("$gitRemoteName" -and ("$gitRemoteName" -ne "$gitRepoLeaf")) {
                $Icon = $bg.$primary + $fg.$primaryTextColor +  "  $gitRemoteIcon "
                $Text = $bg.$tint + $fg.$secondaryTextColor + "  $gitRemoteName"
                WriteLinePadded ($Icon + $Text)
            }
        }
        $Icon = $bg.$primary +  "     "
        $Text = $bg.$tint
        WriteLinePadded ($Icon + $Text)
        [Console]::WriteLine()
    }

    [Console]::Write(($fg.$primary + " "))

    saveState
    setWindowTitle
    $global:_showprompt=""

    Return "  "

}
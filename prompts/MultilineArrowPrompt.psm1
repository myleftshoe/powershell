#Author: psammut

# $script:foregroundColor = 'White'
$script:promptColor = 'Yellow'
$script:dynamicPromptColor="on"
$script:colorIndex=0;

function get-NextColor( ) {
    $colors = [Enum]::GetValues( [ConsoleColor] )
    $max = $colors.length - 1

    $script:colorIndex++
    if ($script:colorIndex -gt $max) {
        $script:colorIndex = 0
    }
    $color= $colors[$colorIndex]
    if ("$color" -eq "$((get-host).ui.rawui.BackgroundColor)") {
        $color = get-NextColor
    }
    return $color
}


function MultilineArrowPrompt {
    # Prompt Colors
    # Black DarkBlue DarkGreen DarkCyan DarkRed DarkMagenta DarkYellow
    # Gray DarkGray Blue Green Cyan Red Magenta Yellow White

    $is_git = git rev-parse --is-inside-work-tree

    if ("$dynamicPromptColor" -eq "on") {
        $script:promptColor = Get-NextColor
    }

    $currentDrive = (Get-Location).Drive
    $currentDriveLabel = (Get-Volume $currentDrive.Name).FileSystemLabel

    # Write-Host


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
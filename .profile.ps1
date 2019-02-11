#Author: psammut

# Set code page to Unicode UTF-8
chcp 65001 > $null

#Force coloring of git and npm commands
# $env:TERM = 'cygwin'
# $env:TERM = 'FRSX'

# Change color of command line parameters
Set-PSReadLineOption -Colors @{Parameter = "Magenta"; Operator = "Magenta"; Type = "Magenta"}

# Color directory listings
# You must install the PSColor module (https://github.com/Davlind/PSColor) first:
# Install-Module PSColor
Import-Module PSColor

# folder in which shell was started
function ~~ {Set-Location $START}
function ~ {Set-Location ~}

function Set-StartDirectory {
    $global:START = Get-Location
    Write-Host
    Write-Host "Start folder set to $START"
    Write-Host
}
Set-Alias set~~ Set-StartDirectory

set~~

function Get-StartDirectory {
    Write-Host
    Write-Host $START
}
Set-Alias get~~ Get-StartDirectory

function gitStatus { git status $args}
Set-Alias gs gitStatus

$DATA = "D:\"
$DOCS = "$DATA\Documents"
$DEV = "X:\"
$SCRIPTS = "$DEV\$\powershell"
$env:path += ";$SCRIPTS"

function \ { cd \ }
function / { cd \ }
function modules {Set-Location $DOCS\PowerShell\Modules}
function docs {Set-Location $DOCS}
function dev {Set-Location $DEV}
function rel {Set-Location $DEV\releases}
function pow {Set-Location $SCRIPTS}
function pwr {Set-Location $SCRIPTS}
function scripts {Set-Location $SCRIPTS}
function react {Set-Location $DEV\react}
function sysinfo {Clear-Host; screenfetch}

Import-Module PowerPrompt
function Prompt() {
    PowerPrompt
}

function pp { PowerPrompt -show }
function ton { PowerPromptTimer -on }
function toff { PowerPromptTimer -off }

function $ { cd $DEV\$ }

$GO="$DEV\$\go"

function new-junction {
    $target= (Get-Item (Get-Location))
    # SymbolicLink seems to require admin priveleges whereas Juncrtion does not???
    # New-Item -ItemType SymbolicLink -Path $QUICKACCESS -name $target.name -Value $target
    $path="$GO\$($target.name)".replace("\\", "\")
    write-host
    try {
        New-Item -ItemType Junction -Path $path -Value $target -ErrorAction stop
        write-host "[GO] Created $path"

    } catch {
        write-host "[GO] $path already exists!"
    }
    write-host
    write-host $msg
    return $path
}

function go {
    param([string]$param)
    if (-not (Test-Path "$GO")) {
        mkdir "$GO"
    }
    if ($param -eq "+") {
        $newJunction = new-junction
        return
    }
    $names=@((Get-ChildItem -path $GO).Name)
    $junctionPath=Get-Location
    try {
        if ($param) {
            $junctionPath= "$GO\$param"
            try {
                $index=[int]$param
                $junctionPath= "$GO\$($names[[int]$param-1])"
            }
            catch {}
        }
        $target = (Get-Item $junctionPath).target[0] 2>$null
        if ($target) {
            cd "$target"
            return
        }
    }
    catch {}
    # Not adding or target not found:
    write-host

    $Info=@()
    for($i = 0; $i -lt $names.count; $i++) {
        $objInfo = New-Object PSObject -Property @{
            'id' = $i + 1
            'name' = $names[$i]
        }
        $Info += $objInfo
    }

    $Info | select id, name | format-table -HideTableHeaders

    $id = read-host -prompt 'go '

    try {
        $index=[int]$id
        if (($index -gt 0) -and ($index -le $names.count)) {
            $junctionPath= "$GO\$($names[[int]$index-1])"
            $target = (Get-Item $junctionPath).target[0] 2>$null
            if ($target) { cd $target }
        }
    }
    catch {}

}

function gogo {
    cd $GO
    # write-host
    # (Get-ChildItem).Name
}

# Not used
function createShortcut($ShortcutPath, $TargetPath) {

    # [parameter(Mandatory, Position = 0)]
    # param[String]$ShortcutPath,
    # # [Parameter(Mandatory, Position = 1)]
    # [String]$TargetPath,


    $Shell = New-Object -ComObject ("WScript.Shell")
    # write-host $TargetPath
    $Shortcut = $Shell.CreateShortcut("$ShortcutPath")
    $Shortcut.TargetPath = "$TargetPath"
    $Shortcut.Save()

}

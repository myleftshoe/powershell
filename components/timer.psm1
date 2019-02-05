$script:timer=1
$script:savedCommandId

function PowerPromptTimer {
    param(
        [switch]$on,
        [switch]$off
    )
    if ($on) {
        $script:timer=1
        return
    }
    if ($off) {
        $script:timer=0
        return
    }
}

function ShowTimer {
    $previousCommand = Get-History -Count 1
    if ("$($previousCommand.Id)" -ne "$savedCommandId") {
        $previousCommandDuration = [int]$previousCommand.Duration.TotalMilliseconds
        $script:savedCommandId = $previousCommand.Id
    }

    if ($timer) {
        Write-Host
        # Write-Host -NoNewLine "    " -foregroundColor "Yellow"
        Write-Host -NoNewline ("{0:HH}:{0:mm}:{0:ss} " -f (Get-Date)) -foregroundColor "DarkGray"
        if ($previousCommandDuration) {
            Write-Host -NoNewLine "($previousCommandDuration ms)"
        }
        Write-Host
    }
}

#Author: psammut
# if (-not (Test-Path env:PowerPromptName)) {
#     $env:PowerPromptName = "PanelPrompt"
#     [Environment]::SetEnvironmentVariable("PowerPromptName", "PanelPrompt", "User")
# }
$script:defaultPrompt="PanelPrompt"
$script:disabled=0


function PowerPrompt {

    param(
        [string]$name,
        [switch]$persist,
        [switch]$disable,
        [switch]$enable
    )

    # Any error causes the standard powershell prompt to display
    if ($disable) {
        $script:disabled=1
        return
    }
    if ($enable) {
        $script:disabled=0
        return
    }
    if ($disabled) {
        return
    }

    if ($name) {
        $env:PowerPromptName=$name
        if ($persist) {
            [environment]::SetEnvironmentVariable("PowerPromptName", "$name", "User")
        }
        return
    }

    if (-not (Test-Path env:PowerPromptName)) {
        $env:PowerPromptName = "$defaultPrompt"
        [environment]::SetEnvironmentVariable("PowerPromptName", "$defaultPrompt", "User")
    }

    & $env:PowerPromptName

    return "  "
}

Export-ModuleMember -Function PowerPrompt
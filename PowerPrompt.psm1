#Author: psammut
# if (-not (Test-Path env:PowerPromptName)) {
#     $env:PowerPromptName = "PanelPrompt"
#     [Environment]::SetEnvironmentVariable("PowerPromptName", "PanelPrompt", "User")
# }
$script:defaultPrompt="PanelPrompt"
$script:disabled=0


function PowerPrompt {

    Param(
        [string]$name,
        [switch]$persist,
        [switch]$disable,
        [switch]$enable
    )

    # Any error causes the standard powershell prompt to display
    if ($disable) {
        $script:disabled=1
        Return
    }
    if ($enable) {
        $script:disabled=0
        Return
    }
    if ($disabled) {
        Return
    }

    if ($name) {
        $Env:PowerPromptName=$name
        if ($persist) {
            [Environment]::SetEnvironmentVariable("PowerPromptName", "$name", "User")
        }
        Return
    }

    if (-not (Test-Path env:PowerPromptName)) {
        $env:PowerPromptName = "$defaultPrompt"
        [Environment]::SetEnvironmentVariable("PowerPromptName", "$defaultPrompt", "User")
    }

    & $Env:PowerPromptName

    Return "  "
}

Export-ModuleMember -Function PowerPrompt
#Author: psammut
# if (-not (Test-Path env:PowerPromptName)) {
#     $env:PowerPromptName = "PanelPrompt"
#     [Environment]::SetEnvironmentVariable("PowerPromptName", "PanelPrompt", "User")
# }
$script:defaultPrompt="PanelPrompt"


function PowerPrompt {

    Param(
        [string]$name,
        [switch]$persist
    )

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
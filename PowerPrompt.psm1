$script:defaultPrompt="PanelPrompt"
$script:disabled=0
<#
 .Synopsis
  Pimp your PowerShell prompt!

 .Parameter name

  Set the prompt to the style specifed by name

 .Parameter persist

  Persist the prompt across sessions. Setting the name parameter without this will
  only change the prompt for the duration of the session.

 .Parameter disable

  Disable PowerPrompt, i.e. use the standard PS> prompt. Lasts for the duration
  of the session only. (Comment out the prompt function in your powershell profile
  to disable it permanently.)

 .Parameter enable

  Re-enable PowerPrompt if you have disabled it using -disable.

 .Example
  PowerPrompt MultilineArrowPrompt
  (Changes the prompt to another style)

 .Example
  PowerPrompt PowerlineStyle -persist
  (Changes the prompt and persists it across sessions)

 .Example
  PowerPrompt -disable
  (Temporarily disables PowerPrompt)

.Example
  PowerPrompt -enable
 (Re-enables it)
#>
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

    ShowTimer
    Write-Host
    & $env:PowerPromptName

    return "  "
}

Export-ModuleMember -Function PowerPrompt
Export-ModuleMember -Function PowerPromptTimer

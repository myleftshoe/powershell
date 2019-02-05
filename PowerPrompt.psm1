#Author: psammut
function PowerPrompt([string]$PromptName) {

    & $PromptName
    # PanelPrompt
    Return "  "

}
Export-ModuleMember -Function PowerPrompt
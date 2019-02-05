@{
    ModuleVersion = '1.0'
    GUID = '200df696-29c1-4b3b-9e06-a297b881ad8d'
    RootModule = 'PowerPrompt.psm1'
    NestedModules = @(
      '.\components\timer.psm1'
      '.\prompts\PanelPrompt.psm1'
      '.\prompts\MultilineArrowPrompt.psm1'
      '.\prompts\PowerlineStylePrompt.psm1'
    )
    FunctionsToExport = @('*')
}
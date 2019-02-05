@{
    ModuleVersion = '1.0'
    GUID = '200df696-29c1-4b3b-9e06-a297b881ad8d'
    RootModule = 'PowerPrompt.psm1'
    NestedModules = @(
      '.\prompts\PanelPrompt.psm1'
      '.\prompts\MultilineArrowPrompt.psm1'
    )
    FunctionsToExport = @('*')
}
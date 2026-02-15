@{
    # Regles a exclure pour un script GUI WPF PowerShell
    ExcludeRules = @(
        'PSAvoidGlobalVars',                           # Variables globales necessaires pour WPF event handlers
        'PSUseUsingScopeModifierInNewRunspaces',        # Start-Job utilise -ArgumentList, pas $Using:
        'PSUseDeclaredVarsMoreThanAssignments',         # Variables FindName() utilisees par le binding XAML
        'PSUseShouldProcessForStateChangingFunctions',  # GUI n'utilise pas -WhatIf/-Confirm
        'PSAvoidOverwritingBuiltInCmdlets',             # Write-Log est intentionnel
        'PSUseSingularNouns',                           # Import-Editions est plus clair que Import-Edition
        'PSReviewUnusedParameter',                      # Parametres passes via Dispatcher/XAML
        'PSAvoidUsingWriteHost',                        # Write-Host necessaire pour scripts post-install interactifs
        'PSAvoidEmptyCatchBlock'                        # Blocs catch vides acceptables pour ignorer erreurs non-critiques
    )
}

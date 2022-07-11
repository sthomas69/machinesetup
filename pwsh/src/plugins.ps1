Invoke-Expression (oh-my-posh --init --shell pwsh --config "$PSScriptRoot/.omp.json")

Import-Module -Name Terminal-Icons

# setup autocompletes
Import-Module PSReadLine
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# setup BoxStarter Modules
Import-Module Boxstarter.Chocolatey
